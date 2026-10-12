import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/hisn.dart';

enum AzkarTap { counted, itemDone, sessionDone }

/// Today's counts per dhikr; a new day starts from zero.
final class AzkarProgress extends Equatable {
  const AzkarProgress({this.day = '', this.counts = const {}});

  final String day;

  /// Keyed `session:id`, e.g. `morning:75`.
  final Map<String, int> counts;

  @override
  List<Object?> get props => [day, counts];
}

class AzkarCubit extends HydratedCubit<AzkarProgress> {
  AzkarCubit({DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(const AzkarProgress());

  final DateTime Function() _now;

  String get _today {
    final d = _now();
    return '${d.year}-${d.month}-${d.day}';
  }

  Map<String, int> get _counts => state.day == _today ? state.counts : const {};

  static String _key(AzkarSession s, Dhikr d) => '${s.name}:${d.id}';

  int countOf(AzkarSession s, Dhikr d) => _counts[_key(s, d)] ?? 0;

  bool isDone(AzkarSession s, Dhikr d) => countOf(s, d) >= d.repeat;

  int doneIn(AzkarSession s, List<Dhikr> items) =>
      items.where((d) => isDone(s, d)).length;

  /// Counts one recitation of [d]; a finished dhikr stays finished.
  AzkarTap tap(AzkarSession s, Dhikr d, List<Dhikr> session) {
    if (isDone(s, d)) {
      return doneIn(s, session) == session.length
          ? AzkarTap.sessionDone
          : AzkarTap.itemDone;
    }
    final counts = {..._counts, _key(s, d): countOf(s, d) + 1};
    emit(AzkarProgress(day: _today, counts: counts));
    if (!isDone(s, d)) return AzkarTap.counted;
    return doneIn(s, session) == session.length
        ? AzkarTap.sessionDone
        : AzkarTap.itemDone;
  }

  void reset(AzkarSession s) => emit(
    AzkarProgress(
      day: _today,
      counts: {
        for (final e in _counts.entries)
          if (!e.key.startsWith('${s.name}:')) e.key: e.value,
      },
    ),
  );

  @override
  AzkarProgress? fromJson(Map<String, dynamic> json) => AzkarProgress(
    day: json['day'] as String? ?? '',
    counts: {
      for (final e in (json['counts'] as Map? ?? {}).entries)
        '${e.key}': (e.value as num).toInt(),
    },
  );

  @override
  Map<String, dynamic> toJson(AzkarProgress state) => {
    'day': state.day,
    'counts': state.counts,
  };
}
