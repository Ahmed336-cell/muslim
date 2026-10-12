import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../format.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/city_picker.dart';
import '../widgets/common.dart';

const cairoQibla = 136.14;

/// Static compass; wire a heading sensor into [_heading] for live use.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _heading = 0;
  bool _wasAligned = false;

  String _direction(L10n l, double deg) {
    final names = [
      l.dirN, l.dirNE, l.dirE, l.dirSE, //
      l.dirS, l.dirSW, l.dirW, l.dirNW,
    ];
    return names[((deg + 22.5) % 360 ~/ 45)];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final day = context.select((PrayerTimesBloc b) => b.state.day);
    final qibla = day?.qiblaDegrees ?? cairoQibla;
    final km = day?.qiblaKm;
    final off = ((qibla - _heading + 540) % 360) - 180;
    final aligned = off.abs() < 4;
    if (aligned && !_wasAligned) HapticFeedback.mediumImpact();
    _wasAligned = aligned;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.qiblaTitle),
        actions: const [CityChip(), SizedBox(width: 12)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.near_me_outlined,
                    value: '${context.n(qibla.round())}°',
                    label: _direction(l, qibla),
                  ),
                ),
                Container(width: .7, height: 40, color: Palette.rule),
                Expanded(
                  child: _Stat(
                    icon: Icons.straighten_rounded,
                    value: km == null ? '—' : context.n(money(km)),
                    label: l.kmToKaaba,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: GestureDetector(
              onPanUpdate: (d) =>
                  setState(() => _heading = (_heading - d.delta.dx * .6) % 360),
              child: SizedBox(
                width: 300,
                height: 300,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: -_heading),
                  duration: const Duration(milliseconds: 120),
                  builder: (_, a, _) => Transform.rotate(
                    angle: a * math.pi / 180,
                    child: CustomPaint(
                      painter: _DialPainter(
                        qibla: qibla,
                        aligned: aligned,
                        labels: [
                          l.compassN,
                          l.compassE,
                          l.compassS,
                          l.compassW,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: aligned ? Palette.green : Palette.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: aligned ? Palette.green : Palette.rule,
                ),
              ),
              child: Text(
                aligned
                    ? l.facingQibla
                    : (off > 0
                          ? l.turnRight(context.n(off.round()))
                          : l.turnLeft(context.n((-off).round()))),
                style: Fonts.body(
                  16,
                  weight: FontWeight.w600,
                  color: aligned ? Palette.cream : Palette.ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              l.dragHint,
              style: Fonts.body(13, color: Palette.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Palette.green),
        const SizedBox(height: 4),
        Text(value, style: Fonts.display(22)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Fonts.body(12, color: Palette.inkSoft),
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.qibla,
    required this.aligned,
    required this.labels,
  });

  final double qibla;
  final bool aligned;

  /// N, E, S, W in the UI language.
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    canvas.drawCircle(c, r, Paint()..color = Palette.paperDeep);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = aligned ? Palette.green : Palette.rule
        ..style = PaintingStyle.stroke
        ..strokeWidth = aligned ? 3 : 1,
    );
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: c, radius: r * .62)),
    );
    canvas.translate(c.dx - r, c.dy - r);
    _patternPaint(canvas, Size(r * 2, r * 2));
    canvas.restore();

    final tick = Paint()..strokeCap = StrokeCap.round;
    for (var d = 0; d < 360; d += 5) {
      final major = d % 30 == 0;
      final t = (d - 90) * math.pi / 180;
      final dir = Offset(math.cos(t), math.sin(t));
      tick
        ..color = major ? Palette.ink : Palette.inkSoft.withValues(alpha: .5)
        ..strokeWidth = major ? 1.4 : .8;
      canvas.drawLine(
        c + dir * (r - 6),
        c + dir * (r - (major ? 18 : 12)),
        tick,
      );
    }

    for (final (i, label) in labels.indexed) {
      final t = (i * 90 - 90) * math.pi / 180;
      final p = c + Offset(math.cos(t), math.sin(t)) * (r - 34);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: Fonts.display(17, color: i == 0 ? Palette.clay : Palette.ink),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    final q = (qibla - 90) * math.pi / 180;
    final qd = Offset(math.cos(q), math.sin(q));
    final needle = Paint()
      ..color = aligned ? Palette.green : Palette.brass
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c, c + qd * (r * .7), needle);
    canvas.drawCircle(c, 5, Paint()..color = Palette.ink);

    // Kaaba glyph at the needle tip
    final tip = c + qd * (r * .7 + 12);
    final kaaba = Rect.fromCenter(center: tip, width: 16, height: 16);
    canvas.drawRect(kaaba, Paint()..color = Palette.ink);
    canvas.drawRect(
      Rect.fromLTWH(kaaba.left, kaaba.top + 3.5, 16, 2.2),
      Paint()..color = Palette.brass,
    );
  }

  void _patternPaint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Palette.ink.withValues(alpha: .07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    const cell = 34.0;
    for (double y = 0; y < size.height + cell; y += cell) {
      for (double x = 0; x < size.width + cell; x += cell) {
        final rect = Rect.fromCenter(
          center: Offset(x, y),
          width: cell * .6,
          height: cell * .6,
        );
        canvas.drawRect(rect, paint);
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: cell * .6,
            height: cell * .6,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.aligned != aligned ||
      old.qibla != qibla ||
      old.labels.join() != labels.join();
}
