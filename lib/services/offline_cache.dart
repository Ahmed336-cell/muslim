import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CachedBody {
  const CachedBody(this.bytes, this.savedAt);

  final List<int> bytes;
  final DateTime savedAt;
}

/// Where responses are kept; in memory for tests.
abstract class ResponseStore {
  Future<CachedBody?> read(String key);
  Future<void> write(String key, List<int> bytes);
}

/// One file per response under the app support directory.
class FileResponseStore implements ResponseStore {
  Directory? _dir;

  Future<Directory> _root() async => _dir ??= await Directory(
    '${(await getApplicationSupportDirectory()).path}/http_cache',
  ).create(recursive: true);

  @override
  Future<CachedBody?> read(String key) async {
    final f = File('${(await _root()).path}/$key');
    if (!await f.exists()) return null;
    return CachedBody(await f.readAsBytes(), await f.lastModified());
  }

  /// Written beside the target then renamed, so a crash never leaves a
  /// half-written response behind.
  @override
  Future<void> write(String key, List<int> bytes) async {
    final root = await _root();
    final part = File('${root.path}/$key.part');
    await part.writeAsBytes(bytes, flush: true);
    await part.rename('${root.path}/$key');
  }
}

class MemoryResponseStore implements ResponseStore {
  final entries = <String, CachedBody>{};

  @override
  Future<CachedBody?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, List<int> bytes) async =>
      entries[key] = CachedBody(bytes, DateTime.now());
}

/// Saves every successful GET and answers from the saved copy when the
/// network is down, slow or failing, so text content works offline.
class OfflineClient extends http.BaseClient {
  OfflineClient({
    http.Client? inner,
    ResponseStore? store,
    this.patience = const Duration(seconds: 8),
  }) : _inner = inner ?? http.Client(),
       _store = store ?? FileResponseStore();

  /// Response header set when the body came from the cache.
  static const cachedAtHeader = 'x-cached-at';

  final http.Client _inner;
  final ResponseStore _store;

  /// How long to wait for the network when a saved copy exists.
  final Duration patience;

  /// Secrets never become part of the key, so a new API key keeps the cache.
  static String keyFor(Uri url) {
    final params = {...url.queryParameters}..remove('api_key');
    final stable = url.replace(
      queryParameters: params.isEmpty
          ? null
          : Map.fromEntries(
              params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
            ),
    );
    return sha1.convert(utf8.encode(stable.toString())).toString();
  }

  /// Error payloads that arrive with HTTP 200 must not replace good data.
  static bool _cacheable(List<int> bytes) {
    final head = utf8
        .decode(bytes.take(300).toList(), allowMalformed: true)
        .replaceAll(' ', '');
    return !head.contains('"status":"error"');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method != 'GET') return _inner.send(request);
    final key = keyFor(request.url);
    CachedBody? cached;
    try {
      cached = await _store.read(key);
    } catch (_) {}

    try {
      final fetch = _inner.send(request).then(http.Response.fromStream);
      final res = cached == null ? await fetch : await fetch.timeout(patience);
      if (res.statusCode == 200) {
        if (_cacheable(res.bodyBytes)) {
          try {
            await _store.write(key, res.bodyBytes);
          } catch (_) {}
        }
      } else if (res.statusCode >= 500 && cached != null) {
        return _fromCache(cached, request);
      }
      return _streamed(res.bodyBytes, res.statusCode, request, res.headers);
    } catch (_) {
      if (cached != null) return _fromCache(cached, request);
      rethrow;
    }
  }

  static http.StreamedResponse _fromCache(
    CachedBody cached,
    http.BaseRequest request,
  ) => _streamed(cached.bytes, 200, request, {
    'content-type': 'application/json; charset=utf-8',
    cachedAtHeader: cached.savedAt.toIso8601String(),
  });

  static http.StreamedResponse _streamed(
    List<int> bytes,
    int status,
    http.BaseRequest request,
    Map<String, String> headers,
  ) => http.StreamedResponse(
    Stream.value(bytes),
    status,
    contentLength: bytes.length,
    request: request,
    headers: headers,
  );

  @override
  void close() => _inner.close();
}
