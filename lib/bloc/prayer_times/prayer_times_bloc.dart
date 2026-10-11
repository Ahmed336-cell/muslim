import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart';

part 'prayer_times_event.dart';
part 'prayer_times_state.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  PrayerTimesBloc({required this._repository, this._place = cairo})
    : super(const PrayerTimesState()) {
    on<PrayerTimesEvent>(_onLoad, transformer: restartable());
  }

  final IslamicApi _repository;
  Place _place;

  Future<void> _onLoad(
    PrayerTimesEvent event,
    Emitter<PrayerTimesState> emit,
  ) async {
    final place = event is PrayerTimesRequested ? event.place : null;
    if (place != null && place != _place) {
      _place = place;
      // Old times belong to another city; don't show them.
      emit(const PrayerTimesState(status: PrayerTimesStatus.loading));
    } else {
      emit(state.copyWith(status: PrayerTimesStatus.loading));
    }
    try {
      final day = await _repository.fetchToday(_place);
      emit(state.copyWith(status: PrayerTimesStatus.success, day: day));
    } on ApiException catch (e) {
      emit(state.copyWith(status: PrayerTimesStatus.failure, error: e.message));
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
