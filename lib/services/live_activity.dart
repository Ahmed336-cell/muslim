import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The next-prayer countdown on the iOS lock screen and Dynamic Island,
/// drawn by ios/MuslimWidgets; a no-op elsewhere.
class LiveActivity {
  const LiveActivity();

  static const _channel = MethodChannel('muslim/live_activity');

  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Starts the activity, or updates the one already showing. False when
  /// the system has Live Activities turned off.
  Future<bool> show({
    required String name,
    required String clock,
    required DateTime at,
    required DateTime since,
    required String label,
    required String nowLabel,
    required String city,
    required bool rtl,
  }) async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>('show', {
            'name': name,
            'clock': clock,
            'at': at.millisecondsSinceEpoch,
            'since': since.millisecondsSinceEpoch,
            'label': label,
            'now': nowLabel,
            'city': city,
            'rtl': rtl,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> end() async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>('end');
    } catch (_) {}
  }
}
