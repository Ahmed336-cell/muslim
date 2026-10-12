import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/clock.dart';

enum SadaqahKind { money, food, help, other }

final class SadaqahEntry extends Equatable {
  const SadaqahEntry({
    required this.date,
    required this.kind,
    this.amount = 0,
    this.note = '',
  });

  final DateTime date;
  final SadaqahKind kind;

  /// In the app currency; 0 when not counted in money.
  final double amount;
  final String note;

  @override
  List<Object?> get props => [date, kind, amount, note];
}

final class SadaqahLog extends Equatable {
  const SadaqahLog({this.entries = const [], this.monthlyGoal = 0});

  /// Newest first.
  final List<SadaqahEntry> entries;

  /// 0 = no goal.
  final double monthlyGoal;

  Iterable<SadaqahEntry> inMonth(DateTime month) => entries.where(
    (e) => e.date.year == month.year && e.date.month == month.month,
  );

  double totalIn(DateTime month) =>
      inMonth(month).fold(0, (sum, e) => sum + e.amount);

  /// Weeks in a row, ending this week or last, with at least one entry.
  int weekStreak(DateTime now) {
    DateTime weekOf(DateTime d) =>
        DateTime(d.year, d.month, d.day - (d.weekday % 7));
    final weeks = {for (final e in entries) weekOf(e.date)};
    var week = weekOf(now);
    if (!weeks.contains(week)) {
      week = DateTime(week.year, week.month, week.day - 7);
    }
    var n = 0;
    while (weeks.contains(week)) {
      n++;
      week = DateTime(week.year, week.month, week.day - 7);
    }
    return n;
  }

  @override
  List<Object?> get props => [entries, monthlyGoal];
}

/// A private record of charity given, with a monthly goal.
class SadaqahCubit extends HydratedCubit<SadaqahLog> {
  SadaqahCubit({DateTime Function()? clock})
    : _clock = clock ?? appNow,
      super(const SadaqahLog());

  final DateTime Function() _clock;

  void add(SadaqahKind kind, {double amount = 0, String note = ''}) => emit(
    SadaqahLog(
      entries: [
        SadaqahEntry(
          date: _clock(),
          kind: kind,
          amount: amount,
          note: note.trim(),
        ),
        ...state.entries,
      ],
      monthlyGoal: state.monthlyGoal,
    ),
  );

  void remove(SadaqahEntry entry) => emit(
    SadaqahLog(
      entries: [
        for (final e in state.entries)
          if (e != entry) e,
      ],
      monthlyGoal: state.monthlyGoal,
    ),
  );

  void setGoal(double goal) =>
      emit(SadaqahLog(entries: state.entries, monthlyGoal: goal));

  @override
  SadaqahLog? fromJson(Map<String, dynamic> json) => SadaqahLog(
    entries: [
      for (final e in json['entries'] as List? ?? const [])
        SadaqahEntry(
          date: DateTime.parse(e['date'] as String),
          kind: SadaqahKind.values.asNameMap()[e['kind']] ?? SadaqahKind.other,
          amount: (e['amount'] as num? ?? 0).toDouble(),
          note: e['note'] as String? ?? '',
        ),
    ],
    monthlyGoal: (json['goal'] as num? ?? 0).toDouble(),
  );

  @override
  Map<String, dynamic> toJson(SadaqahLog state) => {
    'entries': [
      for (final e in state.entries)
        {
          'date': e.date.toIso8601String(),
          'kind': e.kind.name,
          'amount': e.amount,
          'note': e.note,
        },
    ],
    'goal': state.monthlyGoal,
  };
}
