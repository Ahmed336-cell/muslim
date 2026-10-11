part of 'ruqyah_bloc.dart';

sealed class RuqyahEvent extends Equatable {
  const RuqyahEvent();

  @override
  List<Object?> get props => [];
}

/// Selects (and loads if needed) a program/source; nulls keep the current.
final class RuqyahRecitationRequested extends RuqyahEvent {
  const RuqyahRecitationRequested({this.program, this.source});

  final RuqyahProgram? program;
  final RuqyahSource? source;

  @override
  List<Object?> get props => [program, source];
}

final class RuqyahTopicsRequested extends RuqyahEvent {
  const RuqyahTopicsRequested();
}

final class RuqyahArticlesRequested extends RuqyahEvent {
  const RuqyahArticlesRequested(this.topic);

  final String topic;

  @override
  List<Object?> get props => [topic];
}

final class RuqyahLanguageChanged extends RuqyahEvent {
  const RuqyahLanguageChanged(this.language);

  final String language;

  @override
  List<Object?> get props => [language];
}
