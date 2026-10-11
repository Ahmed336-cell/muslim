part of 'nisab_bloc.dart';

sealed class NisabEvent extends Equatable {
  const NisabEvent();

  @override
  List<Object?> get props => [];
}

final class NisabRequested extends NisabEvent {
  const NisabRequested();
}

final class NisabStandardChanged extends NisabEvent {
  const NisabStandardChanged(this.standard);

  final NisabStandard standard;

  @override
  List<Object?> get props => [standard];
}

final class NisabCurrencyChanged extends NisabEvent {
  const NisabCurrencyChanged(this.currency);

  final String currency;

  @override
  List<Object?> get props => [currency];
}
