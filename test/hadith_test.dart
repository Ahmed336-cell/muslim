import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/services/hadith.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads bundled collections', () async {
    final repo = HadithRepository();
    final nawawi = await repo.load(HadithBook.nawawi);
    expect(nawawi.hadiths.length, 42);
    expect(nawawi.hadiths.first.arabic, contains('بِالنِّيَّاتِ'));
    final riyad = await repo.load(HadithBook.riyad);
    expect(riyad.hadiths.length, greaterThan(1800));
    expect(riyad.chapters, isNotEmpty);
    expect(
      riyad.chapters.fold(0, (n, c) => n + riyad.inChapter(c.id).length),
      riyad.hadiths.length,
    );
  });

  test('searches Arabic ignoring diacritics, and English', () async {
    final repo = HadithRepository();
    final ar = await repo.search('إنما الأعمال بالنيات');
    expect(ar.first.book, HadithBook.nawawi);
    expect(ar.first.number, 1);
    final en = await repo.search('intention');
    expect(en, isNotEmpty);
    expect(await repo.search('x'), isEmpty);
  });
}
