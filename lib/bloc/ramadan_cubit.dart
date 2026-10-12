import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

enum RamadanDeed { fast, taraweeh, quran }

final class RamadanLog extends Equatable {
  const RamadanLog({this.year = 0, this.days = const {}});

  /// Hijri year the log belongs to; a new Ramadan starts a new log.
  final int year;

  /// Deeds done on each day of Ramadan (1–30).
  final Map<int, Set<RamadanDeed>> days;

  Set<RamadanDeed> on(int day) => days[day] ?? const {};

  int count(RamadanDeed deed) =>
      days.values.where((d) => d.contains(deed)).length;

  @override
  List<Object?> get props => [year, days];
}

/// Fasts, taraweeh and daily juz through Ramadan.
class RamadanCubit extends HydratedCubit<RamadanLog> {
  RamadanCubit() : super(const RamadanLog());

  RamadanLog of(int year) =>
      state.year == year ? state : RamadanLog(year: year);

  void toggle(int year, int day, RamadanDeed deed) {
    final log = of(year);
    final deeds = {...log.on(day)};
    if (!deeds.remove(deed)) deeds.add(deed);
    emit(RamadanLog(year: year, days: {...log.days, day: deeds}));
  }

  @override
  RamadanLog? fromJson(Map<String, dynamic> json) => RamadanLog(
    year: (json['year'] as num?)?.toInt() ?? 0,
    days: {
      for (final e in (json['days'] as Map? ?? const {}).entries)
        int.parse('${e.key}'): {
          for (final n in e.value as List)
            ...RamadanDeed.values.where((d) => d.name == n),
        },
    },
  );

  @override
  Map<String, dynamic> toJson(RamadanLog state) => {
    'year': state.year,
    'days': {
      for (final e in state.days.entries)
        '${e.key}': [for (final d in e.value) d.name],
    },
  };
}
