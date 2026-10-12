import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/clock.dart';

DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);

/// Missed Ramadan fasts to make up, and a kaffarah of 60 days in a row.
final class QadaLog extends Equatable {
  const QadaLog({
    this.owed = 0,
    this.made = const [],
    this.imported = const {},
    this.mealCost = 0,
    this.kaffarahStart,
    this.kaffarahDays = const {},
  });

  /// Fasts missed in total, including ones already made up.
  final int owed;

  /// Days made up, newest first.
  final List<DateTime> made;

  /// Hijri years whose Ramadan tracker was already added to [owed].
  final Set<int> imported;

  /// One meal for a poor person, for fidyah; 0 = not set.
  final double mealCost;

  /// null while no kaffarah is running.
  final DateTime? kaffarahStart;

  /// Days fasted since [kaffarahStart].
  final Set<DateTime> kaffarahDays;

  static const kaffarahLength = 60;

  int get remaining => (owed - made.length).clamp(0, owed);

  bool madeOn(DateTime day) => made.contains(_date(day));

  /// Consecutive kaffarah days from the start; stops at the first gap
  /// before today.
  int kaffarahStreak(DateTime now) {
    final start = kaffarahStart;
    if (start == null) return 0;
    final today = _date(now);
    var n = 0;
    for (
      var d = start;
      !d.isAfter(today);
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      if (kaffarahDays.contains(d)) {
        n++;
      } else if (d != today) {
        return n;
      }
    }
    return n;
  }

  /// A day before today was missed, so the 60 days must restart.
  bool kaffarahBroken(DateTime now) {
    final start = kaffarahStart;
    if (start == null) return false;
    final today = _date(now);
    for (
      var d = start;
      d.isBefore(today);
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      if (!kaffarahDays.contains(d)) return true;
    }
    return false;
  }

  QadaLog copyWith({
    int? owed,
    List<DateTime>? made,
    Set<int>? imported,
    double? mealCost,
    DateTime? Function()? kaffarahStart,
    Set<DateTime>? kaffarahDays,
  }) => QadaLog(
    owed: owed ?? this.owed,
    made: made ?? this.made,
    imported: imported ?? this.imported,
    mealCost: mealCost ?? this.mealCost,
    kaffarahStart: kaffarahStart != null ? kaffarahStart() : this.kaffarahStart,
    kaffarahDays: kaffarahDays ?? this.kaffarahDays,
  );

  @override
  List<Object?> get props => [
    owed,
    made,
    imported,
    mealCost,
    kaffarahStart,
    kaffarahDays,
  ];
}

class QadaCubit extends HydratedCubit<QadaLog> {
  QadaCubit({DateTime Function()? clock})
    : _clock = clock ?? appNow,
      super(const QadaLog());

  final DateTime Function() _clock;

  DateTime get _today => _date(_clock());

  void setOwed(int owed) =>
      emit(state.copyWith(owed: owed.clamp(state.made.length, 9999)));

  /// Adds [missed] days from the Ramadan of [hijriYear], once per year.
  void importRamadan(int hijriYear, int missed) {
    if (state.imported.contains(hijriYear) || missed <= 0) return;
    emit(
      state.copyWith(
        owed: state.owed + missed,
        imported: {...state.imported, hijriYear},
      ),
    );
  }

  /// Toggles today as a made-up fast.
  void toggleToday() {
    final today = _today;
    if (state.made.contains(today)) {
      emit(state.copyWith(made: [...state.made]..remove(today)));
    } else if (state.remaining > 0) {
      emit(state.copyWith(made: [today, ...state.made]));
    }
  }

  void setMealCost(double cost) => emit(state.copyWith(mealCost: cost));

  void startKaffarah() =>
      emit(state.copyWith(kaffarahStart: () => _today, kaffarahDays: const {}));

  void stopKaffarah() =>
      emit(state.copyWith(kaffarahStart: () => null, kaffarahDays: const {}));

  void toggleKaffarahToday() {
    if (state.kaffarahStart == null) return;
    final today = _today;
    final days = {...state.kaffarahDays};
    if (!days.remove(today)) days.add(today);
    emit(state.copyWith(kaffarahDays: days));
  }

  @override
  QadaLog? fromJson(Map<String, dynamic> json) {
    final start = json['kStart'] as String?;
    return QadaLog(
      owed: (json['owed'] as num? ?? 0).toInt(),
      made: [
        for (final d in json['made'] as List? ?? const [])
          DateTime.parse(d as String),
      ],
      imported: {
        for (final y in json['imported'] as List? ?? const [])
          (y as num).toInt(),
      },
      mealCost: (json['meal'] as num? ?? 0).toDouble(),
      kaffarahStart: start == null ? null : DateTime.parse(start),
      kaffarahDays: {
        for (final d in json['kDays'] as List? ?? const [])
          DateTime.parse(d as String),
      },
    );
  }

  @override
  Map<String, dynamic> toJson(QadaLog state) => {
    'owed': state.owed,
    'made': [for (final d in state.made) d.toIso8601String()],
    'imported': state.imported.toList(),
    'meal': state.mealCost,
    'kStart': state.kaffarahStart?.toIso8601String(),
    'kDays': [for (final d in state.kaffarahDays) d.toIso8601String()],
  };
}
