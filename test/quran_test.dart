import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim/bloc/quran/mushaf_cubit.dart';
import 'package:muslim/bloc/quran/quran_prefs_cubit.dart';
import 'package:muslim/bloc/quran/ambient_cubit.dart';
import 'package:muslim/bloc/quran/khatmah_cubit.dart';
import 'package:muslim/bloc/quran/recent_surahs_cubit.dart';
import 'package:muslim/bloc/quran/recitation_cubit.dart';
import 'package:muslim/bloc/quran/tafsir_cubit.dart';
import 'package:muslim/bloc/quran_bookmark_cubit.dart';
import 'package:muslim/data.dart';
import 'package:muslim/l10n/l10n.dart';
import 'package:muslim/screens/mushaf_screen.dart';
import 'package:muslim/services/islamic_api.dart' show ApiException;
import 'package:muslim/services/mushaf_pages.dart';
import 'package:muslim/services/quran.dart';
import 'package:muslim/widgets/quran_text.dart';

import 'fake_audio.dart';
import 'helpers.dart';

Map<String, dynamic> _ayahJson(int surah, int n, String text, {int page = 1}) =>
    {
      'surah': {'number': surah},
      'numberInSurah': n,
      'text': text,
      'page': page,
      'juz': 1,
      'sajda': false,
    };

/// Page p holds the last two ayahs of surah p and the first two of p + 1.
class _FakeQuranApi extends QuranApi {
  final pageCalls = <(int, Mushaf)>[];
  final tafsirCalls = <(TafsirSource, int, int)>[];

  @override
  Future<MushafPage> fetchPage(int page, Mushaf mushaf) async {
    pageCalls.add((page, mushaf));
    final last = surahs[page - 1].ayahs;
    return MushafPage(
      number: page,
      mushaf: mushaf,
      ayahs: [
        for (final (s, n) in [
          (page, last - 1),
          (page, last),
          (page + 1, 1),
          (page + 1, 2),
        ])
          Ayah(
            surah: s,
            number: n,
            text: '${mushaf.name} $s:$n',
            page: page,
            juz: 1,
          ),
      ],
    );
  }

  @override
  Future<Ayah> fetchAyah(int surah, int ayah, Mushaf mushaf) async => Ayah(
    surah: surah,
    number: ayah,
    text: 'text $surah:$ayah',
    page: 1,
    juz: 1,
  );

  @override
  Future<String> fetchTafsir(TafsirSource source, int surah, int ayah) async {
    tafsirCalls.add((source, surah, ayah));
    if (source == TafsirSource.qurtubi) {
      throw const ApiException(ApiException.network);
    }
    return '${source.name} on $surah:$ayah';
  }
}

void main() {
  group('parsing', () {
    test('strips the bismillah prefix whatever the diacritics', () {
      expect(
        stripBismillah('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الٓمٓ'),
        'الٓمٓ',
      );
      expect(stripBismillah('بسم الله الرحمن الرحيم الم'), 'الم');
      // An-Naml 30 mentions the bismillah mid-ayah: untouched.
      const naml = 'إِنَّهُۥ مِن سُلَيْمَٰنَ وَإِنَّهُۥ بِسْمِ ٱللَّهِ';
      expect(stripBismillah(naml), naml);
    });

    test('ayah 1 loses the bismillah except in al-Fatihah', () {
      const b = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      final baqarah = Ayah.fromJson(_ayahJson(2, 1, '$b الٓمٓ'));
      expect(baqarah.text, 'الٓمٓ');
      expect(baqarah.opensWithBismillah, isTrue);

      final fatihah = Ayah.fromJson(_ayahJson(1, 1, '\ufeff$b'));
      expect(fatihah.text, b);
      expect(fatihah.opensWithBismillah, isFalse);

      expect(
        Ayah.fromJson(_ayahJson(9, 1, 'بَرَآءَةٌ')).opensWithBismillah,
        isFalse,
      );
    });

    test('a page can hold the end of one surah and the start of the next', () {
      final page = MushafPage.fromJson({
        'number': 604,
        'ayahs': [
          _ayahJson(112, 4, 'وَلَمْ يَكُن', page: 604),
          _ayahJson(113, 1, 'بسم الله الرحمن الرحيم قل', page: 604),
        ],
      }, Mushaf.plain);
      expect(page.ayahs.map((a) => (a.surah, a.number, a.text)), [
        (112, 4, 'وَلَمْ يَكُن'),
        (113, 1, 'قل'),
      ]);
    });

    test('finds the page of any ayah', () {
      expect(pageStarts, hasLength(pageCount));
      expect(pageOf(1), 1);
      expect(pageOf(2), 2);
      expect(pageOf(2, 5), 2);
      expect(pageOf(2, 6), 3);
      expect(pageOf(2, 286), 49);
      expect(pageOf(3), 50);
      expect(pageOf(18), 293);
      expect(pageOf(114, 6), 604);
    });

    test('splits tajweed markup into coloured runs', () {
      const text = 'ذ[n[َٲ]لِكَ [h:11[ٱ]لْكِتَ';
      expect(tajweedRuns(text), [
        ('ذ', null),
        ('َٲ', 'n'),
        ('لِكَ ', null),
        ('ٱ', 'h'),
        ('لْكِتَ', null),
      ]);
      expect(stripTajweed(text), 'ذَٲلِكَ ٱلْكِتَ');
    });

    test('turns tafsir HTML into paragraphs', () {
      expect(
        htmlToText('<h2>Title</h2><p>One &amp; two</p><p>Three</p>'),
        'Title\n\nOne & two\n\nThree',
      );
    });
  });

  group('QuranPrefsCubit', () {
    setUp(useMemoryStorage);

    test('tafsir follows the app language until one is picked', () {
      final c = QuranPrefsCubit();
      expect(c.state.tafsirFor('ar'), TafsirSource.muyassar);
      expect(c.state.tafsirFor('en'), TafsirSource.ibnKathir);
      c.setTafsir(TafsirSource.qurtubi);
      expect(c.state.tafsirFor('en'), TafsirSource.qurtubi);
    });

    test('persists mushaf, style, tafsir and a clamped font size', () {
      QuranPrefsCubit()
        ..setMushaf(Mushaf.tajweed)
        ..setStyle(MushafStyle.emerald)
        ..setTafsir(TafsirSource.jalalayn)
        ..setFontSize(99);
      final restored = QuranPrefsCubit().state;
      expect(restored.mushaf, Mushaf.tajweed);
      expect(restored.style, MushafStyle.emerald);
      expect(restored.tafsir, TafsirSource.jalalayn);
      expect(restored.fontSize, QuranPrefs.maxFontSize);
      expect(
        QuranPrefsCubit().fromJson({'mushaf': 'uthmani'})?.style,
        MushafStyle.classic,
      );
    });
  });

  group('QuranBookmarkCubit', () {
    test('reads bookmarks saved before ayahs were tracked', () {
      final c = QuranBookmarkCubit();
      expect(c.fromJson({'surah': 18}), const QuranBookmark(18, 1));
      expect(c.fromJson({'surah': null}), isNull);
      expect(c.toJson(const QuranBookmark(2, 255)), {'surah': 2, 'ayah': 255});
    });
  });

  group('juz', () {
    test('lists the surahs in a juz with their entry ayah', () {
      expect(surahsInJuz(1), [(1, 1), (2, 1)]);
      expect(surahsInJuz(2), [(2, 142)]);
      expect(surahsInJuz(4), [(3, 93), (4, 1)]);
      expect(surahsInJuz(15), [(17, 1), (18, 1)]);
      expect(surahsInJuz(30).first, (78, 1));
      expect(surahsInJuz(30).last, (114, 1));
      expect(juzOrdinalsAr, hasLength(30));
    });
  });

  group('RecentSurahsCubit', () {
    setUp(useMemoryStorage);

    test('keeps the last three surahs, newest first, and persists', () {
      RecentSurahsCubit()
        ..visit(2, 2)
        ..visit(2, 3)
        ..visit(18, 293)
        ..visit(36, 440)
        ..visit(67, 562);
      expect(RecentSurahsCubit().state, [(67, 562), (36, 440), (18, 293)]);
    });
  });

  group('MushafCubit', () {
    test(
      'loads the page and its neighbours, reloads on mushaf change',
      () async {
        final api = _FakeQuranApi();
        final c = MushafCubit(api: api, mushaf: Mushaf.uthmani)..visit(1);
        await Future<void>.delayed(Duration.zero);
        expect(api.pageCalls, [(1, Mushaf.uthmani), (2, Mushaf.uthmani)]);
        expect(c.state.pages[1]!.page!.ayahs.first.text, 'uthmani 1:6');

        c.visit(2);
        await Future<void>.delayed(Duration.zero);
        expect(api.pageCalls.last, (3, Mushaf.uthmani));
        expect(api.pageCalls, hasLength(3));

        c.setMushaf(Mushaf.tajweed, page: 2);
        await Future<void>.delayed(Duration.zero);
        expect(c.state.pages.keys.toSet(), {1, 2, 3});
        expect(c.state.pages[2]!.page!.mushaf, Mushaf.tajweed);
      },
    );
  });

  group('TafsirCubit', () {
    test('loads, crosses surahs and reports errors', () async {
      final c = TafsirCubit(
        api: _FakeQuranApi(),
        mushaf: Mushaf.uthmani,
        surah: 1,
        ayah: 7,
        source: TafsirSource.muyassar,
      );
      await Future<void>.delayed(Duration.zero);
      expect(c.state.text, 'muyassar on 1:7');
      expect(c.state.verse!.text, 'text 1:7');

      c.next();
      await Future<void>.delayed(Duration.zero);
      expect((c.state.surah, c.state.ayah), (2, 1));
      expect(c.state.text, 'muyassar on 2:1');

      c.previous();
      await Future<void>.delayed(Duration.zero);
      expect((c.state.surah, c.state.ayah), (1, 7));

      c.setSource(TafsirSource.qurtubi);
      await Future<void>.delayed(Duration.zero);
      expect(c.state.error, ApiException.network);
      expect(c.state.verse, isNotNull);
    });
  });

  group('reader', () {
    setUp(() {
      useMemoryStorage();
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    Future<_FakeQuranApi> pumpReader(WidgetTester tester, String lang) async {
      final api = _FakeQuranApi();
      await tester.pumpWidget(
        RepositoryProvider<QuranApi>.value(
          value: api,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => QuranPrefsCubit()),
              BlocProvider(create: (_) => QuranBookmarkCubit()),
              BlocProvider(create: (_) => RecentSurahsCubit()),
              BlocProvider(create: (_) => KhatmahCubit()),
              BlocProvider(
                create: (_) => RecitationCubit(engine: FakeEngine()),
              ),
              BlocProvider(create: (_) => AmbientCubit(engine: FakeAmbient())),
            ],
            child: MaterialApp(
              locale: Locale(lang),
              supportedLocales: L10n.supportedLocales,
              localizationsDelegates: const [
                L10n.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const MushafScreen(page: 1),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      return api;
    }

    testWidgets('next surah starts on the same page with its banner', (
      tester,
    ) async {
      await pumpReader(tester, 'en');
      expect(find.byType(AyahMarker), findsNWidgets(4));
      expect(find.text('سورة البقرة'), findsOneWidget);
    });

    testWidgets('tapping an ayah opens its tafsir and moves across surahs', (
      tester,
    ) async {
      final api = await pumpReader(tester, 'en');

      await tester.tap(find.byType(AyahMarker).at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(api.tafsirCalls.last, (TafsirSource.ibnKathir, 1, 7));
      expect(find.text('ibnKathir on 1:7'), findsOneWidget);
      expect(find.text('Al-Fatihah · Ayah 7'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.navigate_next_rounded).last);
      await tester.pump();
      await tester.pump();
      expect(find.text('Al-Baqarah · Ayah 1'), findsOneWidget);
      expect(find.text('ibnKathir on 2:1'), findsOneWidget);

      await tester.tap(find.text('Mark as last read'));
      await tester.pump();
      final ctx = tester.element(find.byType(MushafScreen));
      expect(ctx.read<QuranBookmarkCubit>().state, const QuranBookmark(2, 1));
    });

    testWidgets('swiping turns the page', (tester) async {
      final api = await pumpReader(tester, 'ar');
      // Arabic UI is right-to-left: the next page comes from the left.
      await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('صفحة ٢'), findsOneWidget);
      expect(api.pageCalls.map((c) => c.$1), containsAll([1, 2, 3]));
    });

    testWidgets('switching mushaf reloads the page', (tester) async {
      final api = await pumpReader(tester, 'ar');
      final ctx = tester.element(find.byType(MushafScreen));
      ctx.read<QuranPrefsCubit>().setMushaf(Mushaf.plain);
      await tester.pump();
      await tester.pump();
      expect(api.pageCalls.last.$2, Mushaf.plain);
    });
  });
}
