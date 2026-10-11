import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../data.dart';

String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

final class TasbihState extends Equatable {
  const TasbihState({this.index = 0, this.count = 0, this.total = 0});

  final int index;
  final int count;

  /// Taps today.
  final int total;

  Dhikr get current => adhkar[index];

  @override
  List<Object> get props => [index, count, total];
}

enum TasbihTap { counted, dhikrDone, setDone }

class TasbihCubit extends HydratedCubit<TasbihState> {
  TasbihCubit({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _day = _dayKey((clock ?? DateTime.now)()),
      super(const TasbihState());

  final DateTime Function() _clock;
  String _day;

  TasbihTap tap() {
    final key = _dayKey(_clock());
    final s = key == _day ? state : const TasbihState();
    _day = key;
    final count = s.count + 1;
    final done = count >= s.current.target;
    final index = done ? (s.index + 1) % adhkar.length : s.index;
    emit(
      TasbihState(index: index, count: done ? 0 : count, total: s.total + 1),
    );
    if (!done) return TasbihTap.counted;
    return index == 0 ? TasbihTap.setDone : TasbihTap.dhikrDone;
  }

  void reset() => emit(TasbihState(total: state.total));

  @override
  TasbihState? fromJson(Map<String, dynamic> json) {
    if (json['day'] != _dayKey(_clock())) return const TasbihState();
    final index = json['index'] as int;
    return TasbihState(
      index: index < adhkar.length ? index : 0,
      count: json['count'] as int,
      total: json['total'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson(TasbihState state) => {
    'day': _day,
    'index': state.index,
    'count': state.count,
    'total': state.total,
  };
}
