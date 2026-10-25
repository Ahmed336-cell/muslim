import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslim/bloc/quran/mushaf_cubit.dart';
import 'package:muslim/services/mushaf_pages.dart';
import 'package:muslim/services/quran.dart';
import 'package:muslim/services/quran_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final text = QuranText();

  test('every script covers all 604 pages', () async {
    for (final mushaf in Mushaf.values) {
      final first = await text.page(1, mushaf);
      expect(first.ayahs.length, 7);
      expect(first.ayahs.first.surah, 1);
      final last = await text.page(pageCount, mushaf);
      expect((last.ayahs.last.surah, last.ayahs.last.number), (114, 6));
      for (var p = 1; p <= pageCount; p++) {
        final page = await text.page(p, mushaf);
        final a = page.ayahs.first;
        expect((a.surah, a.number), pageStarts[p - 1], reason: '$mushaf $p');
        expect(page.ayahs.every((a) => a.page == p), isTrue);
      }
    }
  });

  test('bismillah is stripped and metadata kept', () async {
    final baqarah = await text.ayah(2, 1, Mushaf.uthmani);
    expect(baqarah.text.contains('بِسْمِ'), isFalse);
    expect(baqarah.text, isNotEmpty);
    final fatiha = await text.ayah(1, 1, Mushaf.uthmani);
    expect(fatiha.text, startsWith('بِسْمِ'));
    final iqra = await text.ayah(96, 19, Mushaf.simple);
    expect(iqra.sajda, isTrue);
    expect(iqra.juz, 30);
    final tajweed = await text.ayah(2, 2, Mushaf.tajweed);
    expect(tajweed.text, contains('['));
  });

  test('QuranApi reads the bundle with no network', () async {
    var calls = 0;
    final api = QuranApi(
      client: MockClient((_) async {
        calls++;
        throw http.ClientException('offline');
      }),
      text: QuranText(),
    );
    final page = await api.fetchPage(50, Mushaf.uthmani);
    expect(page.ayahs, isNotEmpty);
    final ayah = await api.fetchAyah(3, 1, Mushaf.plain);
    expect(ayah.surah, 3);
    expect(calls, 0);
  });

  test('preloaded pages show without a loading state', () async {
    final api = QuranApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
      text: QuranText(),
    );
    await api.preload(Mushaf.uthmani);
    final cubit = MushafCubit(api: api, mushaf: Mushaf.uthmani);
    cubit.visit(10);
    expect(cubit.state.pages[10]?.page?.number, 10);
    expect(cubit.state.pages[11]?.page, isNotNull);
    expect(cubit.state.pages[9]?.page, isNotNull);
    await cubit.close();
  });

  test('search ignores diacritics and spelling variants', () async {
    final kursi = await text.search(
      'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    );
    expect(
      kursi.matches.map((m) => '${m.ayah.surah}:${m.ayah.number}'),
      containsAll(['2:255', '3:2']),
    );
    final m = kursi.matches.first;
    expect(
      m.ayah.text.substring(m.start, m.start + m.length),
      startsWith('الله'),
    );

    final rahman = await text.search('الرحمن');
    expect(rahman.total, greaterThan(40));
    expect(rahman.matches.length, lessThanOrEqualTo(100));

    expect((await text.search('ا')).total, 0);
    expect((await text.search('zzzz')).total, 0);
  });

  test('locate picks ayat al-kursi from a spoken phrase', () async {
    final ayah = await text.locate(
      'الله لا اله الا هو الحي القيوم، لا تاخذه سنه ولا نوم.',
    );
    expect(ayah?.surah, 2);
    expect(ayah?.number, 255);
  });

  test('locate ignores a fragment that is too short', () async {
    expect(await text.locate('الله'), isNull);
  });
}
