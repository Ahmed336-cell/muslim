part of 'names_bloc.dart';

sealed class NamesEvent extends Equatable {
  const NamesEvent();

  @override
  List<Object?> get props => [];
}

final class NamesRequested extends NamesEvent {
  const NamesRequested([this.language]);

  /// null keeps the current language.
  final String? language;

  @override
  List<Object?> get props => [language];
}

final class NamesSearched extends NamesEvent {
  const NamesSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
