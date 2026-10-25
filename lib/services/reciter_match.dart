import 'dart:math' as math;
import 'dart:typed_data';

import 'recitation.dart';

/// One enrolled recording. The same sheikh can have several (murattal,
/// mujawwad, a different riwaya) because each one was fingerprinted alone.
class ReciterVoice {
  const ReciterVoice({
    required this.reciterId,
    required this.recordingId,
    required this.nameAr,
    required this.nameEn,
    required this.recordingName,
  });

  final int reciterId;
  final int recordingId;
  final String nameAr;
  final String nameEn;
  final String recordingName;

  String name(String language) => language == 'ar' ? nameAr : nameEn;

  /// Verse-by-verse audio when this voice has a Hafs edition. Other
  /// riwayat stay on the full-surah recording.
  AyahReciter? get ayahReciter {
    final name = recordingName;
    const otherRiwayah = [
      'ورش',
      'قالون',
      'البزي',
      'قنبل',
      'شعبة',
      'دوري',
      'سوسي',
      'خلف',
    ];
    if (otherRiwayah.any((w) => name.contains(w))) return null;
    final all = [
      for (final r in AyahReciter.values)
        if (r.mp3quranId == reciterId) r,
    ];
    if (all.isEmpty) return null;
    final mujawwad = name.contains('مجود');
    for (final r in all) {
      if (r.id.contains('mujawwad') == mujawwad) return r;
    }
    return all.first;
  }

  factory ReciterVoice.fromJson(Map<String, dynamic> json) => ReciterVoice(
    reciterId: json['reciterId'] as int,
    recordingId: json['recordingId'] as int,
    nameAr: '${json['nameAr']}',
    nameEn: '${json['nameEn']}',
    recordingName: '${json['recordingName']}',
  );
}

class ReciterMatch {
  const ReciterMatch({required this.voice, required this.score});

  final ReciterVoice voice;

  /// Cosine similarity, 1 when the clip matches the enrolled voice.
  final double score;
}

/// Highest cosine matches. [embeddings] is row-major, one unit vector per
/// voice, and [query] is compared after it is normalized.
List<ReciterMatch> rankReciters(
  Float32List query,
  Float32List embeddings,
  List<ReciterVoice> voices, {
  int k = 3,
}) {
  if (voices.isEmpty || query.isEmpty) return const [];
  final dim = query.length;
  if (embeddings.length != voices.length * dim) {
    throw ArgumentError(
      'embeddings ${embeddings.length} != ${voices.length} x $dim',
    );
  }
  var norm = 0.0;
  for (final v in query) {
    norm += v * v;
  }
  norm = math.sqrt(norm);
  if (norm == 0) return const [];

  final scored = <ReciterMatch>[];
  for (var i = 0; i < voices.length; i++) {
    var dot = 0.0;
    final row = i * dim;
    for (var d = 0; d < dim; d++) {
      dot += embeddings[row + d] * query[d];
    }
    scored.add(ReciterMatch(voice: voices[i], score: dot / norm));
  }
  scored.sort((a, b) => b.score.compareTo(a.score));
  return scored.take(k).toList();
}
