import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

import 'player.dart';

/// On-device recitation recognition: tarteel-ai/whisper-base-ar-quran,
/// int8 ggml, run by whisper.cpp. The model is downloaded on first use.
class ReciteEngine {
  ReciteEngine({http.Client? client}) : _client = client ?? http.Client();

  static final modelUrl = Uri.parse(
    'https://huggingface.co/sadrapp/whisper-base-ar-quran-ggml/resolve/'
    'fa7a13981ff68f2a1af37a33e2c35e1238d922d5/ggml-model-q8_0.bin',
  );
  static const modelSha256 =
      '72194195f7d280adebec57acf2c6e01e209484322ec1cec21c275a3c0b1e3d77';
  static const modelBytes = 81768585;

  final http.Client _client;
  late final _recorder = AudioRecorder();
  String? _dir;
  bool _loaded = false;
  bool _warmed = false;
  Future<void>? _warming;
  WhisperLiveSession? _session;
  StreamSubscription<Uint8List>? _mic;
  final _pcm = BytesBuilder(copy: false);

  Future<String> _path(String name) async {
    _dir ??= (await getApplicationSupportDirectory()).path;
    return '$_dir/$name';
  }

  Future<String> get _modelPath => _path('ggml-whisper-base-ar-quran-q8.bin');

  Future<bool> hasModel() async => File(await _modelPath).exists();

  /// Throws on network failure or a corrupt download.
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

  /// Starts listening; the stream carries the transcript so far while the
  /// reciter speaks. Null when the microphone permission is denied.
  Future<Stream<String>?> start() async {
    if (!await _recorder.hasPermission()) return null;
    _loaded = true;
    final session = await startWhisperLiveSession(
      modelPath: await _modelPath,
      lang: 'ar',
      suppressNonSpeechTokens: true,
      keepModelLoaded: true,
    );
    final audio = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
    _pcm.clear();
    _mic = audio.listen((chunk) {
      _pcm.add(chunk);
      session.feed(chunk);
    });
    _session = session;
    return session.partials;
  }

  Future<void> _stopListening() async {
    await _recorder.stop();
    await _mic?.cancel();
    _mic = null;
    await usePlaybackSession();
  }

  Future<void> cancel() async {
    await _stopListening();
    await _session?.stop();
    _session = null;
  }

  /// Load Whisper into RAM during mic capture so ayah detect skips the
  /// multi-second cold start that makes Android feel stuck.
  Future<void> warmModel() {
    if (_warmed) return Future.value();
    return _warming ??= _warm();
  }

  Future<void> _warm() async {
    try {
      if (!await hasModel()) return;
      // 0.25 s of silence — enough to park the model, tiny to decode.
      final silence = Uint8List(16000 * 2 ~/ 4);
      final wav = File(await _path('warm.wav'));
      await _writeWav(wav, silence);
      await _transcribeFile(wav.path, timeout: const Duration(seconds: 60));
      _warmed = true;
    } catch (error, stack) {
      debugPrint('whisper warm: $error\n$stack');
    } finally {
      _warming = null;
    }
  }

  /// Transcript of a 16 kHz mono PCM clip already on hand.
  ///
  /// [maxSeconds] keeps only the start of the clip so ayah locate stays
  /// quick on phones. [timeout] stops a hang (common on Android when RAM
  /// is tight after the speaker model).
  Future<String> transcribePcm(
    Uint8List pcm, {
    int? maxSeconds,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    if (pcm.length < 16000 || !await hasModel()) return '';
    await warmModel();
    final clip = maxSeconds == null
        ? pcm
        : Uint8List.sublistView(
            pcm,
            0,
            math.min(pcm.length, 16000 * 2 * maxSeconds),
          );
    if (clip.length < 16000) return '';
    try {
      final wav = File(await _path('identify.wav'));
      await _writeWav(wav, clip);
      return (await _transcribeFile(wav.path, timeout: timeout)).trim();
    } catch (error, stack) {
      debugPrint('whisper pcm: $error\n$stack');
      return '';
    }
  }

  Future<String> _transcribeFile(
    String audioPath, {
    required Duration timeout,
  }) async {
    _loaded = true;
    final response = await const Whisper(model: WhisperModel.base)
        .transcribe(
          transcribeRequest: TranscribeRequest(
            audio: audioPath,
            language: 'ar',
            threads: _threads,
            isNoTimestamps: true,
            noContext: true,
            maxContext: 0,
            suppressNonSpeechTokens: true,
            keepModelLoaded: true,
          ),
          modelPath: await _modelPath,
        )
        .timeout(timeout);
    _warmed = true;
    return response.text;
  }

  /// Stops listening and returns the transcript. The whole recording is
  /// transcribed again in one pass, which is more accurate than the live
  /// text.
  Future<String> finish() async {
    await _stopListening();
    final live = await _session?.stop() ?? '';
    _session = null;
    final pcm = _pcm.takeBytes();
    if (pcm.isEmpty) return live;
    try {
      final wav = File(await _path('recitation.wav'));
      await _writeWav(wav, pcm);
      final text = await _transcribeFile(
        wav.path,
        timeout: const Duration(seconds: 90),
      );
      return text.trim().isEmpty ? live : text;
    } catch (error, stack) {
      debugPrint('whisper finish: $error\n$stack');
      return live;
    }
  }

  /// Android phones thrash with the package default of 6 whisper threads.
  static int get _threads {
    final n = Platform.numberOfProcessors;
    if (Platform.isAndroid) return math.max(1, math.min(n, 2));
    return math.max(1, math.min(n, 4));
  }

  /// Write header + PCM without spreading the clip into a Dart list
  /// (a 30s capture is ~1 MB of ints and can stall low-RAM Androids).
  static Future<void> _writeWav(File wav, Uint8List pcm) async {
    final sink = wav.openWrite();
    try {
      sink
        ..add(_wavHeader(pcm.length))
        ..add(pcm);
    } finally {
      await sink.close();
    }
  }

  static Uint8List _wavHeader(int dataBytes) {
    const rate = 16000, channels = 1, bits = 16;
    final h = ByteData(44);
    void ascii(int at, String s) {
      for (var i = 0; i < 4; i++) {
        h.setUint8(at + i, s.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    h.setUint32(4, 36 + dataBytes, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    h.setUint32(16, 16, Endian.little);
    h.setUint16(20, 1, Endian.little);
    h.setUint16(22, channels, Endian.little);
    h.setUint32(24, rate, Endian.little);
    h.setUint32(28, rate * channels * bits ~/ 8, Endian.little);
    h.setUint16(32, channels * bits ~/ 8, Endian.little);
    h.setUint16(34, bits, Endian.little);
    ascii(36, 'data');
    h.setUint32(40, dataBytes, Endian.little);
    return h.buffer.asUint8List();
  }

  /// Frees the model kept in memory between attempts.
  Future<void> release() async {
    if (!_loaded && !_warmed) return;
    _loaded = false;
    _warmed = false;
    await const Whisper(model: WhisperModel.base).releaseModel();
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
