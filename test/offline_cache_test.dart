import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/services/offline_cache.dart';
import 'package:muslim/services/quran.dart';

/// A server that can be switched off, slowed down or made to fail.
class _Server {
  var online = true;
  var status = 200;
  Duration delay = Duration.zero;
  String body = '{"ok":1}';
  var calls = 0;

  late final client = MockClient((req) async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (!online) throw Exception('offline');
    return http.Response.bytes(utf8.encode(body), status);
  });
}

void main() {
  final url = Uri.https('api.test', '/v1/page/1', {'b': '2', 'a': '1'});

  test('saves responses and serves them once offline', () async {
    final server = _Server();
    final store = MemoryResponseStore();
    final c = OfflineClient(inner: server.client, store: store);

    expect((await c.get(url)).body, '{"ok":1}');
    expect(store.entries, hasLength(1));

    server.online = false;
    final res = await c.get(url);
    expect(res.statusCode, 200);
    expect(res.body, '{"ok":1}');
    expect(res.headers[OfflineClient.cachedAtHeader], isNotNull);
  });

  test('without a saved copy the network error surfaces', () async {
    final server = _Server()..online = false;
    final c = OfflineClient(inner: server.client, store: MemoryResponseStore());
    await expectLater(c.get(url), throwsException);
  });

  test('fresh data replaces the saved copy', () async {
    final server = _Server();
    final c = OfflineClient(inner: server.client, store: MemoryResponseStore());
    await c.get(url);
    server.body = '{"ok":2}';
    expect((await c.get(url)).body, '{"ok":2}');
    server.online = false;
    expect((await c.get(url)).body, '{"ok":2}');
  });

  test('server errors fall back; error payloads are never saved', () async {
    final server = _Server();
    final c = OfflineClient(inner: server.client, store: MemoryResponseStore());
    await c.get(url);

    server.status = 503;
    expect((await c.get(url)).body, '{"ok":1}');

    server
      ..status = 200
      ..body = '{"status": "error", "message": "rate limited"}';
    expect((await c.get(url)).body, contains('rate limited'));
    server.online = false;
    expect((await c.get(url)).body, '{"ok":1}');
  });

  test('a slow network gives way to the saved copy', () async {
    final server = _Server();
    final c = OfflineClient(
      inner: server.client,
      store: MemoryResponseStore(),
      patience: const Duration(milliseconds: 50),
    );
    await c.get(url);
    server.delay = const Duration(milliseconds: 300);
    final watch = Stopwatch()..start();
    expect((await c.get(url)).body, '{"ok":1}');
    expect(watch.elapsedMilliseconds, lessThan(250));
  });

  test('keys ignore the API key and parameter order', () {
    expect(
      OfflineClient.keyFor(
        Uri.https('x.test', '/p', {'a': '1', 'api_key': 'secret', 'b': '2'}),
      ),
      OfflineClient.keyFor(Uri.https('x.test', '/p', {'b': '2', 'a': '1'})),
    );
    expect(
      OfflineClient.keyFor(Uri.https('x.test', '/p', {'a': '1'})),
      isNot(OfflineClient.keyFor(Uri.https('x.test', '/p', {'a': '2'}))),
    );
  });

  test('a Quran page read once opens again offline', () async {
    final store = MemoryResponseStore();
    final server = _Server()
      ..body = jsonEncode({
        'code': 200,
        'status': 'OK',
        'data': {
          'number': 1,
          'ayahs': [
            {
              'surah': {'number': 1},
              'numberInSurah': 1,
              'text': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              'page': 1,
              'juz': 1,
              'sajda': false,
            },
          ],
        },
      });
    await QuranApi(
      client: OfflineClient(inner: server.client, store: store),
    ).fetchPage(1, Mushaf.uthmani);

    server.online = false;
    // A new QuranApi has an empty memory cache, like a fresh app start.
    final page = await QuranApi(
      client: OfflineClient(inner: server.client, store: store),
    ).fetchPage(1, Mushaf.uthmani);
    expect(page.ayahs.single.surah, 1);
  });

  test('prayer times survive a restart without network', () async {
    final store = MemoryResponseStore();
    final server = _Server()
      ..body = jsonEncode({
        'status': 'success',
        'data': {
          'times': {
            'Fajr': '04:30',
            'Sunrise': '05:50',
            'Dhuhr': '11:45',
            'Asr': '15:05',
            'Maghrib': '17:40',
            'Isha': '18:55',
          },
          'date': {
            'hijri': {
              'day': '1',
              'month': {'ar': 'رجب', 'en': 'Rajab'},
              'year': '1448',
            },
          },
          'qibla': {
            'direction': {'degrees': 136.0},
            'distance': {'value': 1287.0},
          },
          'timezone': {'utc_offset': '+03:00'},
        },
      });
    const place = Place(30, 31);
    final api = IslamicApi(
      client: OfflineClient(inner: server.client, store: store),
      apiKey: 'k',
    );
    final online = await api.fetchToday(place);

    server.online = false;
    final offline = await IslamicApi(
      client: OfflineClient(inner: server.client, store: store),
      apiKey: 'another-key',
    ).fetchToday(place);
    expect(
      offline.prayers.map((p) => p.name),
      online.prayers.map((p) => p.name),
    );
  });
}
