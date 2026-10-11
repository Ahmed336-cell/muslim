part of 'names_bloc.dart';

enum NamesStatus { initial, loading, success, failure }

final class NamesState extends Equatable {
  const NamesState({
    this.status = NamesStatus.initial,
    this.language = 'en',
    this.book,
    this.query = '',
    this.error,
  });

  final NamesStatus status;
  final String language;

  /// Last loaded book; kept while a new language loads or if it fails.
  final NamesBook? book;
  final String query;
  final String? error;

  List<DivineName> get visible =>
      book?.names.where((n) => n.matches(query.trim())).toList() ?? const [];

  NamesState copyWith({
    NamesStatus? status,
    String? language,
    NamesBook? book,
    String? query,
    String? error,
  }) {
    return NamesState(
      status: status ?? this.status,
      language: language ?? this.language,
      book: book ?? this.book,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, language, book, query, error];
}
