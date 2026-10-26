import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum LocationAccess { granted, denied, blocked, disabled, unknown }

class LocationException implements Exception {
  const LocationException(this.code);

  static const disabled = 'location_disabled';
  static const denied = 'location_denied';

  /// Denied for good; only the system settings can undo it.
  static const blocked = 'location_blocked';
  static const failed = 'location_failed';

  final String code;

  @override
  String toString() => code;
}

/// Device position; overridden in tests.
class LocationService {
  const LocationService();

  /// Current permission, without prompting. [unknown] when the plugin
  /// cannot answer (tests, or a platform without location).
  Future<LocationAccess> access() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationAccess.disabled;
      }
      return switch (await Geolocator.checkPermission()) {
        LocationPermission.deniedForever => LocationAccess.blocked,
        LocationPermission.denied ||
        LocationPermission.unableToDetermine => LocationAccess.denied,
        LocationPermission.whileInUse || LocationPermission.always =>
          LocationAccess.granted,
      };
    } catch (_) {
      return LocationAccess.unknown;
    }
  }

  /// Asks for permission when needed. Throws [LocationException].
  Future<(double lat, double lon)> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationException.disabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        throw const LocationException(LocationException.denied);
      case LocationPermission.deniedForever:
        throw const LocationException(LocationException.blocked);
      case LocationPermission.whileInUse ||
          LocationPermission.always ||
          LocationPermission.unableToDetermine:
        break;
    }

    // A fix from the last hour is close enough for prayer times.
    final last = await _lastKnown();
    if (last != null &&
        DateTime.now().difference(last.timestamp) < const Duration(hours: 1)) {
      return (last.latitude, last.longitude);
    }

    // Network location is quick but missing on some devices (and emulators),
    // so fall back to GPS before giving up.
    for (final accuracy in [LocationAccuracy.medium, LocationAccuracy.high]) {
      try {
        final p = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            timeLimit: const Duration(seconds: 15),
          ),
        );
        return (p.latitude, p.longitude);
      } catch (_) {}
    }
    final stale = last ?? await _lastKnown();
    if (stale != null) return (stale.latitude, stale.longitude);
    throw const LocationException(LocationException.failed);
  }

  Future<Position?> _lastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
