import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../services/recite_check.dart';

/// One saved recitation check.
final class ReciteAttempt extends Equatable {
  const ReciteAttempt({
    required this.at,
    required this.surah,
    required this.from,
    required this.to,
    required this.result,
  });

  final DateTime at;
  final int surah;
  final int from;
  final int to;
  final ReciteResult result;

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'surah': surah,
    'from': from,
    'to': to,
    'heard': result.heard,
    'words': [
      for (final w in result.words)
        {
          'a': w.ayah,
          'i': w.index,
          'w': w.word,
          'f': w.folded,
          'm': result.marks[(w.ayah, w.index)]!.name,
          'h': result.heardAs[(w.ayah, w.index)],
        },
    ],
  };

  static ReciteAttempt? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['at']}');
    final surah = json['surah'];
    final from = json['from'];
    final to = json['to'];
    final words = json['words'];
    if (at == null ||
        surah is! int ||
        from is! int ||
        to is! int ||
        words is! List) {
      return null;
    }
    final expected = <ExpectedWord>[];
    final marks = <(int, int), WordMark>{};
    final heardAs = <(int, int), String>{};
    for (final raw in words) {
      if (raw is! Map) return null;
      final ayah = raw['a'];
      final index = raw['i'];
      final word = raw['w'];
      final folded = raw['f'];
      final mark = WordMark.values.asNameMap()[raw['m']];
      if (ayah is! int ||
          index is! int ||
          word is! String ||
          folded is! String ||
          mark == null) {
        return null;
      }
      expected.add((ayah: ayah, index: index, word: word, folded: folded));
      marks[(ayah, index)] = mark;
      if (raw['h'] case final String heard) {
        heardAs[(ayah, index)] = heard;
      }
    }
    return ReciteAttempt(
      at: at,
      surah: surah,
      from: from,
      to: to,
      result: ReciteResult(
        words: expected,
        marks: marks,
        heardAs: heardAs,
        heard: json['heard'] as String? ?? '',
      ),
    );
  }

  @override
  List<Object?> get props => [at, surah, from, to, result.heard, result.score];
}

/// Newest checks first. Kept on device with the rest of the hifz settings.
class ReciteHistoryCubit extends HydratedCubit<List<ReciteAttempt>> {
  ReciteHistoryCubit() : super(const []);

  static const maxAttempts = 40;

  void remember({
    required int surah,
    required int from,
    required int to,
    required ReciteResult result,
  }) {
    emit(
      [
        ReciteAttempt(
          at: DateTime.now(),
          surah: surah,
          from: from,
          to: to,
          result: result,
        ),
        ...state,
      ].take(maxAttempts).toList(),
    );
  }

  @override
  List<ReciteAttempt>? fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) return const [];
    return [for (final raw in items) ?_read(raw)];
  }

  static ReciteAttempt? _read(Object? raw) {
    if (raw is Map<String, dynamic>) return ReciteAttempt.fromJson(raw);
    if (raw is Map) {
      return ReciteAttempt.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(List<ReciteAttempt> state) => {
    'items': [for (final a in state) a.toJson()],
  };
}
