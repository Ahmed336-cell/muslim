import 'dart:convert';

import 'package:http/http.dart' as http;

/// One prophetic-praise track on Archive.org.
class TawashihTrack {
  const TawashihTrack({
    required this.id,
    required this.file,
    required this.titleAr,
    required this.titleEn,
  });

  final String id;
  final String file;
  final String titleAr;
  final String titleEn;

  String title(String language) => language == 'ar' ? titleAr : titleEn;
}

/// A munshid / collection, like a Quran [Reciter].
class TawashihMunshid {
  const TawashihMunshid({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.archiveId,
    this.nameContains,
    this.curated,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  /// Archive.org item identifier.
  final String archiveId;

  /// Keep only files whose name contains one of these (Arabic collections).
  final List<String>? nameContains;

  /// When set, skip the network catalogue and use these tracks.
  final List<TawashihTrack>? curated;

  String name(String language) => language == 'ar' ? nameAr : nameEn;

  Uri urlFor(TawashihTrack t) => Uri.parse(
    'https://archive.org/download/$archiveId/'
    '${t.file.split('/').map(Uri.encodeComponent).join('/')}',
  );
}

/// Shown under "Popular", most-loved first.
const popularTawashih = ['naqshbandi', 'bahtimi', 'classic', 'samkari'];

/// Curated titles for the classic `Tawashih` item (English filenames).
const _classicTitles = <String, (String, String)>{
  'المولد.mp3': ('المولد', 'Al-Mawlid'),
  '01.mp3': ('يا محمد يا مؤيد طه', 'Ya Muhammad, O supported Taha'),
  '02.mp3': ('نور عيني طه الحبيب', 'Light of my eyes, beloved Taha'),
  '03.mp3': ('ولد الهدى', 'The Guide was born'),
  '04.mp3': ('ولد الهدى فالكائنات ضياء', 'The Guide was born and creation shone'),
  '05.mp3': ('يا طه ما أنساك', 'O Taha, I never forget you'),
  'AlAnwar.mp3': ('زهت وتسامت الأنوار', 'The lights rose and shone'),
  'AlHady.mp3': ('الهدى', 'Al-Hady'),
  'AlMawled.mp3': ('المولد', 'Al-Mawled'),
  'Almonady.mp3': ('المنادي', 'Al-Munadi'),
  'Amena.mp3': ('آمنة', 'Aminah'),
  'Anwar.mp3': ('أنوار', 'Lights'),
  'Emam.mp3': ('إمام الرسل', 'Imam of the messengers'),
  'Fagr.mp3': ('الفجر', 'Fajr'),
  'Listen.mp3': ('استمع', 'Listen'),
  'Makka.mp3': ('هبط الليل والنور بمكة', 'Night and light in Makkah'),
  'Mawled.mp3': ('يا مولد الرسول', 'O birth of the Messenger'),
  'Mohamdyon.mp3': ('محمديون', 'Muhammadiyyun'),
  'Mohamed.mp3': ('محمد يا رسول الله', 'Muhammad, O Messenger of Allah'),
  'Naoh.mp3': ('نوح', 'Nuh'),
  'Nour.mp3': ('نور', 'Light'),
  'Rasoul.mp3': ('يا رسول الله', 'O Messenger of Allah'),
  'RasoulAlhoda.mp3': ('رسول الهدى', 'Messenger of guidance'),
  'RasoulAllah.mp3': ('رسول الله', 'Messenger of Allah'),
  'Salah.mp3': ('الصلاة على النبي الإمام', 'Prayers on the Prophet, the Imam'),
  'Saly.mp3': ('صلى الله على محمد', 'May Allah send prayers on Muhammad'),
  'Sanltqi.mp3': ('سنلتقي', 'We shall meet'),
  'Saydna.mp3': ('محمدنا هو سيدنا', 'Our Muhammad is our master'),
  'Shafa3a.mp3': ('منك الشفاعة ترتجى', 'From you intercession is hoped'),
  'Sun.mp3': ('شمس', 'Sun'),
  'Taha.mp3': ('طه يا خير الخلائق', 'Taha, best of creation'),
  'Tayeb.mp3': ('طيب', 'Tayyib'),
  'Wled.mp3': ('ولد', 'Born'),
};

/// Munshids available in the app (Archive.org).
const tawashihMunshids = <TawashihMunshid>[
  TawashihMunshid(
    id: 'naqshbandi',
    nameAr: 'السيد النقشبندي',
    nameEn: 'Sayed al-Naqshbandi',
    archiveId: 'Naqshabandee',
  ),
  TawashihMunshid(
    id: 'classic',
    nameAr: 'تواشيح كلاسيكية',
    nameEn: 'Classic tawashih',
    archiveId: 'Tawashih',
  ),
  TawashihMunshid(
    id: 'bahtimi',
    nameAr: 'كامل يوسف البهتيمي',
    nameEn: 'Kamil Yusuf al-Bahtimi',
    archiveId: '2071215',
    nameContains: ['البهتيمي', 'بهتيم'],
  ),
  TawashihMunshid(
    id: 'samkari',
    nameAr: 'إسماعيل السمكري',
    nameEn: 'Ismail al-Samkari',
    archiveId: '2071215',
    nameContains: ['السمكر', 'سمكر'],
  ),
  TawashihMunshid(
    id: 'toukhi',
    nameAr: 'محمد الطوخي',
    nameEn: 'Muhammad al-Toukhi',
    archiveId: '2071215',
    nameContains: ['الطوخ', 'طوخ'],
  ),
  TawashihMunshid(
    id: 'omran',
    nameAr: 'محمد عمران',
    nameEn: 'Muhammad Omran',
    archiveId: '2071215',
    nameContains: ['عمران'],
  ),
  TawashihMunshid(
    id: 'tobar',
    nameAr: 'نصر الدين طوبار',
    nameEn: 'Nasr al-Din Tobar',
    archiveId: '2071215',
    nameContains: ['طوبار'],
  ),
  TawashihMunshid(
    id: 'halbawi',
    nameAr: 'محمد الهلباوي',
    nameEn: 'Muhammad al-Halbawi',
    archiveId: '2071215',
    nameContains: ['الهلب', 'هلب'],
  ),
];

TawashihMunshid? tawashihById(String id) =>
    tawashihMunshids.where((m) => m.id == id).firstOrNull;

/// Stable negative id for [DownloadsCubit] / [RecitationCubit.recording],
/// so it never clashes with mp3quran recording ids.
int tawashihRecordingId(String munshidId) {
  var h = 0;
  for (final c in munshidId.codeUnits) {
    h = (h * 31 + c) & 0x3fffffff;
  }
  return -1 - h;
}

/// Loads track lists from Archive.org metadata (cached per item).
class TawashihApi {
  TawashihApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final _cache = <String, List<String>>{};

  Future<List<TawashihTrack>> tracks(TawashihMunshid munshid) async {
    if (munshid.curated case final curated?) return curated;

    final files = await _mp3Files(munshid.archiveId);
    var picked = files;
    if (munshid.nameContains case final keys?) {
      picked = [
        for (final f in files)
          if (keys.any(f.contains)) f,
      ];
    }

    final out = <TawashihTrack>[
      for (final f in picked) _trackFor(munshid, f),
    ];
    out.sort(
      (a, b) => a.titleAr.toLowerCase().compareTo(b.titleAr.toLowerCase()),
    );
    return out;
  }

  TawashihTrack _trackFor(TawashihMunshid m, String file) {
    if (m.archiveId == 'Tawashih') {
      if (_classicTitles[file] case final t?) {
        return TawashihTrack(
          id: file,
          file: file,
          titleAr: t.$1,
          titleEn: t.$2,
        );
      }
    }
    final label = _label(file);
    return TawashihTrack(id: file, file: file, titleAr: label, titleEn: label);
  }

  Future<List<String>> _mp3Files(String archiveId) async {
    final hit = _cache[archiveId];
    if (hit != null) return hit;
    final uri = Uri.https('archive.org', '/metadata/$archiveId');
    final res = await _client.get(uri).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw StateError('Archive metadata ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final files = [
      for (final f in body['files'] as List? ?? const [])
        if (f is Map && '${f['name']}'.toLowerCase().endsWith('.mp3'))
          '${f['name']}',
    ];
    return _cache[archiveId] = files;
  }

  static String _label(String file) => tawashihFileLabel(file);
}

/// Display title for an Archive.org mp3 filename.
String tawashihFileLabel(String file) {
  final classic = _classicTitles[file];
  if (classic != null) return classic.$1;
  var s = file.replaceAll(RegExp(r'\.mp3$', caseSensitive: false), '');
  s = s.replaceAll('_', ' ');
  s = s.replaceFirst(RegExp(r'^\d+\s*[-–.]?\s*'), '');
  s = s.replaceAll(RegExp(r'\s*[-–_]{2,}\s*'), ' — ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  final sheikh = RegExp(r'^(.+?)\s+[_\-–]\s*الشيخ').firstMatch(s);
  if (sheikh != null) s = sheikh.group(1)!.trim();
  return s.isEmpty ? file : s;
}

String tawashihFileTitle(String file, String language) {
  final classic = _classicTitles[file];
  if (classic != null) return language == 'ar' ? classic.$1 : classic.$2;
  return tawashihFileLabel(file);
}

/// Flat list kept for older call sites / tests.
List<TawashihTrack> get tawashihTracks => [
  for (final e in _classicTitles.entries)
    TawashihTrack(
      id: e.key,
      file: e.key,
      titleAr: e.value.$1,
      titleEn: e.value.$2,
    ),
];
