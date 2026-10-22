import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';

/// Sky mood from the upcoming / just-passed prayer.
enum SkyPeriod { fajr, morning, noon, afternoon, maghrib, isha }

SkyPeriod skyPeriodFor(List<Prayer> prayers, DateTime now) {
  DateTime? at(String name) =>
      prayers.where((p) => p.name == name).firstOrNull?.on(now);

  final fajr = at('Fajr');
  final sunrise = at('Sunrise');
  final dhuhr = at('Dhuhr');
  final asr = at('Asr');
  final maghrib = at('Maghrib');
  final isha = at('Isha');

  if (fajr == null || maghrib == null || isha == null) {
    final h = now.hour;
    if (h < 5) return SkyPeriod.isha;
    if (h < 7) return SkyPeriod.fajr;
    if (h < 11) return SkyPeriod.morning;
    if (h < 15) return SkyPeriod.noon;
    if (h < 17) return SkyPeriod.afternoon;
    if (h < 19) return SkyPeriod.maghrib;
    return SkyPeriod.isha;
  }

  if (now.isBefore(fajr)) return SkyPeriod.isha;
  if (sunrise != null && now.isBefore(sunrise)) return SkyPeriod.fajr;
  if (dhuhr != null && now.isBefore(dhuhr)) return SkyPeriod.morning;
  if (asr != null && now.isBefore(asr)) return SkyPeriod.noon;
  if (now.isBefore(maghrib)) return SkyPeriod.afternoon;
  if (now.isBefore(isha)) return SkyPeriod.maghrib;
  return SkyPeriod.isha;
}

class _SkyPalette {
  const _SkyPalette({
    required this.sky,
    required this.ground,
    required this.mosque,
    required this.dome,
    required this.accent, // sun / moon
    required this.label,
    required this.countdown,
    required this.trees,
    required this.stars,
    required this.birds,
  });

  final List<Color> sky;
  final Color ground;
  final Color mosque;
  final Color dome;
  final Color accent;
  final Color label;
  final Color countdown;
  final Color trees;
  final bool stars;
  final bool birds;
}

_SkyPalette _palette(SkyPeriod p) => switch (p) {
  SkyPeriod.fajr => const _SkyPalette(
    sky: [Color(0xFF2A3A5C), Color(0xFF7A6B8E), Color(0xFFE8A07A), Color(0xFFF5D4B8)],
    ground: Color(0xFF3D4A3A),
    mosque: Color(0xFF4A5A6E),
    dome: Color(0xFF6A8FB0),
    accent: Color(0xFFFFC98A),
    label: Color(0xFFE8B4A0),
    countdown: Color(0xFFF8F0E8),
    trees: Color(0xFF2E4030),
    stars: true,
    birds: false,
  ),
  SkyPeriod.morning => const _SkyPalette(
    sky: [Color(0xFF9ED0F0), Color(0xFFC8E6F8), Color(0xFFEAF6FC)],
    ground: Color(0xFFB8D4A8),
    mosque: Color(0xFF5B7C9E),
    dome: Color(0xFF6BA3C9),
    accent: Color(0xFFFFE08A),
    label: Color(0xFFA9512F),
    countdown: Color(0xFF1F2A24),
    trees: Color(0xFF5A8A4A),
    stars: false,
    birds: true,
  ),
  SkyPeriod.noon => const _SkyPalette(
    sky: [Color(0xFF6BB8E8), Color(0xFFA8D8F0), Color(0xFFE0F2FA)],
    ground: Color(0xFFA8C898),
    mosque: Color(0xFF4E7394),
    dome: Color(0xFF5B9BC4),
    accent: Color(0xFFFFF0A8),
    label: Color(0xFFA9512F),
    countdown: Color(0xFF1F2A24),
    trees: Color(0xFF4E8A3E),
    stars: false,
    birds: true,
  ),
  SkyPeriod.afternoon => const _SkyPalette(
    sky: [Color(0xFF7EC4E8), Color(0xFFB8DCF0), Color(0xFFF0F7FC)],
    ground: Color(0xFFB0CFA0),
    mosque: Color(0xFF5B7C9E),
    dome: Color(0xFF6B9BC3),
    accent: Color(0xFFFFD878),
    label: Color(0xFFA9512F),
    countdown: Color(0xFF1F2A24),
    trees: Color(0xFF5A8A4A),
    stars: false,
    birds: true,
  ),
  SkyPeriod.maghrib => const _SkyPalette(
    sky: [Color(0xFF3A3A6A), Color(0xFFC06858), Color(0xFFE8A060), Color(0xFFF5CFA0)],
    ground: Color(0xFF4A5540),
    mosque: Color(0xFF3E4E62),
    dome: Color(0xFF5A7A9A),
    accent: Color(0xFFFFB060),
    label: Color(0xFFE89870),
    countdown: Color(0xFFF8F0E8),
    trees: Color(0xFF2E3A28),
    stars: false,
    birds: true,
  ),
  SkyPeriod.isha => const _SkyPalette(
    sky: [Color(0xFF0B1224), Color(0xFF1A2744), Color(0xFF2A3A5C)],
    ground: Color(0xFF1A2420),
    mosque: Color(0xFF2A3848),
    dome: Color(0xFF3A5A78),
    accent: Color(0xFFE8E4D0),
    label: Color(0xFFC8B898),
    countdown: Color(0xFFF2F2F2),
    trees: Color(0xFF152018),
    stars: true,
    birds: false,
  ),
};

/// Animated mosque sky that follows [period].
class HomeSkyScene extends StatefulWidget {
  const HomeSkyScene({super.key, required this.period, this.child});

  final SkyPeriod period;
  final Widget? child;

  @override
  State<HomeSkyScene> createState() => _HomeSkySceneState();
}

class _HomeSkySceneState extends State<HomeSkyScene>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette(widget.period);
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => CustomPaint(
        painter: _SkyMosquePainter(
          palette: palette,
          t: _anim.value,
          period: widget.period,
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _SkyMosquePainter extends CustomPainter {
  _SkyMosquePainter({
    required this.palette,
    required this.t,
    required this.period,
  });

  final _SkyPalette palette;
  final double t;
  final SkyPeriod period;

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;

    // Sky
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: p.sky,
        ).createShader(Offset.zero & size),
    );

    // Soft clouds (day / afternoon / maghrib)
    if (!p.stars || period == SkyPeriod.fajr) {
      _clouds(canvas, size, p);
    }

    // Stars
    if (p.stars) _stars(canvas, size);

    // Sun / moon
    _orb(canvas, size, p);

    // Distant hills
    final hill = Path()
      ..moveTo(0, size.height * .72)
      ..quadraticBezierTo(
        size.width * .25,
        size.height * .58,
        size.width * .5,
        size.height * .68,
      )
      ..quadraticBezierTo(
        size.width * .75,
        size.height * .78,
        size.width,
        size.height * .66,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()..color = Color.lerp(p.ground, p.sky.last, .35)!,
    );

    // Near ground
    final ground = Path()
      ..moveTo(0, size.height * .82)
      ..quadraticBezierTo(
        size.width * .5,
        size.height * .74,
        size.width,
        size.height * .84,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, Paint()..color = p.ground);

    // Trees left / right
    _tree(canvas, Offset(size.width * .12, size.height * .88), 28, p.trees);
    _tree(canvas, Offset(size.width * .2, size.height * .9), 22, p.trees);
    _tree(canvas, Offset(size.width * .84, size.height * .89), 26, p.trees);
    _tree(canvas, Offset(size.width * .92, size.height * .91), 20, p.trees);

    _mosque(canvas, size, p);

    if (p.birds) _birds(canvas, size, p);
  }

  void _clouds(Canvas canvas, Size size, _SkyPalette p) {
    final drift = math.sin(t * 2 * math.pi) * 8;
    final paint = Paint()..color = Colors.white.withValues(alpha: .45);
    void puff(double x, double y, double r) {
      canvas.drawCircle(Offset(x + drift, y), r, paint);
      canvas.drawCircle(Offset(x + drift + r * .7, y + 2), r * .75, paint);
      canvas.drawCircle(Offset(x + drift - r * .6, y + 3), r * .65, paint);
    }

    puff(size.width * .15, size.height * .22, 14);
    puff(size.width * .55, size.height * .16, 12);
    puff(size.width * .88, size.height * .3, 10);
  }

  void _stars(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    for (var i = 0; i < 28; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * .55;
      final twinkle =
          .35 + .65 * ((math.sin(t * 2 * math.pi * 2 + i) + 1) / 2);
      canvas.drawCircle(
        Offset(x, y),
        1.1 + (i % 3) * .4,
        Paint()..color = Colors.white.withValues(alpha: twinkle),
      );
    }
  }

  void _orb(Canvas canvas, Size size, _SkyPalette p) {
    final night = period == SkyPeriod.isha;
    final dawn = period == SkyPeriod.fajr;
    final dusk = period == SkyPeriod.maghrib;
    // Path across sky: morning high-right, noon top, afternoon mid-right, etc.
    final progress = switch (period) {
      SkyPeriod.fajr => .15,
      SkyPeriod.morning => .35,
      SkyPeriod.noon => .5,
      SkyPeriod.afternoon => .68,
      SkyPeriod.maghrib => .88,
      SkyPeriod.isha => .2,
    };
    final bob = math.sin(t * 2 * math.pi) * 3;
    final c = Offset(
      size.width * (.15 + progress * .7),
      size.height * (night || dawn ? .22 : .18 + (progress - .5).abs() * .15) +
          bob,
    );
    final r = night ? 16.0 : (dusk || dawn ? 20.0 : 24.0);

    // Glow pulse
    final pulse = 1 + .08 * math.sin(t * 2 * math.pi);
    canvas.drawCircle(
      c,
      r * 1.7 * pulse,
      Paint()..color = p.accent.withValues(alpha: night ? .15 : .28),
    );
    canvas.drawCircle(
      c,
      r * 1.25 * pulse,
      Paint()..color = p.accent.withValues(alpha: night ? .25 : .4),
    );

    if (night) {
      // Crescent
      canvas.drawCircle(c, r, Paint()..color = p.accent);
      canvas.drawCircle(
        c.translate(r * .35, -r * .1),
        r * .85,
        Paint()..color = p.sky.first,
      );
    } else {
      canvas.drawCircle(c, r, Paint()..color = p.accent);
      // Soft rim
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: .35),
      );
    }
  }

  void _tree(Canvas canvas, Offset base, double h, Color color) {
    final trunk = Paint()..color = Color.lerp(color, Colors.black, .35)!;
    canvas.drawRect(
      Rect.fromCenter(center: base.translate(0, -h * .15), width: 4, height: h * .35),
      trunk,
    );
    final leaf = Paint()..color = color;
    canvas.drawCircle(base.translate(0, -h * .45), h * .28, leaf);
    canvas.drawCircle(base.translate(-h * .18, -h * .35), h * .2, leaf);
    canvas.drawCircle(base.translate(h * .18, -h * .35), h * .2, leaf);
  }

  void _mosque(Canvas canvas, Size size, _SkyPalette p) {
    final cx = size.width * .5;
    final baseY = size.height * .94;
    final mosque = Paint()..color = p.mosque;
    final dome = Paint()..color = p.dome;

    // Side wings
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 78, baseY - 48, 40, 48),
        const Radius.circular(6),
      ),
      mosque,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 38, baseY - 48, 40, 48),
        const Radius.circular(6),
      ),
      mosque,
    );

    // Minarets
    for (final dx in [-88.0, 88.0]) {
      final x = cx + dx;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 6, baseY - 108, 12, 108),
          const Radius.circular(3),
        ),
        mosque,
      );
      // Balcony rings
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 10, baseY - 70, 20, 8),
          const Radius.circular(2),
        ),
        Paint()..color = Color.lerp(p.mosque, Colors.white, .15)!,
      );
      // Finial
      canvas.drawCircle(Offset(x, baseY - 112), 7, dome);
      canvas.drawCircle(Offset(x, baseY - 120), 3, dome);
    }

    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 52, baseY - 62, 104, 62),
        const Radius.circular(8),
      ),
      mosque,
    );

    // Dome
    final domePath = Path()
      ..moveTo(cx - 46, baseY - 58)
      ..quadraticBezierTo(cx, baseY - 118, cx + 46, baseY - 58)
      ..close();
    canvas.drawPath(domePath, dome);
    // Crescent on dome
    canvas.drawCircle(Offset(cx, baseY - 118), 5, Paint()..color = p.accent);
    canvas.drawCircle(
      Offset(cx + 2, baseY - 119),
      4,
      Paint()..color = p.dome,
    );

    // Windows / door
    final voidPaint = Paint()..color = Color.lerp(p.mosque, Colors.black, .35)!;
    for (final dx in [-28.0, 0.0, 28.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + dx - 7, baseY - 42, 14, 22),
          const Radius.circular(7),
        ),
        voidPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 14, baseY - 36, 28, 36),
        const Radius.circular(14),
      ),
      voidPaint,
    );

    // Soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, baseY + 2),
        width: 160,
        height: 10,
      ),
      Paint()..color = Colors.black.withValues(alpha: .12),
    );
  }

  void _birds(Canvas canvas, Size size, _SkyPalette p) {
    final bird = Paint()
      ..color = Color.lerp(p.mosque, Colors.black, .25)!
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 4; i++) {
      final phase = t * 2 * math.pi + i * 1.3;
      final x = size.width * (.18 + i * .12) + math.sin(phase) * 10;
      final y = size.height * (.18 + i * .04) + math.cos(phase * .8) * 6;
      final flap = 4 + 2 * math.sin(phase * 3);
      final path = Path()
        ..moveTo(x - 7, y)
        ..quadraticBezierTo(x - 2, y - flap, x, y)
        ..quadraticBezierTo(x + 2, y - flap, x + 7, y);
      canvas.drawPath(path, bird);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyMosquePainter old) =>
      old.t != t || old.period != period || old.palette != palette;
}

/// Text colours that match the active sky.
(Color label, Color countdown) skyTextColors(SkyPeriod period) {
  final p = _palette(period);
  return (p.label, p.countdown);
}
