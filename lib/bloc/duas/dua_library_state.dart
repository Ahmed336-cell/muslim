part of 'dua_library_bloc.dart';

enum DuaLibraryStatus { initial, loading, success, failure }

final class DuaLibraryState extends Equatable {
  const DuaLibraryState({
    this.status = DuaLibraryStatus.initial,
    this.language = 'en',
    this.library,
    this.query = '',
    this.error,
  });

  final DuaLibraryStatus status;
  final String language;

  /// Kept while another language loads or if that load fails.
  final DuaLibrary? library;
  final String query;
  final String? error;

  bool get searching => query.trim().length >= 2;

  List<Dua> get results =>
      searching ? library?.search(query) ?? const [] : const [];

  DuaLibraryState copyWith({
    DuaLibraryStatus? status,
    String? language,
    DuaLibrary? library,
    String? query,
    String? error,
  }) {
    return DuaLibraryState(
      status: status ?? this.status,
      language: language ?? this.language,
      library: library ?? this.library,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, language, library, query, error];
}
