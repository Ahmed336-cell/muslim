import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../format.dart';
import '../l10n/l10n.dart';
import '../services/heading.dart';
import '../theme.dart';
import '../widgets/prayer_mat.dart';
import 'qibla_screen.dart' show cairoQibla;

/// Camera view with the Kaaba marker over the surroundings and a prayer mat
/// on the floor that turns to face the Qibla.
class QiblaArScreen extends StatefulWidget {
  const QiblaArScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const QiblaArScreen());

  @override
  State<QiblaArScreen> createState() => _QiblaArScreenState();
}

/// Roughly the horizontal field of view of a phone's main camera in portrait.
const _halfFov = 32.0;
const _green = Color(0xFF1E4D3A);
const _brass = Color(0xFFB0812F);
const _brassLight = Color(0xFFE8C06A);

class _QiblaArScreenState extends State<QiblaArScreen>
    with WidgetsBindingObserver {
  CameraController? _camera;
  bool _cameraFailed = false;
  StreamSubscription<Heading>? _sub;
  double _declination = 0;

  /// Unwrapped and smoothed so the overlay glides instead of jittering.
  double? _heading;
  bool _weak = false;
  bool _wasAligned = false;
  MatStyle _mat = _savedMat();

  static const _matKey = 'qiblaArMat';

  static MatStyle _savedMat() {
    final name = HydratedBloc.storage.read(_matKey);
    return MatStyle.values.firstWhere(
      (m) => m.name == name,
      orElse: () => MatStyle.emerald,
    );
  }

  void _pickMat(MatStyle m) {
    HapticFeedback.selectionClick();
    setState(() => _mat = m);
    HydratedBloc.storage.write(_matKey, m.name);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _startCamera();
    _sub = cameraHeadingStream()?.listen(_onHeading, onError: (_) {});
    final place = context.read<SettingsCubit>().state.place;
    magneticDeclination(place.lat, place.lon).then((d) {
      if (mounted) _declination = d;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([]);
    _sub?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final c = _camera;
      _camera = null;
      c?.dispose();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      _startCamera();
    }
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final c = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await c.initialize();
      if (!mounted) return c.dispose();
      setState(() {
        _camera = c;
        _cameraFailed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cameraFailed = true);
    }
  }

  void _onHeading(Heading e) {
    final (raw, accuracy) = e;
    final h = (raw + _declination) % 360;
    setState(() {
      final current = _heading;
      _heading = current == null ? h : current + turnTo(h, current % 360) * .35;
      _weak = accuracy != null && accuracy > 30;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final day = context.select((PrayerTimesBloc b) => b.state.day);
    final qibla = day?.qiblaDegrees ?? cairoQibla;
    final km = day?.qiblaKm;
    final heading = _heading;
    final off = heading == null ? null : turnTo(qibla, heading % 360);
    final aligned = off != null && off.abs() < 4;
    if (aligned && !_wasAligned) HapticFeedback.heavyImpact();
    _wasAligned = aligned;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _Background(camera: _camera),
          // Scrims keep the overlay legible on bright scenes.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0xB3000000),
                ],
                stops: [0, .22, .6, 1],
              ),
            ),
          ),
          if (off != null) ...[
            _KaabaMarker(off: off, aligned: aligned, km: km),
            _Mat(off: off, aligned: aligned, style: _mat),
          ],
          Positioned(
            right: 12,
            top: MediaQuery.paddingOf(context).top + 120,
            child: _MatPicker(selected: _mat, onPick: _pickMat),
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(title: l.qiblaAr),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    _cameraFailed
                        ? l.qiblaArNoCamera
                        : _weak
                        ? l.compassCalibrate
                        : l.qiblaArHint,
                    textAlign: TextAlign.center,
                    style: Fonts.body(
                      13.5,
                      color: _weak ? _brassLight : Colors.white,
                    ).copyWith(shadows: _shadow),
                  ),
                ),
                if (_cameraFailed)
                  TextButton(
                    onPressed: Geolocator.openAppSettings,
                    child: Text(
                      l.openSettings,
                      style: Fonts.body(
                        14,
                        weight: FontWeight.w600,
                        color: _brassLight,
                      ),
                    ),
                  ),
                const Spacer(),
                if (off == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      l.dragHint,
                      style: Fonts.body(13, color: Colors.white70),
                    ),
                  )
                else
                  _TurnPill(off: off, aligned: aligned),
                AnimatedOpacity(
                  opacity: aligned ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      l.qiblaArPray,
                      style: Fonts.body(
                        15,
                        weight: FontWeight.w600,
                        color: _brassLight,
                      ).copyWith(shadows: _shadow),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _shadow = [Shadow(color: Color(0xAA000000), blurRadius: 8)];

class _Background extends StatelessWidget {
  const _Background({required this.camera});

  final CameraController? camera;

  @override
  Widget build(BuildContext context) {
    final c = camera;
    if (c == null || !c.value.isInitialized) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E241B), Color(0xFF1E4D3A)],
          ),
        ),
      );
    }
    // previewSize is landscape; fill the portrait screen without stretching.
    final size = c.value.previewSize!;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(c),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Fonts.display(
                19,
                color: Colors.white,
              ).copyWith(shadows: _shadow),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// The Kaaba floating where it would be on the horizon, or an edge arrow when
/// it is outside the camera's view.
class _KaabaMarker extends StatelessWidget {
  const _KaabaMarker({
    required this.off,
    required this.aligned,
    required this.km,
  });

  final double off;
  final bool aligned;
  final double? km;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final y = box.maxHeight * .34;
        if (off.abs() > _halfFov + 4) {
          final right = off > 0;
          return Stack(
            children: [
              Positioned(
                top: y,
                left: right ? null : 12,
                right: right ? 12 : null,
                child: Icon(
                  right
                      ? Icons.keyboard_double_arrow_right_rounded
                      : Icons.keyboard_double_arrow_left_rounded,
                  size: 54,
                  color: _brassLight,
                  shadows: _shadow,
                ),
              ),
            ],
          );
        }
        final x = w / 2 + off / _halfFov * (w / 2);
        const size = 72.0;
        return Stack(
          children: [
            Positioned(
              left: x - 70,
              top: y - size / 2,
              width: 140,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: size,
                    height: size,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: .35),
                      border: Border.all(
                        color: aligned ? _brassLight : Colors.white70,
                        width: aligned ? 3 : 1.5,
                      ),
                      boxShadow: [
                        if (aligned)
                          BoxShadow(
                            color: _brassLight.withValues(alpha: .6),
                            blurRadius: 24,
                          ),
                      ],
                    ),
                    child: const CustomPaint(painter: _KaabaPainter()),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.kaaba,
                    style: Fonts.display(
                      16,
                      color: Colors.white,
                    ).copyWith(shadows: _shadow),
                  ),
                  if (km != null)
                    Text(
                      '${context.n(money(km!))} ${l.kmToKaaba}',
                      textAlign: TextAlign.center,
                      style: Fonts.body(
                        11.5,
                        color: Colors.white70,
                      ).copyWith(shadows: _shadow),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The prayer mat lying on the floor; its head (the mihrab) turns toward
/// the Qibla, so it points straight ahead once you are facing it.
class _Mat extends StatelessWidget {
  const _Mat({required this.off, required this.aligned, required this.style});

  final double off;
  final bool aligned;
  final MatStyle style;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width * .74;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, .0009)
      ..rotateX(-.9)
      ..rotateZ(off * math.pi / 180);
    return Align(
      alignment: const Alignment(0, .5),
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: SizedBox(
          width: w,
          height: w * 1.55,
          child: CustomPaint(
            painter: PrayerMatPainter(style: style, glow: aligned),
          ),
        ),
      ),
    );
  }
}

class _MatPicker extends StatelessWidget {
  const _MatPicker({required this.selected, required this.onPick});

  final MatStyle selected;
  final ValueChanged<MatStyle> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final m in MatStyle.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onPick(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: .3),
                  border: Border.all(
                    color: m == selected ? _brassLight : Colors.white38,
                    width: m == selected ? 3 : 1,
                  ),
                ),
                child: ClipOval(
                  child: OverflowBox(
                    maxWidth: 70,
                    maxHeight: 108,
                    child: SizedBox(
                      width: 70,
                      height: 108,
                      child: CustomPaint(painter: PrayerMatPainter(style: m)),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TurnPill extends StatelessWidget {
  const _TurnPill({required this.off, required this.aligned});

  final double off;
  final bool aligned;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: aligned ? _green : Colors.black.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: aligned ? _brassLight : Colors.white24),
      ),
      child: Text(
        aligned
            ? l.facingQibla
            : off > 0
            ? l.turnRight(context.n(off.round()))
            : l.turnLeft(context.n((-off).round())),
        style: Fonts.body(16, weight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

class _KaabaPainter extends CustomPainter {
  const _KaabaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final body = Rect.fromLTWH(w * .12, w * .2, w * .76, w * .66);
    canvas.drawRect(body, Paint()..color = const Color(0xFF111111));
    canvas.drawRect(
      Rect.fromLTWH(
        body.left,
        body.top + body.height * .18,
        body.width,
        w * .1,
      ),
      Paint()..color = _brassLight,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        body.left + body.width * .58,
        body.top + body.height * .42,
        body.width * .2,
        body.height * .58,
      ),
      Paint()..color = _brass,
    );
  }

  @override
  bool shouldRepaint(_KaabaPainter old) => false;
}
