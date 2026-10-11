part of 'fasting_bloc.dart';

enum FastingStatus { initial, loading, success, failure }

final class FastingState extends Equatable {
  const FastingState({
    this.status = FastingStatus.initial,
    this.day,
    this.error,
  });

  final FastingStatus status;
  final FastingDay? day;
  final String? error;

  bool get isBusy => status == FastingStatus.loading;

  FastingState copyWith({
    FastingStatus? status,
    FastingDay? day,
    String? error,
  }) {
    return FastingState(
      status: status ?? this.status,
      day: day ?? this.day,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, day, error];
}
