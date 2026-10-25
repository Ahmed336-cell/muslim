import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'player.dart';
import 'reciter_match.dart';

export 'reciter_match.dart';

/// Identifies a reciter from a short clip.
///
/// The voiceprints in [catalogAsset] were built with [modelName]. The same
/// file has to run here; a different speaker model would rank nonsense.
class ReciterId {
  ReciterId({http.Client? client}) : _client = client ?? http.Client();

  static const modelName = 'nemo_en_titanet_small.onnx';
  static final modelUrl = Uri.parse(
    'https://github.com/k2-fsa/sherpa-onnx/releases/download/'
    'speaker-recongition-models/$modelName',
  );
  static const modelSha256 =
      'ad4a1802485d8b34c722d2a9d04249662f2ece5d28a7a039063ca22f515a789e';
  static const modelBytes = 40257283;

  static const catalogAsset = 'assets/reciter_id/catalog.json';
  static const embeddingsAsset = 'assets/reciter_id/embeddings.bin';

  /// Cosine on TitaNet. On a 289-voice catalogue, a surah that was not used
  /// for enrollment matched the right reciter at 0.73 or above. The two
  /// misses topped out at 0.65, so those stay "unknown".
  static const threshold = 0.70;

  /// Sixteen seconds. Long enough to name a voice and place an ayah.
  /// A shorter take still scores when the simulator mic delivers less.
  static const listenFor = Duration(seconds: 16);
  static const minListen = Duration(seconds: 20);
  static const window = Duration(seconds: 20);
  static const hop = Duration(seconds: 10);

  /// When two or more windows exist, at least this fraction must name the
  /// same reciter as the pooled vector.
  static const minAgreement = 0.5;

  final http.Client _client;
  final _recorder = AudioRecorder();
  String? _dir;
  sherpa.SpeakerEmbeddingExtractor? _extractor;
  List<ReciterVoice>? _voices;
  Float32List? _embeddings;
  var _bindingsReady = false;

  Future<String> _path(String name) async {
    _dir ??= (await getApplicationSupportDirectory()).path;
    return '$_dir/$name';
  }

  Future<String> get _modelPath => _path(modelName);

  Future<bool> hasModel() async => File(await _modelPath).exists();

  Future<void> _bindings() async {
    if (_bindingsReady) return;
    await sherpa.initBindingsAsync();
    _bindingsReady = true;
  }

  /// Throws on a network failure or a corrupt download.
  Future<void> downloadModel({void Function(double)? onProgress}) async {
    final target = await _modelPath;
    if (await File(target).exists()) return;
    final part = File('$target.part');
    final response = await _client.send(http.Request('GET', modelUrl));
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: modelUrl);
    }
    final total = response.contentLength ?? modelBytes;
    final digest = _DigestSink();
    final hasher = sha256.startChunkedConversion(digest);
    final sink = part.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        hasher.add(chunk);
        received += chunk.length;
        onProgress?.call(received / total);
      }
      await sink.close();
      hasher.close();
    } catch (_) {
      await sink.close();
      if (await part.exists()) await part.delete();
      rethrow;
    }
    if (digest.value.toString() != modelSha256) {
      await part.delete();
      throw const FileSystemException('Model checksum mismatch');
    }
    await part.rename(target);
  }

  Future<void> loadCatalog() async {
    if (_voices != null) return;
    final meta =
        jsonDecode(await rootBundle.loadString(catalogAsset))
            as Map<String, dynamic>;
    final items = meta['items'] as List? ?? const [];
    final dim = meta['dim'] as int? ?? 0;
    final voices = [
      for (final item in items)
        ReciterVoice.fromJson(item as Map<String, dynamic>),
    ];
    final bytes = await rootBundle.load(embeddingsAsset);
    final embeddings = bytes.buffer.asFloat32List(
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ 4,
    );
    if (voices.isEmpty || dim == 0) {
      _voices = const [];
      _embeddings = Float32List(0);
      return;
    }
    if (embeddings.length != voices.length * dim) {
      throw StateError(
        'voice catalog is corrupt (${embeddings.length} floats, '
        '${voices.length} x $dim)',
      );
    }
    _voices = voices;
    _embeddings = embeddings;
  }

  Future<sherpa.SpeakerEmbeddingExtractor> _openExtractor() async {
    final existing = _extractor;
    if (existing != null) return existing;
    await _bindings();
    final extractor = sherpa.SpeakerEmbeddingExtractor(
      config: sherpa.SpeakerEmbeddingExtractorConfig(
        model: await _modelPath,
        numThreads: 2,
        debug: false,
      ),
    );
    return _extractor = extractor;
  }

  var _cancelled = false;

  /// Stops a [listen] that is still recording.
  void stop() {
    _cancelled = true;
  }

  /// Records [listenFor] from the microphone. Null when permission is
  /// denied or [stop] was called.
  Future<ListenCapture?> listen({
    void Function(double progress)? onProgress,
  }) async {
    _cancelled = false;
    if (!await _recorder.hasPermission()) {
      return ListenCapture(
        matches: [],
        pcm: ListenCapture._emptyPcm,
        denied: true,
      );
    }
    await loadCatalog();
    final voices = _voices;
    final embeddings = _embeddings;
    if (voices == null || embeddings == null || voices.isEmpty) {
      return ListenCapture(matches: [], pcm: ListenCapture._emptyPcm);
    }
    final chunks = <Uint8List>[];
    StreamSubscription<Uint8List>? sub;
    try {
      final audio = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      sub = audio.listen(
        chunks.add,
        onError: (Object error, StackTrace stack) {
          debugPrint('identify mic: $error\n$stack');
        },
      );
      final started = DateTime.now();
      while (!_cancelled && DateTime.now().difference(started) < listenFor) {
        onProgress?.call(
          (DateTime.now().difference(started).inMilliseconds /
                  listenFor.inMilliseconds)
              .clamp(0.0, 1.0)
              .toDouble(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    } finally {
      try {
        await _recorder.stop();
      } catch (_) {}
      await sub?.cancel();
      await usePlaybackSession();
    }
    if (_cancelled) return null;
    final bytes = BytesBuilder(copy: false);
    for (final chunk in chunks) {
      bytes.add(chunk);
    }
    final pcm = bytes.takeBytes();
    final found = await identifyPcm16(pcm);
    return ListenCapture(
      matches: found.matches,
      pcm: pcm,
      agreement: found.agreement,
    );
  }

  /// [pcm16] is little-endian mono 16 kHz. Empty under 3 seconds.
  Future<({List<ReciterMatch> matches, double agreement})> identifyPcm16(
    Uint8List pcm16,
  ) async {
    await loadCatalog();
    final voices = _voices ?? const <ReciterVoice>[];
    final embeddings = _embeddings;
    if (voices.isEmpty || embeddings == null) {
      return (matches: const <ReciterMatch>[], agreement: 0.0);
    }
    final samples = _pcm16ToFloat(pcm16);
    final windows = _windows(samples);
    if (windows.isEmpty) return (matches: const <ReciterMatch>[], agreement: 0.0);
    final extractor = await _openExtractor();
    final vectors = <Float32List>[];
    for (final chunk in windows) {
      final stream = extractor.createStream();
      try {
        stream.acceptWaveform(samples: chunk, sampleRate: 16000);
        stream.inputFinished();
        if (!extractor.isReady(stream)) continue;
        vectors.add(extractor.compute(stream));
      } finally {
        stream.free();
      }
    }
    if (vectors.isEmpty) {
      return (matches: const <ReciterMatch>[], agreement: 0.0);
    }
    final matches = rankReciters(_pool(vectors), embeddings, voices);
    var agreement = 1.0;
    if (vectors.length >= 2 && matches.isNotEmpty) {
      final id = matches.first.voice.reciterId;
      var same = 0;
      for (final vector in vectors) {
        final top = rankReciters(vector, embeddings, voices, k: 1);
        if (top.isNotEmpty && top.first.voice.reciterId == id) same++;
      }
      agreement = same / vectors.length;
    }
    return (matches: matches, agreement: agreement);
  }

  /// 20-second slices when the take is long enough. A clip of at least
  /// 3 seconds is still scored whole, so a simulator mic is not dropped.
  static List<Float32List> _windows(Float32List samples) {
    const rate = 16000;
    if (samples.length < rate * 3) return const [];
    final win = rate * window.inSeconds;
    if (samples.length < rate * minListen.inSeconds) return [samples];
    final hopN = rate * hop.inSeconds;
    if (samples.length <= win) return [samples];
    final chunks = <Float32List>[];
    var start = 0;
    while (start < samples.length) {
      final end = start + win < samples.length ? start + win : samples.length;
      if (end - start > rate * 15) {
        chunks.add(Float32List.sublistView(samples, start, end));
      }
      if (start + win >= samples.length) break;
      start += hopN;
    }
    return chunks;
  }

  static Float32List _pool(List<Float32List> vectors) {
    final dim = vectors.first.length;
    final mean = Float64List(dim);
    for (final vector in vectors) {
      var norm = 0.0;
      for (final v in vector) {
        norm += v * v;
      }
      norm = math.sqrt(norm);
      if (norm == 0) continue;
      for (var d = 0; d < dim; d++) {
        mean[d] += vector[d] / norm;
      }
    }
    var norm = 0.0;
    for (final v in mean) {
      norm += v * v;
    }
    norm = math.sqrt(norm);
    final out = Float32List(dim);
    if (norm == 0) return out;
    for (var d = 0; d < dim; d++) {
      out[d] = mean[d] / norm;
    }
    return out;
  }

  bool get catalogReady => _voices != null && _voices!.isNotEmpty;

  static Float32List _pcm16ToFloat(Uint8List bytes) {
    final view = ByteData.sublistView(bytes);
    final n = bytes.length ~/ 2;
    final out = Float32List(n);
    for (var i = 0; i < n; i++) {
      out[i] = view.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return out;
  }

  void dispose() {
    _extractor?.free();
    _extractor = null;
    _recorder.dispose();
  }
}

/// Mono 16 kHz PCM from a wav file. Empty when the file is not PCM.
Uint8List pcm16kFromWav(Uint8List bytes) {
  if (bytes.length < 44) return Uint8List(0);
  final data = ByteData.sublistView(bytes);
  if (String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF') return Uint8List(0);
  if (String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') return Uint8List(0);
  var channels = 1;
  var rate = 16000;
  var bits = 16;
  Uint8List? pcm;
  var i = 12;
  while (i + 8 <= bytes.length) {
    final id = String.fromCharCodes(bytes.sublist(i, i + 4));
    final size = data.getUint32(i + 4, Endian.little);
    final body = i + 8;
    if (id == 'fmt ' && body + 16 <= bytes.length) {
      channels = data.getUint16(body + 2, Endian.little);
      rate = data.getUint32(body + 4, Endian.little);
      bits = data.getUint16(body + 14, Endian.little);
    } else if (id == 'data') {
      final end = (body + size).clamp(0, bytes.length);
      pcm = Uint8List.sublistView(bytes, body, end);
      break;
    }
    i = body + size + (size.isOdd ? 1 : 0);
  }
  if (pcm == null || bits != 16 || channels < 1 || rate < 1) {
    return Uint8List(0);
  }
  if (channels > 1) {
    final frames = pcm.length ~/ (2 * channels);
    final mono = Uint8List(frames * 2);
    final src = ByteData.sublistView(pcm);
    final dst = ByteData.sublistView(mono);
    for (var f = 0; f < frames; f++) {
      var sum = 0;
      for (var c = 0; c < channels; c++) {
        sum += src.getInt16((f * channels + c) * 2, Endian.little);
      }
      dst.setInt16(f * 2, sum ~/ channels, Endian.little);
    }
    pcm = mono;
  }
  if (rate == 16000) return pcm;
  final src = ByteData.sublistView(pcm);
  final n = pcm.length ~/ 2;
  final outN = (n * 16000 / rate).floor();
  final out = Uint8List(outN * 2);
  final dst = ByteData.sublistView(out);
  for (var i = 0; i < outN; i++) {
    final at = i * rate / 16000;
    final i0 = at.floor().clamp(0, n - 1);
    final i1 = (i0 + 1).clamp(0, n - 1);
    final t = at - i0;
    final s0 = src.getInt16(i0 * 2, Endian.little);
    final s1 = src.getInt16(i1 * 2, Endian.little);
    dst.setInt16(
      i * 2,
      (s0 + (s1 - s0) * t).round().clamp(-32768, 32767).toInt(),
      Endian.little,
    );
  }
  return out;
}

class ListenCapture {
  ListenCapture({
    required this.matches,
    required this.pcm,
    this.agreement = 1,
    this.denied = false,
  });

  static final _emptyPcm = Uint8List(0);

  final List<ReciterMatch> matches;

  /// Share of windows that named the same reciter as the pooled vector.
  final double agreement;

  /// Little-endian mono 16 kHz PCM from the same take.
  final Uint8List pcm;

  /// Microphone permission was denied. [matches] and [pcm] are empty.
  final bool denied;
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
