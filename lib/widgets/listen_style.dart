import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/ambient.dart';

/// Dark palette for the listening screens.
abstract final class Listen {
  static const bg = Color(0xFF101513);
  static const surface = Color(0xFF1A211E);
  static const surfaceHi = Color(0xFF26302B);
  static const text = Color(0xFFF3EFE6);
  static const textSoft = Color(0x99F3EFE6);
  static const textFaint = Color(0x55F3EFE6);
  static const accent = Color(0xFF4CC38A);
  static const gold = Color(0xFFE0B860);
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
