part of 'prayer_times_bloc.dart';

sealed class PrayerTimesEvent extends Equatable {
  const PrayerTimesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads today's times; a new [place] switches city first.
final class PrayerTimesRequested extends PrayerTimesEvent {
  const PrayerTimesRequested({this.place});

  final Place? place;

  @override
  List<Object?> get props => [place];
}

final class PrayerTimesRefreshed extends PrayerTimesEvent {
  const PrayerTimesRefreshed();
}
