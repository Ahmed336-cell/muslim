import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart';

part 'fasting_event.dart';
part 'fasting_state.dart';

class FastingBloc extends Bloc<FastingEvent, FastingState> {
  FastingBloc({required this._repository, this._place = cairo})
    : super(const FastingState()) {
    on<FastingRequested>(_onLoad, transformer: restartable());
  }

  final IslamicApi _repository;
  Place _place;

  Future<void> _onLoad(
    FastingRequested event,
    Emitter<FastingState> emit,
  ) async {
    final place = event.place;
    if (place != null && place != _place) {
      _place = place;
      emit(const FastingState(status: FastingStatus.loading));
    } else {
      emit(state.copyWith(status: FastingStatus.loading));
    }
    try {
      final day = await _repository.fetchFasting(_place);
      emit(state.copyWith(status: FastingStatus.success, day: day));
    } on ApiException catch (e) {
      emit(state.copyWith(status: FastingStatus.failure, error: e.message));
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
