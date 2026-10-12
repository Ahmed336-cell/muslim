import 'package:flutter/foundation.dart';

/// Debug builds can pretend to be on another day, keeping the time of day:
/// `flutter run --dart-define=SIM_DATE=2026-10-16`.
const _simulatedDate = String.fromEnvironment('SIM_DATE');

final Duration _shift = () {
  final target = DateTime.tryParse(_simulatedDate);
  if (!kDebugMode || target == null) return Duration.zero;
  final now = DateTime.now();
  return DateTime(
    target.year,
    target.month,
    target.day,
  ).difference(DateTime(now.year, now.month, now.day));
}();

DateTime appNow() => DateTime.now().add(_shift);
