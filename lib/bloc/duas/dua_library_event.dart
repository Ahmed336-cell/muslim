part of 'dua_library_bloc.dart';

sealed class DuaLibraryEvent extends Equatable {
  const DuaLibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Loads once per language; pass [force] to refetch.
final class DuaLibraryRequested extends DuaLibraryEvent {
  const DuaLibraryRequested({this.language, this.force = false});

  final String? language;
  final bool force;

  @override
  List<Object?> get props => [language, force];
}

/// Changes the language for the next load without fetching now.
final class DuaLibraryLanguageSet extends DuaLibraryEvent {
  const DuaLibraryLanguageSet(this.language);

  final String language;

  @override
  List<Object?> get props => [language];
}

final class DuaSearched extends DuaLibraryEvent {
  const DuaSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
