import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart';

part 'ruqyah_event.dart';
part 'ruqyah_state.dart';

class RuqyahBloc extends Bloc<RuqyahEvent, RuqyahState> {
  RuqyahBloc({required this._api, String language = 'en'})
    : super(RuqyahState(language: language)) {
    on<RuqyahRecitationRequested>(_onRecitation);
    on<RuqyahTopicsRequested>(_onTopics);
    on<RuqyahArticlesRequested>(_onArticles);
    on<RuqyahLanguageChanged>(_onLanguage);
  }

  final IslamicApi _api;

  Future<void> _onRecitation(
    RuqyahRecitationRequested e,
    Emitter<RuqyahState> emit,
  ) async {
    final program = e.program ?? state.program;
    final source = e.source ?? state.source;
    final key = RuqyahState.keyOf(program, source);
    emit(state.copyWith(program: program, source: source));

    final current = state.recitations[key];
    if (current != null && (current.isLoading || current.data != null)) {
      return;
    }

    final lang = state.language;
    emit(state.withRecitation(key, const Loadable.loading()));
    final result = await _load(() => _api.fetchRuqyah(program, source, lang));
    if (state.language == lang) emit(state.withRecitation(key, result));
  }

  Future<void> _onTopics(
    RuqyahTopicsRequested e,
    Emitter<RuqyahState> emit,
  ) async {
    if (state.topics.isLoading || state.topics.data != null) return;
    final lang = state.language;
    emit(state.copyWith(topics: const Loadable.loading()));
    final result = await _load(() => _api.fetchRuqyahTopics(lang));
    if (state.language == lang) emit(state.copyWith(topics: result));
  }

  Future<void> _onArticles(
    RuqyahArticlesRequested e,
    Emitter<RuqyahState> emit,
  ) async {
    final current = state.articles[e.topic];
    if (current != null && (current.isLoading || current.data != null)) {
      return;
    }
    final lang = state.language;
    emit(state.withArticles(e.topic, const Loadable.loading()));
    final result = await _load(() => _api.fetchRuqyahArticles(e.topic, lang));
    if (state.language == lang) emit(state.withArticles(e.topic, result));
  }

  void _onLanguage(RuqyahLanguageChanged e, Emitter<RuqyahState> emit) {
    if (e.language == state.language) return;
    emit(
      RuqyahState(
        language: e.language,
        program: state.program,
        source: state.source,
      ),
    );
    add(const RuqyahRecitationRequested());
    add(const RuqyahTopicsRequested());
  }

  static Future<Loadable<T>> _load<T>(Future<T> Function() fetch) async {
    try {
      return Loadable.done(await fetch());
    } on ApiException catch (e) {
      return Loadable.failed(e.message);
    } catch (_) {
      return const Loadable.failed(ApiException.badResponse);
    }
  }
}
