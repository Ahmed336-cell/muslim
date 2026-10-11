import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart';

part 'names_event.dart';
part 'names_state.dart';

class NamesBloc extends Bloc<NamesEvent, NamesState> {
  NamesBloc({required this._api, String language = 'en'})
    : super(NamesState(language: language)) {
    on<NamesRequested>(_onRequested, transformer: restartable());
    on<NamesSearched>((e, emit) => emit(state.copyWith(query: e.query)));
  }

  final IslamicApi _api;

  Future<void> _onRequested(
    NamesRequested event,
    Emitter<NamesState> emit,
  ) async {
    final language = event.language ?? state.language;
    emit(state.copyWith(status: NamesStatus.loading, language: language));
    try {
      final book = await _api.fetchNames(language);
      emit(state.copyWith(status: NamesStatus.success, book: book));
    } on ApiException catch (e) {
      emit(state.copyWith(status: NamesStatus.failure, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: NamesStatus.failure,
          error: ApiException.badResponse,
        ),
      );
    }
  }
}
