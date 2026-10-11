import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/names/names_bloc.dart';
import 'package:muslim/services/islamic_api.dart';

Map<String, dynamic> _data(String lang) => {
  'language_code': lang,
  'title': 'The Beautiful Names of Allah',
  'hadith': 'Allah has ninety-nine names…',
  'names': [
    {
      'number': 2,
      'name': 'الرَّحِيمُ',
      'transliteration': 'Ar Raheem',
      'translation': 'The Most Compassionate',
      'meaning': 'The One who has plenty of mercy for the believers.',
      'audio': '/audio/asma-ul-husna/rahim.mp3',
    },
    {
      'number': 1,
      'name': 'الرَّحْمَنُ',
      'transliteration': 'Ar Rahmaan',
      'translation': 'The Most Merciful',
      'meaning': 'The One who has plenty of mercy.',
      'audio': '/audio/asma-ul-husna/rahman.mp3',
    },
  ],
};

class _FakeApi extends IslamicApi {
  _FakeApi() : super(apiKey: 'test');

  @override
  Future<NamesBook> fetchNames(String language) async {
    if (language == 'xyz') {
      throw const ApiException("Language code 'xyz' is not available.");
    }
    return NamesBook.fromJson(_data(language));
  }
}

void main() {
  final book = NamesBook.fromJson(_data('en'));

  test('parses, sorts by number, resolves audio URL', () {
    expect(book.names.map((n) => n.number), [1, 2]);
    expect(
      book.names.first.audioUrl.toString(),
      'https://islamicapi.com/audio/asma-ul-husna/rahman.mp3',
    );
  });

  test('search matches number, transliteration, translation, arabic', () {
    final n = book.names.first;
    expect(n.matches('1'), isTrue);
    expect(n.matches('rahm'), isTrue);
    expect(n.matches('merciful'), isTrue);
    expect(n.matches('الرَّحْمَنُ'), isTrue);
    expect(n.matches('king'), isFalse);
  });

  test('name of the day is stable within a day and changes next day', () {
    final a = book.forDay(DateTime(2026, 10, 11, 1));
    final b = book.forDay(DateTime(2026, 10, 11, 23));
    final c = book.forDay(DateTime(2026, 10, 12));
    expect(a.number, b.number);
    expect(a.number, isNot(c.number));
  });

  blocTest<NamesBloc, NamesState>(
    'loads then filters by query',
    build: () => NamesBloc(api: _FakeApi()),
    act: (b) => b
      ..add(const NamesRequested())
      ..add(const NamesSearched('compassion')),
    verify: (b) {
      expect(b.state.status, NamesStatus.success);
      expect(b.state.visible.map((n) => n.number), [2]);
    },
  );

  blocTest<NamesBloc, NamesState>(
    'unknown language keeps previous names and reports error',
    build: () => NamesBloc(api: _FakeApi()),
    seed: () => NamesState(status: NamesStatus.success, book: book),
    act: (b) => b.add(const NamesRequested('xyz')),
    verify: (b) {
      expect(b.state.status, NamesStatus.failure);
      expect(b.state.book, same(book));
      expect(b.state.error, contains('not available'));
    },
  );
}
