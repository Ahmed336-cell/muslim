import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart';

part 'dua_library_event.dart';
part 'dua_library_state.dart';

class DuaLibraryBloc extends Bloc<DuaLibraryEvent, DuaLibraryState> {
  DuaLibraryBloc({required this._api, String language = 'en'})
    : super(DuaLibraryState(language: language)) {
    on<DuaLibraryRequested>(_onRequested, transformer: restartable());
    on<DuaLibraryLanguageSet>(
      (e, emit) => emit(state.copyWith(language: e.language)),
    );
    on<DuaSearched>((e, emit) => emit(state.copyWith(query: e.query)));
  }

  final IslamicApi _api;

  Future<void> _onRequested(
    DuaLibraryRequested event,
    Emitter<DuaLibraryState> emit,
  ) async {
    final language = event.language ?? state.language;
    final cached = state.library?.language == language;
    if (cached && !event.force) return;

    emit(state.copyWith(status: DuaLibraryStatus.loading, language: language));
    try {
      final library = await _api.fetchDuaLibrary(language);
      emit(state.copyWith(status: DuaLibraryStatus.success, library: library));
    } on ApiException catch (e) {
      emit(state.copyWith(status: DuaLibraryStatus.failure, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: DuaLibraryStatus.failure,
          error: ApiException.badResponse,
        ),
      );
    }
  }
}
