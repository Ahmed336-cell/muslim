part of 'fasting_bloc.dart';

sealed class FastingEvent extends Equatable {
  const FastingEvent();

  @override
  List<Object?> get props => [];
}

/// Loads today's fast; a new [place] switches city first.
final class FastingRequested extends FastingEvent {
  const FastingRequested({this.place});

  final Place? place;

  @override
  List<Object?> get props => [place];
}
