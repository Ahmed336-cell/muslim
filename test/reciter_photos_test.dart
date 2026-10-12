import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/quran/recitation_cubit.dart';
import 'package:muslim/services/recitation.dart';
import 'package:muslim/services/reciter_photos.dart';
import 'package:muslim/widgets/reciter_art.dart';

import 'fake_audio.dart';

void main() {
  test('every credited photo is bundled, and only those', () {
    final files = Directory(
      'assets/reciters',
    ).listSync().map((f) => f.uri.pathSegments.last).toSet();
    expect(files, {for (final id in reciterPhotoCredits.keys) '$id.jpg'});
    expect(reciterPhoto(123), 'assets/reciters/123.jpg');
    expect(reciterPhoto(51), isNull, reason: 'no free photo');
    expect(reciterPhoto(null), isNull);
  });

  test('tracks carry the reciter photo', () async {
    final engine = FakeEngine();
    final c = RecitationCubit(engine: engine);
    await c.playAyahs(1, 1, AyahReciter.muaiqly, 'en');
    expect(engine.queue.first.art, 'assets/reciters/102.jpg');

    const reciter = Reciter(
      id: 92,
      name: 'Yasser Al-Dosari',
      recordings: [
        Recording(id: 1, name: 'Hafs', server: 'https://x.test/', surahs: [1]),
      ],
    );
    await c.playSurahs(reciter, reciter.recordings.first, 1, 'en');
    expect(engine.queue.first.art, 'assets/reciters/92.jpg');

    await c.playAyahs(1, 1, AyahReciter.abdulBasit, 'en');
    expect(engine.queue.first.art, isNull);
    await c.close();
  });

  testWidgets('shows the photo, or generated art without one', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            ReciterArt(name: 'Mishary', photo: 'assets/reciters/123.jpg'),
            ReciterArt(name: 'Abdul Basit'),
          ],
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Basit'), findsOneWidget);
  });
}
