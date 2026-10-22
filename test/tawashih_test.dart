import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/services/tawashih.dart';

void main() {
  test('munshid catalogue has unique ids and archive items', () {
    expect(tawashihMunshids, isNotEmpty);
    expect(
      tawashihMunshids.map((m) => m.id).toSet().length,
      tawashihMunshids.length,
    );
    for (final id in popularTawashih) {
      expect(tawashihById(id), isNotNull);
    }
  });

  test('classic titles and url encoding', () {
    expect(tawashihTracks, isNotEmpty);
    final m = tawashihById('classic')!;
    final t = tawashihTracks.first;
    expect(m.urlFor(t).host, 'archive.org');
    expect(m.urlFor(t).path, contains('/download/Tawashih/'));
    expect(tawashihFileTitle(t.file, 'ar'), t.titleAr);
  });

  test('file label strips indices and credits', () {
    expect(
      tawashihFileLabel('01 - يا رب ساعدنا - الشيخ كامل يوسف البهتيمي.mp3'),
      contains('يا رب'),
    );
  });
}
