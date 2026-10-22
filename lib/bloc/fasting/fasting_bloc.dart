import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data.dart';
import '../../services/clock.dart';
import '../../services/islamic_api.dart';
import '../../services/islamic_events.dart';
import '../../services/prayer_calc.dart';

part 'fasting_event.dart';
part 'fasting_state.dart';

/// Sahur / iftar from on-device prayer times — works offline, no API key.
class FastingBloc extends Bloc<FastingEvent, FastingState> {
  FastingBloc({
    this._calculator = const PrayerCalculator(),
    this._place = cairo,
    DateTime Function()? clock,
  }) : _clock = clock ?? appNow,
       super(const FastingState()) {
    on<FastingRequested>(_onLoad, transformer: restartable());
  }

  final PrayerCalculator _calculator;
  final DateTime Function() _clock;
  Place _place;

  void _onLoad(FastingRequested event, Emitter<FastingState> emit) {
    final place = event.place;
    if (place != null && place != _place) {
      _place = place;
      emit(const FastingState(status: FastingStatus.loading));
    } else {
      emit(state.copyWith(status: FastingStatus.loading));
    }
    try {
      final now = _clock();
      final prayer = _calculator.today(_place, now);
      Prayer find(String name) =>
          prayer.prayers.firstWhere((p) => p.name == name);
      final city = prayer.cityNow(now);
      final day = FastingDay.local(
        fajr: find('Fajr'),
        maghrib: find('Maghrib'),
        whiteDays: upcomingWhiteDays(city, shift: _place.hijriShift),
      );
      emit(state.copyWith(status: FastingStatus.success, day: day));
    } catch (_) {
      emit(
        state.copyWith(
          status: FastingStatus.failure,
          error: ApiException.badResponse,
        ),
      );
    }
  }
}
