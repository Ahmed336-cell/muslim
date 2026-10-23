import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// (degrees from north 0..360 — or -180..180 on Android —, accuracy in
/// degrees or null when unknown).
typedef Heading = (double, double?);

const _compassChannel = MethodChannel('sabeelak/compass');
const _headingChannel = EventChannel('sabeelak/heading');
const _cameraChannel = EventChannel('sabeelak/camera_heading');

/// Where the top of the phone points. iOS follows device motion, so the dial
/// turns as the phone turns even when it is not held flat.
Stream<Heading>? headingStream() => defaultTargetPlatform == TargetPlatform.iOS
    ? _native(_headingChannel)
    : _flutterCompass();

/// Where the back camera points (held upright). On Android flutter_compass
/// already switches to the camera axis once the phone is tilted up.
Stream<Heading>? cameraHeadingStream() =>
    defaultTargetPlatform == TargetPlatform.iOS
    ? _native(_cameraChannel)
    : _flutterCompass();

Stream<Heading> _native(EventChannel channel) =>
    channel.receiveBroadcastStream().where((e) => e != null).map((e) {
      final v = (e as List).cast<num>();
      final accuracy = v[1].toDouble();
      return (v[0].toDouble(), accuracy < 0 ? null : accuracy);
    });

Stream<Heading>? _flutterCompass() => FlutterCompass.events
    ?.where((e) => e.heading != null)
    .map((e) => (e.heading!, e.accuracy));

/// Degrees to add to a magnetic heading for true north. Android only; iOS
/// streams are already true north (or close enough without location).
Future<double> magneticDeclination(double lat, double lon) async {
  if (defaultTargetPlatform != TargetPlatform.android) return 0;
  try {
    return await _compassChannel.invokeMethod<double>('declination', {
          'lat': lat,
          'lon': lon,
        }) ??
        0;
  } catch (_) {
    // No channel (tests, other platforms): stay on magnetic north.
    return 0;
  }
}

/// Signed turn from [heading] to [target], -180..180; positive = turn right.
double turnTo(double target, double heading) =>
    ((target - heading + 540) % 360) - 180;
