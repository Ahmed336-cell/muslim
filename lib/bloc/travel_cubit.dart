import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/clock.dart';
import '../services/prayer_calc.dart';

/// Home, where the user is now, and whether that makes them a traveller.
final class Travel extends Equatable {
  const Travel({
    this.home,
    this.here,
    this.manual,
    this.since,
    this.dismissed = false,
  });

  /// Roughly the distance (48 miles) most scholars take for shortening.
  static const thresholdKm = 80.0;

  final (double lat, double lon)? home;
  final (double lat, double lon)? here;

  /// The user's own choice; null = decide by distance.
  final bool? manual;

  /// When the user first appeared away from home.
  final DateTime? since;

  /// The "you seem to be travelling" banner was closed for this trip.
  final bool dismissed;

  double? get kmFromHome => switch ((home, here)) {
    ((final h1, final h2), (final n1, final n2)) => distanceKm(h1, h2, n1, n2),
    _ => null,
  };

  bool get away => (kmFromHome ?? 0) >= thresholdKm;

  bool get travelling => manual ?? away;

  /// 1-based day of the trip.
  int? dayOf(DateTime now) => since == null
      ? null
      : DateTime(now.year, now.month, now.day)
                .difference(DateTime(since!.year, since!.month, since!.day))
                .inDays +
            1;

  Travel copyWith({
    (double, double)? Function()? home,
    (double, double)? Function()? here,
    bool? Function()? manual,
    DateTime? Function()? since,
    bool? dismissed,
  }) => Travel(
    home: home != null ? home() : this.home,
    here: here != null ? here() : this.here,
    manual: manual != null ? manual() : this.manual,
    since: since != null ? since() : this.since,
    dismissed: dismissed ?? this.dismissed,
  );

  @override
  List<Object?> get props => [home, here, manual, since, dismissed];
}

class TravelCubit extends HydratedCubit<Travel> {
  TravelCubit({DateTime Function()? clock})
    : _clock = clock ?? appNow,
      super(const Travel());

  final DateTime Function() _clock;

  /// The prayer-time place changed; the first one seen becomes home.
  void observe(double lat, double lon) {
    final here = (lat, lon);
    var next = state.copyWith(here: () => here, home: () => state.home ?? here);
    if (next.away && next.since == null) {
      next = next.copyWith(since: _clock, dismissed: false);
    } else if (!next.away && state.manual == null) {
      next = next.copyWith(since: () => null);
    }
    emit(next);
  }

  void setHomeHere() => emit(
    state.copyWith(
      home: () => state.here,
      since: () => null,
      manual: () => null,
    ),
  );

  /// null goes back to deciding by distance.
  void setManual(bool? on) => emit(
    state.copyWith(
      manual: () => on,
      since: () => on == true ? state.since ?? _clock() : state.since,
    ),
  );

  void dismiss() => emit(state.copyWith(dismissed: true));

  static (double, double)? _point(Object? j) => j is List && j.length == 2
      ? ((j[0] as num).toDouble(), (j[1] as num).toDouble())
      : null;

  @override
  Travel? fromJson(Map<String, dynamic> json) => Travel(
    home: _point(json['home']),
    here: _point(json['here']),
    manual: json['manual'] as bool?,
    since: DateTime.tryParse(json['since'] as String? ?? ''),
    dismissed: json['dismissed'] as bool? ?? false,
  );

  @override
  Map<String, dynamic> toJson(Travel state) => {
    if (state.home case (final a, final b)) 'home': [a, b],
    if (state.here case (final a, final b)) 'here': [a, b],
    'manual': state.manual,
    'since': state.since?.toIso8601String(),
    'dismissed': state.dismissed,
  };
}
