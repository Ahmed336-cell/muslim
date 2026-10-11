import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart';

part 'nisab_event.dart';
part 'nisab_state.dart';

class NisabBloc extends Bloc<NisabEvent, NisabState> {
  NisabBloc({required this._api, String currency = 'EGP'})
    : super(NisabState(currency: currency)) {
    on<NisabEvent>(_onEvent, transformer: restartable());
  }

  final IslamicApi _api;

  Future<void> _onEvent(NisabEvent event, Emitter<NisabState> emit) async {
    final standard = event is NisabStandardChanged
        ? event.standard
        : state.standard;
    final currency = event is NisabCurrencyChanged
        ? event.currency
        : state.currency;

    emit(
      state.copyWith(
        status: NisabStatus.loading,
        standard: standard,
        currency: currency,
      ),
    );
    try {
      final nisab = await _api.fetchNisab(
        standard: standard,
        currency: currency,
      );
      emit(state.copyWith(status: NisabStatus.success, nisab: nisab));
    } on ApiException catch (e) {
      emit(state.copyWith(status: NisabStatus.failure, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: NisabStatus.failure,
          error: ApiException.badResponse,
        ),
      );
    }
  }
}
