import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../data.dart';
import 'islamic_api.dart' show ApiException;

/// Verse-by-verse recitations. The first set is on cdn.islamic.network.
/// [folder] voices are everyayah.com, one file per ayah, no page cap.
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
  husaryMuallim(
    'ea.husarymuallim',
    128,
    'الحصري (معلم)',
    'Al-Husary (Muallim)',
    118,
    'Husary_Muallim_128kbps',
  ),
  minshawi(
    'ar.minshawi',
    128,
    'محمد صديق المنشاوي',
    'Muhammad Siddiq Al-Minshawi',
    112,
  ),
  minshawiMujawwad(
    'ea.minshawimujawwad',
    192,
    'المنشاوي (مجوّد)',
    'Al-Minshawi (Mujawwad)',
    112,
    'Minshawy_Mujawwad_192kbps',
  ),
  abdulBasit('ar.abdulsamad', 64, 'عبد الباسط عبد الصمد', 'Abdul Basit', 51),
  abdulBasitMujawwad(
    'ea.abdulbasitmujawwad',
    128,
    'عبد الباسط (مجوّد)',
    'Abdul Basit (Mujawwad)',
    51,
    'Abdul_Basit_Mujawwad_128kbps',
  ),
  sudais('ar.abdurrahmaansudais', 192, 'عبد الرحمن السديس', 'As-Sudais', 54),
  shuraym('ar.saoodshuraym', 64, 'سعود الشريم', 'Saud Ash-Shuraym', 31),
  muaiqly('ar.mahermuaiqly', 128, 'ماهر المعيقلي', 'Maher Al-Muaiqly', 102),
  ajamy('ar.ahmedajamy', 128, 'أحمد العجمي', 'Ahmed Al-Ajamy', 5),
  shaatree('ar.shaatree', 128, 'أبو بكر الشاطري', 'Abu Bakr Ash-Shatri', 4),
  basfar('ar.abdullahbasfar', 192, 'عبد الله بصفر', 'Abdullah Basfar', 60),
  hudhaify('ar.hudhaify', 128, 'علي الحذيفي', 'Ali Al-Hudhaify', 74),
  ayyoub('ar.muhammadayyoub', 128, 'محمد أيوب', 'Muhammad Ayyub', 109),
  jibreel('ar.muhammadjibreel', 128, 'محمد جبريل', 'Muhammad Jibreel', 111),
  rifai('ar.hanirifai', 192, 'هاني الرفاعي', 'Hani Ar-Rifai', 89),
  dossari(
    'ea.dossari',
    128,
    'ياسر الدوسري',
    'Yasser Al-Dosari',
    92,
    'Yasser_Ad-Dussary_128kbps',
  ),
  ghamdi(
    'ea.ghamdi',
    40,
    'سعد الغامدي',
    'Saad Al-Ghamdi',
    30,
    'Ghamadi_40kbps',
  ),
  budair(
    'ea.budair',
    128,
    'صلاح البدير',
    'Salah Al-Budair',
    43,
    'Salah_Al_Budair_128kbps',
  ),
  qasim(
    'ea.qasim',
    192,
    'محسن القاسم',
    'Muhsin Al-Qasim',
    67,
    'Muhsin_Al_Qasim_192kbps',
  ),
  juhani(
    'ea.juhani',
    128,
    'عبد الله الجهني',
    'Abdullah Al-Juhani',
    62,
    'Abdullaah_3awwaad_Al-Juhaynee_128kbps',
  ),
  qahtani(
    'ea.qahtani',
    192,
    'خالد القحطاني',
    'Khalid Al-Qahtani',
    21,
    'Khaalid_Abdullaah_al-Qahtaanee_192kbps',
  ),
  qatami(
    'ea.qatami',
    128,
    'ناصر القطامي',
    'Nasser Al-Qatami',
    86,
    'Nasser_Alqatami_128kbps',
  ),
  bukhatir(
    'ea.bukhatir',
    128,
    'صلاح بو خاطر',
    'Salah Bukhatir',
    46,
    'Salaah_AbdulRahman_Bukhatir_128kbps',
  ),
  suwaid(
    'ea.suwaid',
    64,
    'أيمن سويد',
    'Ayman Suwaid',
    21203,
    'Ayman_Sowaid_64kbps',
  ),
  akhdar(
    'ea.akhdar',
    32,
    'إبراهيم الأخضر',
    'Ibrahim Al-Akhdar',
    1,
    'Ibrahim_Akhdar_32kbps',
  ),
  tablawi(
    'ea.tablawi',
    128,
    'محمد الطبلاوي',
    'Muhammad Al-Tablawi',
    106,
    'Mohammad_al_Tablaway_128kbps',
  ),
  mustafaIsmail(
    'ea.mustafaismail',
    48,
    'مصطفى إسماعيل',
    'Mustafa Ismail',
    125,
    'Mustafa_Ismail_48kbps',
  ),
  albanna(
    'ea.albanna',
    32,
    'محمود علي البنا',
    'Mahmoud Ali Al-Banna',
    121,
    'mahmoud_ali_al_banna_32kbps',
  ),
  tunaiji(
    'ea.tunaiji',
    64,
    'خليفة الطنيجي',
    'Khalifa Al-Tunaiji',
    24,
    'khalefa_al_tunaiji_64kbps',
  ),
  suwaisi(
    'ea.suwaisi',
    128,
    'علي حجاج السويسي',
    'Ali Hajjaj Al-Suwaisi',
    77,
    'Ali_Hajjaj_AlSuesy_128kbps',
  ),
  yassin(
    'ea.yassin',
    128,
    'سهل ياسين',
    'Sahl Yassin',
    32,
    'Sahl_Yassin_128kbps',
  ),
  jaber('ea.jaber', 64, 'علي جابر', 'Ali Jaber', 76, 'Ali_Jaber_64kbps'),
  abbad('ea.abbad', 64, 'فارس عباد', 'Fares Abbad', 81, 'Fares_Abbad_64kbps'),
  matrood(
    'ea.matrood',
    128,
    'عبد الله المطرود',
    'Abdullah Al-Matrood',
    59,
    'Abdullah_Matroud_128kbps',
  ),
  abdulKareem(
    'ea.abdulkareem',
    128,
    'محمد عبدالكريم',
    'Muhammad Abdul Kareem',
    115,
    'Muhammad_AbdulKareem_128kbps',
  ),
  alili('ea.alili', 128, 'عزيز عليلي', 'Aziz Alili', null, 'aziz_alili_128kbps'),
  neana(
    'ea.neana',
    128,
    'أحمد نعينع',
    'Ahmed Neana',
    null,
    'Ahmed_Neana_128kbps',
  ),
  parhizgar(
    'ea.parhizgar',
    48,
    'شهريار پرهیزگار',
    'Shahriar Parhizgar',
    null,
    'Parhizgar_48kbps',
  );

  const AyahReciter(
    this.id,
    this.bitrate,
    this.arabic,
    this.english,
    this.mp3quranId, [
    this.folder,
  ]);

  final String id;
  final int bitrate;
  final String arabic;
  final String english;

  /// The same reciter in the mp3quran catalogue, when one exists.
  final int? mp3quranId;

  /// everyayah.com folder. Null means [id] is an islamic.network edition.
  final String? folder;

  String label(String language) => language == 'ar' ? arabic : english;

  Uri ayahUrl(int surah, int ayah) {
    final folder = this.folder;
    if (folder != null) {
      final file =
          '${surah.toString().padLeft(3, '0')}${ayah.toString().padLeft(3, '0')}.mp3';
      return Uri.https('everyayah.com', '/data/$folder/$file');
    }
    return Uri.https(
      'cdn.islamic.network',
      '/quran/audio/$bitrate/$id/${globalAyah(surah, ayah)}.mp3',
    );
  }

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

  /// Where [ayah] begins in this recording's surah file, from mp3quran.
  /// Null when that recording has no timing.
  Future<Duration?> ayahOffset(int recordingId, int surah, int ayah) async {
    final http.Response res;
    try {
      res = await _client
          .get(
            Uri.https('www.mp3quran.net', '/api/v3/ayat_timing', {
              'surah': '$surah',
              'read': '$recordingId',
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    }
    if (res.statusCode != 200) return null;
    try {
      return ayahOffsetFromJson(jsonDecode(utf8.decode(res.bodyBytes)), ayah);
    } catch (_) {
      return null;
    }
  }

  /// Every ayah start in this recording's surah file. Empty when the
  /// recording has no timing.
  Future<List<({int ayah, Duration start, Duration end})>> ayahTimings(
    int recordingId,
    int surah,
  ) async {
    final http.Response res;
    try {
      res = await _client
          .get(
            Uri.https('www.mp3quran.net', '/api/v3/ayat_timing', {
              'surah': '$surah',
              'read': '$recordingId',
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return const [];
    }
    if (res.statusCode != 200) return const [];
    try {
      return ayahTimingsFromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    } catch (_) {
      return const [];
    }
  }
}

/// [start_time] for [ayah] in an `ayat_timing` payload, in milliseconds.
Duration? ayahOffsetFromJson(Object? json, int ayah) {
  if (json is! List) return null;
  for (final row in json) {
    if (row is! Map || row['ayah'] != ayah) continue;
    final ms = row['start_time'];
    if (ms is num && ms >= 0) return Duration(milliseconds: ms.round());
  }
  return null;
}

/// Ayah start and end times from an `ayat_timing` payload, earliest first.
/// Ayah 0 is the opening basmala and is left out.
List<({int ayah, Duration start, Duration end})> ayahTimingsFromJson(
  Object? json,
) {
  if (json is! List) return const [];
  final out = <({int ayah, Duration start, Duration end})>[];
  for (final row in json) {
    if (row is! Map) continue;
    final ayah = row['ayah'];
    final ms = row['start_time'];
    final endMs = row['end_time'];
    final n = ayah is int
        ? ayah
        : ayah is num
        ? ayah.round()
        : null;
    if (n == null || n < 1 || ms is! num || ms < 0) continue;
    final start = Duration(milliseconds: ms.round());
    final end = endMs is num ? Duration(milliseconds: endMs.round()) : start;
    out.add((ayah: n, start: start, end: end));
  }
  out.sort((a, b) => a.start.compareTo(b.start));
  return out;
}

/// Where [position] sits on the timing map.
///
/// A file that is shorter than the stamps runs ahead of them. Stretch the
/// playhead onto the stamp timeline so the verse changes with the voice.
Duration timingAt(Duration position, Duration audio, Duration timingEnd) {
  // Only when the file is shorter than the stamps. A longer file is left
  // on the playhead clock.
  if (audio < const Duration(seconds: 1) ||
      timingEnd < const Duration(seconds: 1) ||
      audio >= timingEnd) {
    return position;
  }
  return Duration(
    microseconds:
        position.inMicroseconds *
        timingEnd.inMicroseconds ~/
        audio.inMicroseconds,
  );
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
