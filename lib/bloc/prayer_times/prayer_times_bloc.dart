import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/clock.dart';
import '../../services/islamic_api.dart';
import '../../services/prayer_calc.dart';
import '../../services/qibla_api.dart';

part 'prayer_times_event.dart';
part 'prayer_times_state.dart';

/// Prayer times are computed on the device, so they work offline.
class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  PrayerTimesBloc({
    this._calculator = const PrayerCalculator(),
    this._place = cairo,
    QiblaApi? qibla,
    DateTime Function()? clock,
  }) : _qibla = qibla,
       _clock = clock ?? appNow,
       super(const PrayerTimesState()) {
    on<PrayerTimesEvent>(_onLoad, transformer: restartable());
  }

  final PrayerCalculator _calculator;
  final QiblaApi? _qibla;
  final DateTime Function() _clock;
  Place _place;

  Future<void> _onLoad(
    PrayerTimesEvent event,
    Emitter<PrayerTimesState> emit,
  ) async {
    final place = event is PrayerTimesRequested ? event.place : null;
    if (place != null) _place = place;
    final requested = _place;
    try {
      final day = _calculator.today(requested, _clock());
      emit(PrayerTimesState(status: PrayerTimesStatus.success, day: day));
    } catch (_) {
      emit(
        state.copyWith(
          status: PrayerTimesStatus.failure,
          error: ApiException.badResponse,
        ),
      );
      return;
    }

    final qibla = _qibla;
    if (qibla == null) return;
    final direction = await qibla.direction(requested.lat, requested.lon);
    if (emit.isDone || direction == null) return;
    if (_place.lat != requested.lat || _place.lon != requested.lon) return;
    final day = state.day;
    if (day == null) return;
    emit(
      PrayerTimesState(
        status: PrayerTimesStatus.success,
        day: day.withQibla(direction),
      ),
    );
  }
}
