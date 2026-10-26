import 'dart:convert';

import 'package:http/http.dart' as http;

import 'islamic_api.dart';

/// One spoken tafsir passage. A surah is often split across several files.
class TafsirTrack {
  const TafsirTrack({
    required this.id,
    required this.surah,
    required this.name,
    required this.url,
  });

  final int id;
  final int surah;
  final String name;
  final Uri url;
}

/// A tafsir book and its passages, in mushaf order.
class TafsirBook {
  const TafsirBook({required this.name, required this.tracks});

  final String name;
  final List<TafsirTrack> tracks;
}

/// Passages that share one surah, still in API order.
class TafsirSurah {
  const TafsirSurah({required this.number, required this.tracks});

  final int number;
  final List<TafsirTrack> tracks;
}

/// Turns the `/api/v3/tafsir` body into a book. Rows without audio are dropped.
TafsirBook? tafsirFromJson(Object? json) {
  if (json is! Map) return null;
  final raw = json['tafasir'];
  if (raw is! Map) return null;
  final soar = raw['soar'];
  if (soar is! List) return null;
  final tracks = <TafsirTrack>[];
  for (final item in soar) {
    if (item is! Map) continue;
    final url = _url(item['url']);
    final surah = _int(item['sura_id']);
    if (url == null || surah == null || surah < 1 || surah > 114) continue;
    tracks.add(
      TafsirTrack(
        id: _int(item['id']) ?? tracks.length,
        surah: surah,
        name: _text(item['name']) ?? '',
        url: url,
      ),
    );
  }
  if (tracks.isEmpty) return null;
  return TafsirBook(name: _text(raw['name']) ?? '', tracks: tracks);
}

/// Groups [tracks] by surah without reordering them.
List<TafsirSurah> groupTafsir(List<TafsirTrack> tracks) {
  final order = <int>[];
  final bySurah = <int, List<TafsirTrack>>{};
  for (final track in tracks) {
    bySurah.putIfAbsent(track.surah, () {
      order.add(track.surah);
      return [];
    }).add(track);
  }
  return [
    for (final number in order)
      TafsirSurah(number: number, tracks: bySurah[number]!),
  ];
}

int? _int(Object? value) => value is int ? value : int.tryParse('$value');

String? _text(Object? value) {
  final text = '$value'.trim();
  if (value == null || text.isEmpty || text == 'null') return null;
  return text;
}

Uri? _url(Object? value) {
  final text = _text(value);
  if (text == null || !text.startsWith('http')) return null;
  return Uri.tryParse(text);
}

/// Spoken tafsir from mp3quran.net. Cached per language and book id.
class TafsirApi {
  TafsirApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final _cache = <String, TafsirBook>{};

  /// Al-Tabari summary. mp3quran ids the book as `1`.
  static const tabari = 1;

  Future<TafsirBook> fetch(String language, {int id = tabari}) async {
    final key = '$language:$id';
    final cached = _cache[key];
    if (cached != null) return cached;
    final http.Response res;
    try {
      res = await _client
          .get(
            Uri.https('www.mp3quran.net', '/api/v3/tafsir', {
              'language': language == 'ar' ? 'ar' : 'eng',
              'tafsir': '$id',
            }),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw const ApiException(ApiException.network);
    }
    if (res.statusCode != 200) {
      throw const ApiException(ApiException.badResponse);
    }
    try {
      final json = jsonDecode(utf8.decode(res.bodyBytes));
      final book = tafsirFromJson(json);
      if (book == null) throw const ApiException(ApiException.badResponse);
      return _cache[key] = book;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(ApiException.badResponse);
    }
  }
}
