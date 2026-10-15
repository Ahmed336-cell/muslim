import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/clock.dart';
import '../services/islamic_api.dart';

String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

/// Islamic day of Jumu'ah: Maghrib Thursday → Maghrib Friday.
/// Without prayer times, Maghrib is taken as 18:00.
bool isJumuahMood(DateTime now, {PrayerDay? day}) {
  final clock = day?.cityNow(now) ?? now;
  final maghrib =
      day?.prayers.where((p) => p.name == 'Maghrib').firstOrNull?.on(clock) ??
      DateTime(clock.year, clock.month, clock.day, 18);
  return switch (clock.weekday) {
    DateTime.thursday => !clock.isBefore(maghrib),
    DateTime.friday => clock.isBefore(maghrib),
    _ => false,
  };
}

/// Friday's deeds, most important first.
enum FridayDeed { prayer, ghusl, kahf, salawat, early, clothes, dua }

final class FridayState extends Equatable {
  const FridayState({this.day = '', this.salawat = 0, this.done = const {}});

  final String day;
  final int salawat;
  final Set<FridayDeed> done;

  @override
  List<Object?> get props => [day, salawat, done];
}

/// Today's salawat count and Friday checklist; both start over each day.
class FridayCubit extends HydratedCubit<FridayState> {
  FridayCubit({DateTime Function()? clock})
    : _clock = clock ?? appNow,
      super(const FridayState());

  final DateTime Function() _clock;

  FridayState get today =>
      state.day == _dayKey(_clock()) ? state : const FridayState();

  void salawat() {
    final t = today;
    emit(
      FridayState(day: _dayKey(_clock()), salawat: t.salawat + 1, done: t.done),
    );
  }

  void resetSalawat() =>
      emit(FridayState(day: _dayKey(_clock()), done: today.done));

  void toggle(FridayDeed deed) {
    final t = today;
    final done = {...t.done};
    if (!done.remove(deed)) done.add(deed);
    emit(FridayState(day: _dayKey(_clock()), salawat: t.salawat, done: done));
  }

  @override
  FridayState? fromJson(Map<String, dynamic> json) => FridayState(
    day: json['day'] as String? ?? '',
    salawat: (json['salawat'] as num?)?.toInt() ?? 0,
    done: {
      for (final n in json['done'] as List? ?? const [])
        ...FridayDeed.values.where((d) => d.name == n),
    },
  );

  @override
  Map<String, dynamic> toJson(FridayState state) => {
    'day': state.day,
    'salawat': state.salawat,
    'done': [for (final d in state.done) d.name],
  };
}
