import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/services/tafsir.dart';

void main() {
  test('reads a tafsir book and groups passages by surah', () {
    final book = tafsirFromJson({
      'tafasir': {
        'name': 'الخلاصة من تفسير الطبري',
        'soar': [
          {
            'id': 9,
            'name': 'سورة الفاتحة كاملة',
            'url': 'https://server17.mp3quran.net/tafseer/tabri/001.mp3',
            'sura_id': 1,
          },
          {
            'id': 10,
            'name': 'سورة البقرة الايات من 1 الى 25',
            'url': 'https://server17.mp3quran.net/tafseer/tabri/002-1-25.mp3',
            'sura_id': 2,
          },
          {
            'id': 11,
            'name': 'سورة البقرة الايات من 26 الى 43',
            'url': 'https://server17.mp3quran.net/tafseer/tabri/002-26-43.mp3',
            'sura_id': 2,
          },
          {'id': 1, 'name': 'no audio', 'sura_id': 3},
        ],
      },
    });

    expect(book, isNotNull);
    expect(book!.name, 'الخلاصة من تفسير الطبري');
    expect(book.tracks, hasLength(3));
    expect(book.tracks.first.url.path, endsWith('/001.mp3'));
    final groups = groupTafsir(book.tracks);
    expect(groups.map((g) => g.number), [1, 2]);
    expect(groups.last.tracks, hasLength(2));
  });
}
