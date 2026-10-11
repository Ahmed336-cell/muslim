part of 'nisab_bloc.dart';

enum NisabStatus { initial, loading, success, failure }

final class NisabState extends Equatable {
  const NisabState({
    this.status = NisabStatus.initial,
    this.standard = NisabStandard.classical,
    this.currency = 'EGP',
    this.nisab,
    this.error,
  });

  final NisabStatus status;
  final NisabStandard standard;
  final String currency;

  /// Last successful result; may be for a previous currency while loading.
  final Nisab? nisab;
  final String? error;

  /// Only trust [nisab] for calculations when it matches the selection.
  Nisab? get current =>
      nisab != null &&
          nisab!.currency == currency.toUpperCase() &&
          nisab!.standard == standard
      ? nisab
      : null;

  NisabState copyWith({
    NisabStatus? status,
    NisabStandard? standard,
    String? currency,
    Nisab? nisab,
    String? error,
  }) {
    return NisabState(
      status: status ?? this.status,
      standard: standard ?? this.standard,
      currency: currency ?? this.currency,
      nisab: nisab ?? this.nisab,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, standard, currency, nisab, error];
}
