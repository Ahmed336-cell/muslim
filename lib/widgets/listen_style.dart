import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/ambient.dart';
import '../theme.dart';

/// Dark palette for the listening screens.
abstract final class Listen {
  static bool get _mono => Palette.dark;

  static Color get bg =>
      _mono ? const Color(0xFF000000) : const Color(0xFF101513);
  static Color get surface =>
      _mono ? const Color(0xFF1C1C1E) : const Color(0xFF1A211E);
  static Color get surfaceHi =>
      _mono ? const Color(0xFF2C2C2E) : const Color(0xFF26302B);
  static Color get text =>
      _mono ? const Color(0xFFF2F2F2) : const Color(0xFFF3EFE6);
  static Color get textSoft =>
      _mono ? const Color(0x99F2F2F2) : const Color(0x99F3EFE6);
  static Color get textFaint =>
      _mono ? const Color(0x55F2F2F2) : const Color(0x55F3EFE6);
  static Color get accent =>
      _mono ? const Color(0xFF4CC38A) : const Color(0xFF4CC38A);
  static Color get gold =>
      _mono ? const Color(0xFF6FCF97) : const Color(0xFFE0B860);
}

String ambientName(L10n l, Ambient a) => switch (a) {
  Ambient.rain => l.ambientRain,
  Ambient.storm => l.ambientStorm,
  Ambient.fire => l.ambientFire,
  Ambient.waves => l.ambientWaves,
  Ambient.birds => l.ambientBirds,
  Ambient.night => l.ambientNight,
  Ambient.wind => l.ambientWind,
};

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = '${d.inSeconds.remainder(60)}'.padLeft(2, '0');
  return h > 0 ? '$h:${'$m'.padLeft(2, '0')}:$s' : '$m:$s';
}
