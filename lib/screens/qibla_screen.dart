import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/tab_cubit.dart';
import '../format.dart';
import '../l10n/l10n.dart';
import '../services/heading.dart';
import '../theme.dart';
import '../widgets/city_picker.dart';
import '../widgets/common.dart';
import 'qibla_ar_screen.dart';

const cairoQibla = 136.14;

/// Live compass from the heading sensor; dragging the dial is the fallback
/// on devices without one.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

enum _Sensor { none, live, weak }

class _QiblaScreenState extends State<QiblaScreen> {
  /// Unwrapped so the dial turns the short way across north.
  double _dial = 0;
  double get _heading => _dial % 360;
  bool _wasAligned = false;
  _Sensor _sensor = _Sensor.none;
  StreamSubscription<Heading>? _sub;

  /// Android reports magnetic north; iOS already reports true north.
  double _declination = 0;

  @override
  void initState() {
    super.initState();
    _listen(context.read<TabCubit>().state == AppTab.qibla);
    _loadDeclination();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// The tab stays alive in an IndexedStack; only read the sensor on screen.
  void _listen(bool on) {
    if (on) {
      _sub ??= headingStream()?.listen(_onHeading, onError: (_) {});
    } else {
      _sub?.cancel();
      _sub = null;
    }
  }

  Future<void> _loadDeclination() async {
    final place = context.read<SettingsCubit>().state.place;
    final d = await magneticDeclination(place.lat, place.lon);
    if (mounted && d != 0) setState(() => _declination = d);
  }

  /// Hands the sensor to the AR view while it is open.
  Future<void> _openAr() async {
    _listen(false);
    await Navigator.of(context).push(QiblaArScreen.route());
    if (mounted) _listen(context.read<TabCubit>().state == AppTab.qibla);
  }

  void _onHeading(Heading e) {
    final (raw, accuracy) = e;
    // Android reports -180..180; % maps it onto 0..360.
    final h = (raw + _declination) % 360;
    setState(() {
      _sensor = accuracy != null && accuracy > 30 ? _Sensor.weak : _Sensor.live;
      _dial += turnTo(h, _heading);
    });
  }

  String _hint(L10n l) => switch (_sensor) {
    _Sensor.none => l.dragHint,
    _Sensor.live => l.compassHold,
    _Sensor.weak => l.compassCalibrate,
  };

  bool get _manual => _sensor == _Sensor.none;

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
    final off = turnTo(qibla, _heading);
    final aligned = off.abs() < 4;
    if (aligned && !_wasAligned) HapticFeedback.mediumImpact();
    _wasAligned = aligned;

    return BlocListener<TabCubit, AppTab>(
      listener: (_, tab) => _listen(tab == AppTab.qibla),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.qiblaTitle),
          actions: [
            IconButton(
              tooltip: l.qiblaAr,
              onPressed: _openAr,
              icon: const Icon(Icons.view_in_ar_rounded),
            ),
            const CityChip(),
            const SizedBox(width: 12),
          ],
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
            const SizedBox(height: 4),
            // Fixed marker for where the phone points; line the Kaaba up with it.
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 40,
              color: aligned ? Palette.green : Palette.brass,
            ),
            Center(
              child: GestureDetector(
                onPanUpdate: _manual
                    ? (d) => setState(() => _dial -= d.delta.dx * .6)
                    : null,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: -_dial),
                    duration: const Duration(milliseconds: 32),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _hint(l),
                textAlign: TextAlign.center,
                style: Fonts.body(
                  13,
                  color: _sensor == _Sensor.weak
                      ? Palette.clay
                      : Palette.inkSoft,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: _openAr,
                icon: const Icon(Icons.view_in_ar_rounded),
                label: Text(l.qiblaAr),
              ),
            ),
          ],
        ),
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
