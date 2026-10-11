import 'package:hydrated_bloc/hydrated_bloc.dart';

String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

/// Names of the prayers the user has marked as prayed today.
/// Survives restarts; starts empty on a new day.
class PrayerLogCubit extends HydratedCubit<Set<String>> {
  PrayerLogCubit({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _day = _dayKey((clock ?? DateTime.now)()),
      super(const {});

  final DateTime Function() _clock;
  String _day;

  Set<String> get today {
    if (_dayKey(_clock()) != _day) return const {};
    return state;
  }

  void toggle(String prayer) {
    final key = _dayKey(_clock());
    final next = key == _day ? {...state} : <String>{};
    _day = key;
    if (!next.remove(prayer)) next.add(prayer);
    emit(next);
  }

  @override
  Set<String>? fromJson(Map<String, dynamic> json) {
    if (json['day'] != _dayKey(_clock())) return const {};
    return {...(json['prayed'] as List).cast<String>()};
  }

  @override
  Map<String, dynamic> toJson(Set<String> state) => {
    'day': _day,
    'prayed': state.toList(),
  };
}
