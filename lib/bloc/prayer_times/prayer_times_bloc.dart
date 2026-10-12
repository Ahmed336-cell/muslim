import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/clock.dart';
import '../../services/islamic_api.dart';
import '../../services/prayer_calc.dart';

part 'prayer_times_event.dart';
part 'prayer_times_state.dart';

/// Prayer times are computed on the device, so they work offline.
class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  PrayerTimesBloc({
    this._calculator = const PrayerCalculator(),
    this._place = cairo,
    DateTime Function()? clock,
  }) : _clock = clock ?? appNow,
       super(const PrayerTimesState()) {
    on<PrayerTimesEvent>(_onLoad, transformer: restartable());
  }

  final PrayerCalculator _calculator;
  final DateTime Function() _clock;
  Place _place;

  void _onLoad(PrayerTimesEvent event, Emitter<PrayerTimesState> emit) {
    final place = event is PrayerTimesRequested ? event.place : null;
    if (place != null) _place = place;
    try {
      final day = _calculator.today(_place, _clock());
      emit(PrayerTimesState(status: PrayerTimesStatus.success, day: day));
    } catch (_) {
      emit(
        state.copyWith(
          status: PrayerTimesStatus.failure,
          error: ApiException.badResponse,
        ),
      );
    }
  }
}
