import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/notifications.dart' show reminderPrayers;

String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

final class PrayerLog extends Equatable {
  const PrayerLog({this.days = const {}, this.qada = const {}});

  /// Obligatory prayers marked as prayed, by device day.
  final Map<String, Set<String>> days;

  /// Missed prayers still to make up, by prayer name.
  final Map<String, int> qada;

  Set<String> on(DateTime day) => days[_dayKey(day)] ?? const {};

  int get qadaTotal => qada.values.fold(0, (a, b) => a + b);

  /// The first day anything was logged, or null.
  DateTime? get firstDay {
    DateTime? first;
    for (final k in days.keys) {
      final [y, m, d] = k.split('-').map(int.parse).toList();
      final day = DateTime(y, m, d);
      if (first == null || day.isBefore(first)) first = day;
    }
    return first;
  }

  /// Days in a row, back from today, with all five prayers; an unfinished
  /// today doesn't break it.
  int streak(DateTime now) {
    var day = DateTime(now.year, now.month, now.day);
    if (on(day).length < reminderPrayers.length) {
      day = DateTime(day.year, day.month, day.day - 1);
    }
    var n = 0;
    while (on(day).length >= reminderPrayers.length) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  /// Share of [prayer] (or of all five) prayed over the last [days] days,
  /// counting only since the first logged day.
  double rate(DateTime now, int days, {String? prayer}) {
    final first = firstDay;
    if (first == null) return 0;
    final today = DateTime(now.year, now.month, now.day);
    var total = 0;
    var done = 0;
    for (var i = 0; i < days; i++) {
      final day = DateTime(today.year, today.month, today.day - i);
      if (day.isBefore(first)) break;
      final prayed = on(day);
      if (prayer == null) {
        total += reminderPrayers.length;
        done += prayed.length;
      } else {
        total++;
        if (prayed.contains(prayer)) done++;
      }
    }
    return total == 0 ? 0 : done / total;
  }

  @override
  List<Object?> get props => [days, qada];
}

/// Which prayers were prayed each day, plus the qada still owed.
class PrayerLogCubit extends HydratedCubit<PrayerLog> {
  PrayerLogCubit({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(const PrayerLog());

  /// About a year of history is kept.
  static const keepDays = 400;

  final DateTime Function() _clock;

  Set<String> get today => state.on(_clock());

  void toggle(String prayer) => toggleOn(_clock(), prayer);

  void toggleOn(DateTime day, String prayer) {
    final key = _dayKey(day);
    final prayed = {...?state.days[key]};
    if (!prayed.remove(prayer)) prayed.add(prayer);
    final now = _clock();
    final oldest = DateTime(now.year, now.month, now.day - keepDays);
    emit(
      PrayerLog(
        days: {
          for (final e in state.days.entries)
            if (e.key != key && !_parse(e.key).isBefore(oldest)) e.key: e.value,
          if (prayed.isNotEmpty) key: prayed,
        },
        qada: state.qada,
      ),
    );
  }

  void addQada(String prayer, int delta) {
    final n = ((state.qada[prayer] ?? 0) + delta).clamp(0, 99999);
    emit(PrayerLog(days: state.days, qada: {...state.qada, prayer: n}));
  }

  static DateTime _parse(String key) {
    final [y, m, d] = key.split('-').map(int.parse).toList();
    return DateTime(y, m, d);
  }

  @override
  PrayerLog? fromJson(Map<String, dynamic> json) {
    // Before history was kept: {day, prayed}.
    if (json['day'] case final String day) {
      return PrayerLog(
        days: {
          day: {...(json['prayed'] as List).cast<String>()},
        },
      );
    }
    return PrayerLog(
      days: {
        for (final e in (json['days'] as Map? ?? const {}).entries)
          '${e.key}': {...(e.value as List).cast<String>()},
      },
      qada: {
        for (final e in (json['qada'] as Map? ?? const {}).entries)
          '${e.key}': (e.value as num).toInt(),
      },
    );
  }

  @override
  Map<String, dynamic> toJson(PrayerLog state) => {
    'days': {for (final e in state.days.entries) e.key: e.value.toList()},
    'qada': state.qada,
  };
}
