import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/duas/dua_library_bloc.dart';
import 'package:muslim/bloc/duas/dua_of_day_cubit.dart';
import 'package:muslim/services/islamic_api.dart';

final _duaJson = {
  'dua_id': 3,
  'title': 'Power of La Ilaha Illallah',
  'category_tags': [],
  'introduction': 'Say the following statement 10 times -',
  'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ',
  'audio': '/audio/dua/3.mp3',
  'transliteration': 'Laa ilahaa illAllah',
  'translation': 'None has the right to be worshipped but Allah alone.',
  'reference': 'Bukhari: 6404',
  'hadith': {
    'title': 'Hadith about the Dua',
    'arabic': 'حَدَّثَنَا',
    'translation': 'Whoever recites it ten times…',
  },
  'benefits': {
    'title': 'Benefits',
    'description': 'Brings one closer to Allah.',
    'points': ['Wipes away sins', 'Brings peace'],
  },
  'when_to_recite': {'title': 'When', 'description': '', 'points': []},
  'how_to_perform': {
    'title': 'How',
    'description': 'Steps',
    'steps': ['Sit', 'Recite'],
  },
  'faq': [],
  'related_duas': [],
};

DuaLibrary _library(String lang) => DuaLibrary(
  language: lang,
  categories: const [DuaCategory(slug: 'salah', name: 'Salah')],
  sections: const [
    DuaSection(
      id: 1,
      title: 'After salah',
      category: 'salah',
      duaIds: [3, 999],
    ),
  ],
  duas: {3: Dua.fromJson(_duaJson)},
);

class _FakeApi extends IslamicApi {
  _FakeApi() : super(apiKey: 'test');

  int libraryCalls = 0;
  final duaCalls = <int?>[];

  @override
  Future<DuaLibrary> fetchDuaLibrary(String lang) async {
    libraryCalls++;
    if (lang == 'xyz') {
      throw const ApiException('Language code "xyz" is not available.');
    }
    return _library(lang);
  }

  @override
  Future<Dua> fetchDua(String lang, {int? id}) async {
    duaCalls.add(id);
    if (id != null) throw ApiException('Dua #$id not found for language "en"');
    return Dua.fromJson(_duaJson);
  }
}

void main() {
  test('parses a dua with notes; drops empty notes', () {
    final d = Dua.fromJson(_duaJson);
    expect(d.audioUrl.toString(), 'https://islamicapi.com/audio/dua/3.mp3');
    expect(d.hadith?.description, startsWith('Whoever'));
    expect(d.hadith?.arabic, 'حَدَّثَنَا');
    expect(d.benefits?.items, hasLength(2));
    expect(d.howToPerform?.items, ['Sit', 'Recite']);
    expect(d.whenToRecite, isNull);
  });

  test('library skips ids missing from the dataset', () {
    final lib = _library('en');
    expect(lib.duasIn(lib.sections.first).map((d) => d.id), [3]);
    expect(lib.duaCountOf('salah'), 2);
    expect(lib.search('bukhari'), hasLength(1));
    expect(lib.search('travel'), isEmpty);
  });

  test('dua of the day id is stable per day and in range', () {
    final a = DuaOfDayCubit.idFor(DateTime(2026, 10, 11, 0, 5));
    final b = DuaOfDayCubit.idFor(DateTime(2026, 10, 11, 23, 55));
    expect(a, b);
    expect(a, inInclusiveRange(1, 1001));
    expect(DuaOfDayCubit.idFor(DateTime(2026, 10, 12)), isNot(a));
  });

  group('DuaLibraryBloc', () {
    late _FakeApi api;
    setUp(() => api = _FakeApi());

    blocTest<DuaLibraryBloc, DuaLibraryState>(
      'loads once per language, search needs 2+ chars',
      build: () => DuaLibraryBloc(api: api),
      act: (b) async {
        b.add(const DuaLibraryRequested());
        await Future<void>.delayed(Duration.zero);
        b
          ..add(const DuaLibraryRequested())
          ..add(const DuaSearched('a'));
      },
      verify: (b) {
        expect(api.libraryCalls, 1);
        expect(b.state.searching, isFalse);
        expect(b.state.library?.duas, hasLength(1));
      },
    );

    blocTest<DuaLibraryBloc, DuaLibraryState>(
      'bad language keeps old library and shows error',
      build: () => DuaLibraryBloc(api: api),
      seed: () => DuaLibraryState(
        status: DuaLibraryStatus.success,
        library: _library('en'),
      ),
      act: (b) => b.add(const DuaLibraryRequested(language: 'xyz')),
      verify: (b) {
        expect(b.state.status, DuaLibraryStatus.failure);
        expect(b.state.library?.language, 'en');
        expect(b.state.error, contains('not available'));
      },
    );
  });

  blocTest<DuaOfDayCubit, DuaOfDayState>(
    'falls back to a random dua when the day id is not found',
    build: () => DuaOfDayCubit(api: _FakeApi()),
    act: (c) => c.load(day: DateTime(2026, 10, 11)),
    verify: (c) {
      expect(c.state.dua?.id, 3);
      expect(c.state.error, isNull);
    },
  );
}
