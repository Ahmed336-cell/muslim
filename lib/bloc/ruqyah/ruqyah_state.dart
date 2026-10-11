part of 'ruqyah_bloc.dart';

final class Loadable<T> extends Equatable {
  const Loadable._({this.data, this.isLoading = false, this.error});

  const Loadable.idle() : this._();
  const Loadable.loading() : this._(isLoading: true);
  const Loadable.done(T data) : this._(data: data);
  const Loadable.failed(String error) : this._(error: error);

  final T? data;
  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [data, isLoading, error];
}

final class RuqyahState extends Equatable {
  const RuqyahState({
    this.language = 'en',
    this.program = RuqyahProgram.brief,
    this.source = RuqyahSource.quran,
    this.recitations = const {},
    this.topics = const Loadable.idle(),
    this.articles = const {},
  });

  final String language;
  final RuqyahProgram program;
  final RuqyahSource source;

  /// Keyed by [keyOf].
  final Map<String, Loadable<List<RuqyahEntry>>> recitations;
  final Loadable<List<RuqyahTopic>> topics;

  /// Keyed by topic slug.
  final Map<String, Loadable<List<RuqyahArticle>>> articles;

  static String keyOf(RuqyahProgram p, RuqyahSource s) => '${p.name}/${s.name}';

  Loadable<List<RuqyahEntry>> get current =>
      recitations[keyOf(program, source)] ?? const Loadable.idle();

  RuqyahState copyWith({
    RuqyahProgram? program,
    RuqyahSource? source,
    Loadable<List<RuqyahTopic>>? topics,
  }) => RuqyahState(
    language: language,
    program: program ?? this.program,
    source: source ?? this.source,
    recitations: recitations,
    topics: topics ?? this.topics,
    articles: articles,
  );

  RuqyahState withRecitation(String key, Loadable<List<RuqyahEntry>> v) =>
      RuqyahState(
        language: language,
        program: program,
        source: source,
        recitations: {...recitations, key: v},
        topics: topics,
        articles: articles,
      );

  RuqyahState withArticles(String topic, Loadable<List<RuqyahArticle>> v) =>
      RuqyahState(
        language: language,
        program: program,
        source: source,
        recitations: recitations,
        topics: topics,
        articles: {...articles, topic: v},
      );

  @override
  List<Object?> get props => [
    language,
    program,
    source,
    recitations,
    topics,
    articles,
  ];
}
