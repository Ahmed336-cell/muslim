import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../data.dart';
import 'islamic_api.dart' show ApiException;

/// Verse-by-verse recitations on cdn.islamic.network (alquran.cloud audio
/// editions); bitrates differ per reciter.
enum AyahReciter {
  alafasy('ar.alafasy', 128, 'مشاري العفاسي', 'Mishary Alafasy', 123),
  husary(
    'ar.husary',
    128,
    'محمود خليل الحصري',
    'Mahmoud Khalil Al-Husary',
    118,
  ),
  husaryMujawwad(
    'ar.husarymujawwad',
    128,
    'الحصري (مجوّد)',
    'Al-Husary (Mujawwad)',
    118,
  ),
  abdulBasit('ar.abdulsamad', 64, 'عبد الباسط عبد الصمد', 'Abdul Basit', 51),
  sudais('ar.abdurrahmaansudais', 192, 'عبد الرحمن السديس', 'As-Sudais', 54),
  shuraym('ar.saoodshuraym', 64, 'سعود الشريم', 'Saud Ash-Shuraym', 31),
  muaiqly('ar.mahermuaiqly', 128, 'ماهر المعيقلي', 'Maher Al-Muaiqly', 102),
  ajamy('ar.ahmedajamy', 128, 'أحمد العجمي', 'Ahmed Al-Ajamy', 5),
  shaatree('ar.shaatree', 128, 'أبو بكر الشاطري', 'Abu Bakr Ash-Shatri', 4),
  basfar('ar.abdullahbasfar', 192, 'عبد الله بصفر', 'Abdullah Basfar', 60),
  hudhaify('ar.hudhaify', 128, 'علي الحذيفي', 'Ali Al-Hudhaify', 74),
  ayyoub('ar.muhammadayyoub', 128, 'محمد أيوب', 'Muhammad Ayyub', 109),
  jibreel('ar.muhammadjibreel', 128, 'محمد جبريل', 'Muhammad Jibreel', 111),
  rifai('ar.hanirifai', 192, 'هاني الرفاعي', 'Hani Ar-Rifai', 89);

  const AyahReciter(
    this.id,
    this.bitrate,
    this.arabic,
    this.english,
    this.mp3quranId,
  );

  final String id;
  final int bitrate;
  final String arabic;
  final String english;

  /// The same reciter in the mp3quran catalogue.
  final int mp3quranId;

  String label(String language) => language == 'ar' ? arabic : english;

  Uri ayahUrl(int surah, int ayah) => Uri.https(
    'cdn.islamic.network',
    '/quran/audio/$bitrate/$id/${globalAyah(surah, ayah)}.mp3',
  );

  static AyahReciter byId(String? id) =>
      values.firstWhere((r) => r.id == id, orElse: () => alafasy);
}

final _surahStarts = () {
  final starts = <int>[0];
  for (final s in surahs) {
    starts.add(starts.last + s.ayahs);
  }
  return starts;
}();

/// 1…6236 across the whole Quran.
int globalAyah(int surah, int ayah) => _surahStarts[surah - 1] + ayah;

/// mp3quran ids shown under "Popular", most-listened first.
const popularReciters = [123, 51, 118, 112, 102, 92, 30, 31, 178, 5, 4, 86];

/// A full-surah reciter from mp3quran.net.
class Reciter {
  const Reciter({
    required this.id,
    required this.name,
    required this.recordings,
  });

  final int id;
  final String name;

  /// One per riwaya / style the reciter recorded.
  final List<Recording> recordings;

  /// Hafs first, as most readers expect, then the most complete.
  factory Reciter.fromJson(Map<String, dynamic> m) => Reciter(
    id: m['id'] as int,
    name: '${m['name']}'.trim(),
    recordings:
        [
            for (final r in m['moshaf'] as List? ?? const [])
              Recording.fromJson(r as Map<String, dynamic>),
          ]
          ..removeWhere((r) => r.surahs.isEmpty)
          ..sort((a, b) {
            if (a.isHafs != b.isHafs) return a.isHafs ? -1 : 1;
            return b.surahs.length.compareTo(a.surahs.length);
          }),
  );
}

class Recording {
  const Recording({
    required this.id,
    required this.name,
    required this.server,
    required this.surahs,
  });

  final int id;

  /// Riwaya and style, e.g. "حفص عن عاصم - مرتل".
  final String name;
  final String server;
  final List<int> surahs;

  bool get isHafs =>
      name.contains('حفص') || name.toLowerCase().contains('hafs');

  Uri surahUrl(int surah) =>
      Uri.parse('$server${'$surah'.padLeft(3, '0')}.mp3');

  factory Recording.fromJson(Map<String, dynamic> m) {
    var server = '${m['server']}';
    if (!server.endsWith('/')) server = '$server/';
    return Recording(
      id: m['id'] as int,
      name: '${m['name']}'.trim(),
      server: server,
      surahs: [
        for (final s in '${m['surah_list'] ?? ''}'.split(','))
          if (int.tryParse(s.trim()) case final n? when n >= 1 && n <= 114) n,
      ]..sort(),
    );
  }
}

/// Reciter catalogue from mp3quran.net; names follow the app language.
class RecitersApi {
  RecitersApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final _cache = <String, List<Reciter>>{};

  Future<List<Reciter>> fetch(String language) async {
    final cached = _cache[language];
    if (cached != null) return cached;
    final http.Response res;
    try {
      res = await _client
          .get(
            Uri.https('www.mp3quran.net', '/api/v3/reciters', {
              'language': language == 'ar' ? 'ar' : 'eng',
            }),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw const ApiException(ApiException.network);
    }
    if (res.statusCode != 200) {
      throw const ApiException(ApiException.badResponse);
    }
    try {
      final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map;
      final list = [
        for (final r in json['reciters'] as List)
          Reciter.fromJson(r as Map<String, dynamic>),
      ]..removeWhere((r) => r.recordings.isEmpty);
      list.sort((a, b) => a.name.compareTo(b.name));
      return _cache[language] = list;
    } catch (_) {
      throw const ApiException(ApiException.badResponse);
    }
  }
}

/// Surah files saved for offline listening; replaced by a fake in tests.
class AudioStore {
  AudioStore({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  Directory? _dir;

  Future<Directory> _root() async => _dir ??= Directory(
    '${(await getApplicationSupportDirectory()).path}/recitations',
  );

  Future<File> _file(int recording, int surah) async =>
      File('${(await _root()).path}/$recording/$surah.mp3');

  /// Keys are `(recording, surah)`.
  Future<Set<(int, int)>> saved() async {
    final root = await _root();
    if (!await root.exists()) return {};
    final found = <(int, int)>{};
    await for (final f in root.list(recursive: true)) {
      final parts = f.path.split('/');
      if (parts.length < 2 || !parts.last.endsWith('.mp3')) continue;
      final rec = int.tryParse(parts[parts.length - 2]);
      final surah = int.tryParse(parts.last.replaceAll('.mp3', ''));
      if (rec != null && surah != null) found.add((rec, surah));
    }
    return found;
  }

  Future<Uri?> local(int recording, int surah) async {
    final f = await _file(recording, surah);
    return await f.exists() ? f.uri : null;
  }

  /// Downloads to a temp file first so a cut-off download never plays.
  Future<void> download(
    int recording,
    int surah,
    Uri url, {
    void Function(double progress)? onProgress,
  }) async {
    final file = await _file(recording, surah);
    await file.parent.create(recursive: true);
    final part = File('${file.path}.part');
    final http.StreamedResponse res;
    try {
      res = await _client.send(http.Request('GET', url));
    } catch (_) {
      throw const ApiException(ApiException.network);
    }
    if (res.statusCode != 200) {
      throw const ApiException(ApiException.badResponse);
    }
    final total = res.contentLength ?? 0;
    var received = 0;
    final sink = part.openWrite();
    try {
      await for (final chunk in res.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
      await sink.close();
      await part.rename(file.path);
    } catch (_) {
      await sink.close();
      if (await part.exists()) await part.delete();
      throw const ApiException(ApiException.network);
    }
  }

  Future<void> delete(int recording, int surah) async {
    final f = await _file(recording, surah);
    if (await f.exists()) await f.delete();
  }
}
