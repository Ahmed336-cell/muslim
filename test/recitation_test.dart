import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslim/bloc/quran/ambient_cubit.dart';
import 'package:muslim/bloc/quran/downloads_cubit.dart';
import 'package:muslim/bloc/quran/quran_prefs_cubit.dart';
import 'package:muslim/bloc/quran/recent_reciters_cubit.dart';
import 'package:muslim/bloc/quran/recitation_cubit.dart';
import 'package:muslim/l10n/l10n.dart';
import 'package:muslim/screens/now_playing_screen.dart';
import 'package:muslim/screens/reciters_screen.dart';
import 'package:muslim/widgets/mini_player.dart';
import 'package:muslim/services/ambient.dart';
import 'package:muslim/services/islamic_api.dart' show ApiException;
import 'package:muslim/services/recitation.dart';

import 'fake_audio.dart';
import 'helpers.dart';

Map<String, dynamic> _reciterJson(int id, String name, String surahList) => {
  'id': id,
  'name': name,
  'moshaf': [
    {
      'id': id * 10,
      'name': 'حفص عن عاصم - مرتل',
      'server': 'https://server.test/r$id',
      'surah_list': surahList,
    },
  ],
};

const _recording = Recording(
  id: 50,
  name: 'Hafs',
  server: 'https://server.test/r5/',
  surahs: [1, 2, 112],
);
const _reciter = Reciter(id: 5, name: 'Test Reciter', recordings: [_recording]);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('urls', () {
    test('global ayah numbers run across surahs', () {
      expect(globalAyah(1, 1), 1);
      expect(globalAyah(2, 1), 8);
      expect(globalAyah(2, 255), 262);
      expect(globalAyah(114, 6), 6236);
    });

    test('ayah and surah files', () {
      expect(
        AyahReciter.alafasy.ayahUrl(2, 255).toString(),
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/262.mp3',
      );
      expect(
        _recording.surahUrl(2).toString(),
        'https://server.test/r5/002.mp3',
      );
      expect(AyahReciter.byId('nope'), AyahReciter.alafasy);
    });
  });

  group('RecitersApi', () {
    test('parses, drops empty reciters and sorts by name', () async {
      Uri? asked;
      final api = RecitersApi(
        client: MockClient((req) async {
          asked = req.url;
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'reciters': [
                  _reciterJson(2, 'ياسر', '1,2, 3'),
                  _reciterJson(1, 'أحمد', '114,1'),
                  _reciterJson(3, 'فارغ', ''),
                ],
              }),
            ),
            200,
          );
        }),
      );
      final list = await api.fetch('ar');
      expect(asked!.queryParameters['language'], 'ar');
      expect(list.map((r) => r.name), ['أحمد', 'ياسر']);
      final rec = list.first.recordings.single;
      expect(rec.surahs, [1, 114]);
      expect(rec.server, 'https://server.test/r1/');
      expect(list.last.recordings.single.surahs, [1, 2, 3]);
    });

    test('network failures become ApiException', () async {
      final api = RecitersApi(
        client: MockClient((_) async => throw Exception('down')),
      );
      expect(
        () => api.fetch('en'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            ApiException.network,
          ),
        ),
      );
    });
  });

  group('RecitationCubit', () {
    test('recites ayah by ayah and runs on into the next surah', () async {
      final engine = FakeEngine();
      final c = RecitationCubit(engine: engine);
      await c.playAyahs(1, 6, AyahReciter.husary, 'en');
      await _settle();

      expect(engine.queue.take(2).map((t) => t.ayah), [(1, 6), (1, 7)]);
      expect(c.state.ayah, (1, 6));
      expect(c.state.current!.title, 'Al-Fatihah · 6');
      expect(c.state.current!.uri.path, contains('/ar.husary/6.mp3'));
      await _settle();
      // Near the end of al-Fatihah, al-Baqarah is queued behind it.
      expect(engine.queue.length, 2 + 286);
      expect(c.state.tracks.length, 2 + 286);

      await engine.skipTo(2);
      await _settle();
      expect(c.state.ayah, (2, 1));
    });

    test('pause, resume, skip and stop', () async {
      final engine = FakeEngine();
      final c = RecitationCubit(engine: engine);
      await c.playAyahs(2, 255, AyahReciter.alafasy, 'ar');
      await _settle();
      expect(c.state.current!.title, 'سورة البقرة · ٢٥٥');

      await c.toggle();
      await _settle();
      expect(c.state.playing, isFalse);
      await c.toggle();
      await _settle();
      expect(c.state.playing, isTrue);

      await c.next();
      await _settle();
      expect(c.state.ayah, (2, 256));
      await c.previous();
      await _settle();
      expect(c.state.ayah, (2, 255));

      await c.toggleRepeat();
      expect(c.state.repeat, isTrue);
      expect(engine.repeat, isTrue);

      await c.stop();
      expect(c.state.active, isFalse);
      expect(c.state.repeat, isFalse);
      expect(engine.repeat, isFalse);
      expect(engine.queue, isEmpty);
    });

    test('a failed load can be retried', () async {
      final engine = FakeEngine()..failLoad = true;
      final c = RecitationCubit(engine: engine);
      await c.playAyahs(1, 1, AyahReciter.alafasy, 'en');
      expect(c.state.error, isTrue);
      expect(c.state.playing, isFalse);

      engine.failLoad = false;
      await c.toggle();
      await _settle();
      expect(c.state.error, isFalse);
      expect(c.state.playing, isTrue);
      expect(engine.loads, 2);
    });

    test('whole surahs prefer downloaded files', () async {
      final engine = FakeEngine();
      final c = RecitationCubit(engine: engine);
      final local = Uri.file('/audio/50/2.mp3');
      await c.playSurahs(_reciter, _recording, 2, 'en', local: {2: local});
      await _settle();

      expect(c.state.kind, RecitationKind.surahs);
      expect(c.state.recording, 50);
      expect(c.state.ayah, isNull);
      expect(engine.index, 1);
      expect(engine.queue[1].uri, local);
      expect(engine.queue[0].uri.toString(), 'https://server.test/r5/001.mp3');
      expect(c.state.current!.artist, 'Test Reciter');
    });
  });

  group('DownloadsCubit', () {
    test('tracks progress, saves and deletes', () async {
      final store = FakeStore()..files.add((50, 1));
      final c = DownloadsCubit(store: store);
      await _settle();
      expect(c.state.saved, {(50, 1)});

      final seen = <double?>[];
      final sub = c.stream.listen((s) => seen.add(s.progress[(50, 2)]));
      expect(await c.download(_recording, 2), isTrue);
      await _settle();
      await sub.cancel();
      expect(seen, containsAllInOrder([0.0, .5]));
      expect(c.state.saved, {(50, 1), (50, 2)});
      expect(c.state.progress, isEmpty);
      expect((await c.local(50)).keys, unorderedEquals([1, 2]));

      await c.delete(50, 1);
      expect(c.state.saved, {(50, 2)});
    });

    test('a failed download leaves nothing behind', () async {
      final c = DownloadsCubit(store: FakeStore()..fail = true);
      expect(await c.download(_recording, 112), isFalse);
      expect(c.state.saved, isEmpty);
      expect(c.state.progress, isEmpty);
    });
  });

  group('AmbientCubit', () {
    setUp(useMemoryStorage);

    test('sounds follow the recitation and remember the mix', () async {
      final engine = FakeAmbient();
      final c = AmbientCubit(engine: engine);
      await c.toggle(Ambient.rain);
      expect(engine.playing, isEmpty, reason: 'nothing recited yet');

      await c.setLive(true);
      expect(engine.playing, {Ambient.rain: AmbientMix.defaultVolume});
      await c.toggle(Ambient.fire);
      await c.setVolume(Ambient.fire, .8);
      expect(engine.playing, {
        Ambient.rain: AmbientMix.defaultVolume,
        Ambient.fire: .8,
      });

      await c.setLive(false);
      expect(engine.playing, isEmpty);
      expect(engine.loaded, {Ambient.rain, Ambient.fire});

      await c.toggle(Ambient.rain);
      expect(engine.loaded, {Ambient.fire});
      expect(AmbientCubit(engine: FakeAmbient()).state.volumes, {
        Ambient.fire: .8,
      });

      await c.clearMix();
      expect(c.state.volumes, isEmpty);
      expect(engine.loaded, isEmpty);
    });
  });

  group('RecentRecitersCubit', () {
    setUp(useMemoryStorage);

    test('newest first, no repeats, persisted', () {
      RecentRecitersCubit()
        ..played(1)
        ..played(2)
        ..played(1);
      expect(RecentRecitersCubit().state, [1, 2]);
    });
  });

  group('prefs', () {
    setUp(useMemoryStorage);

    test('ayah reciter persists alongside the other choices', () {
      QuranPrefsCubit()
        ..setFontSize(30)
        ..setReciter(AyahReciter.sudais);
      final again = QuranPrefsCubit().state;
      expect(again.reciter, AyahReciter.sudais);
      expect(again.fontSize, 30);
    });
  });

  group('reciter screen', () {
    setUp(() {
      useMemoryStorage();
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    testWidgets('plays a surah and shows the mini player', (tester) async {
      final engine = FakeEngine();
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => RecitationCubit(engine: engine)),
            BlocProvider(create: (_) => DownloadsCubit(store: FakeStore())),
            BlocProvider(create: (_) => AmbientCubit(engine: FakeAmbient())),
            BlocProvider(create: (_) => RecentRecitersCubit()),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: L10n.supportedLocales,
            localizationsDelegates: const [
              L10n.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const ReciterScreen(reciter: _reciter),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('3 surahs'), findsOneWidget);
      expect(find.byIcon(Icons.graphic_eq_rounded), findsNothing);

      await tester.tap(find.text('Al-Baqarah'));
      await tester.pump();
      await tester.pump();
      expect(engine.index, 1);
      expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);
      // Mini player plus the big play button.
      expect(find.byIcon(Icons.pause_rounded), findsNWidgets(2));
      final ctx = tester.element(find.byType(ReciterScreen));
      expect(ctx.read<RecentRecitersCubit>().state, [5]);

      await tester.tap(find.byTooltip('Download').first);
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.download_done_rounded), findsOneWidget);

      // Full player with background sounds.
      await tester.tap(find.byType(MiniPlayer));
      await tester.pumpAndSettle();
      expect(find.byType(NowPlayingScreen), findsOneWidget);
      await tester.ensureVisible(find.text('Rain'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Rain'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rain'));
      await tester.pump();
      expect(ctx.read<AmbientCubit>().state.contains(Ambient.rain), isTrue);
      expect(find.byType(Slider), findsNWidgets(2));
    });
  });
}
