part of 'prayer_times_bloc.dart';

enum PrayerTimesStatus { initial, loading, success, failure }

final class PrayerTimesState extends Equatable {
  const PrayerTimesState({
    this.status = PrayerTimesStatus.initial,
    this.day,
    this.error,
  });

  final PrayerTimesStatus status;

  /// Kept across failed refreshes so the screen doesn't blank out.
  final PrayerDay? day;
  final String? error;

  bool get isBusy => status == PrayerTimesStatus.loading;

  PrayerTimesState copyWith({
    PrayerTimesStatus? status,
    PrayerDay? day,
    String? error,
  }) {
    return PrayerTimesState(
      status: status ?? this.status,
      day: day ?? this.day,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, day, error];
}
