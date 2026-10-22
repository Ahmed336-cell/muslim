import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'listen_style.dart';
import 'reciter_art.dart';

/// Center vinyl / gramophone disc — spins while [spinning].
class GramophoneDisc extends StatefulWidget {
  const GramophoneDisc({
    super.key,
    required this.name,
    required this.spinning,
    this.size = 280,
  });

  final String name;
  final bool spinning;
  final double size;

  @override
  State<GramophoneDisc> createState() => _GramophoneDiscState();
}

class _GramophoneDiscState extends State<GramophoneDisc>
    with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _spin.repeat();
  }

  @override
  void didUpdateWidget(covariant GramophoneDisc old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!widget.spinning && _spin.isAnimating) {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final label = coverWord(widget.name);
    final (light, dark) = coverColors(widget.name);

    return AnimatedBuilder(
      animation: _spin,
      builder: (_, child) => Transform.rotate(
        angle: _spin.value * 2 * math.pi,
        child: child,
      ),
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .5),
                blurRadius: size * .12,
                offset: Offset(0, size * .04),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _VinylPainter(light: light, dark: dark),
            child: Center(
              child: Container(
                width: size * .42,
                height: size * .42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [light, dark],
                  ),
                  border: Border.all(
                    color: const Color(0xFFF1DFB8).withValues(alpha: .35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.all(size * .04),
                child: FittedBox(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Fonts.arabic(
                      size * .07,
                      color: const Color(0xFFF1DFB8),
                    ).copyWith(height: 1.2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VinylPainter extends CustomPainter {
  _VinylPainter({required this.light, required this.dark});

  final Color light;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF2A2A2E),
            const Color(0xFF121214),
            const Color(0xFF0A0A0C),
          ],
          stops: const [0.35, 0.72, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: .06);
    for (var i = 1; i <= 14; i++) {
      canvas.drawCircle(c, r * (0.48 + i * 0.032), groove);
    }

    // Accent ring hinting the munshid colour.
    canvas.drawCircle(
      c,
      r * .47,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Color.lerp(light, Listen.accent, .4)!.withValues(alpha: .55),
    );

    // Specular sheen.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * .92),
      -1.1,
      0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .08
        ..color = Colors.white.withValues(alpha: .07)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _VinylPainter old) =>
      old.light != light || old.dark != dark;
}
