import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class MushafColors {
  static Color get page =>
      Palette.dark ? const Color(0xFF0A0A0A) : const Color(0xFFFFFCF3);
  static Color get green =>
      Palette.dark ? const Color(0xFF3FA372) : const Color(0xFF2F6B4F);
  static Color get band =>
      Palette.dark ? const Color(0xFF0F2219) : const Color(0xFFDCEBD3);
  static Color get flower =>
      Palette.dark ? const Color(0xFF2E8B62) : const Color(0xFFCF7895);
}

/// Small four-petal flower used along the borders.
void _flower(Canvas canvas, Offset c, double r) {
  final petal = Paint()..color = MushafColors.flower;
  for (var i = 0; i < 4; i++) {
    final t = i * math.pi / 2 + math.pi / 4;
    canvas.drawCircle(c + Offset(math.cos(t), math.sin(t)) * r, r * .8, petal);
  }
  canvas.drawCircle(c, r * .6, Paint()..color = Palette.brass);
}

/// Illuminated border around a mushaf page.
class MushafFrame extends StatelessWidget {
  const MushafFrame({super.key, required this.child});

  final Widget child;

  static const band = 12.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(),
      child: Padding(padding: const EdgeInsets.all(band + 8), child: child),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const b = MushafFrame.band;
    final outer = (Offset.zero & size).deflate(1);
    final inner = outer.deflate(b);
    final green = Paint()
      ..color = MushafColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas
      ..drawRect(outer, Paint()..color = MushafColors.band)
      ..drawRect(inner, Paint()..color = MushafColors.page);

    // Flowers along the band.
    const step = 15.0;
    void along(Offset from, Offset to) {
      final len = (to - from).distance;
      final n = (len / step).floor();
      final gap = len / n;
      final dir = (to - from) / len;
      for (var i = 0; i < n; i++) {
        _flower(canvas, from + dir * (gap * (i + .5)), 2.4);
      }
    }

    const h = b / 2;
    along(
      outer.topLeft + const Offset(b, h),
      outer.topRight + const Offset(-b, h),
    );
    along(
      outer.bottomLeft + const Offset(b, -h),
      outer.bottomRight + const Offset(-b, -h),
    );
    along(
      outer.topLeft + const Offset(h, b),
      outer.bottomLeft + const Offset(h, -b),
    );
    along(
      outer.topRight + const Offset(-h, b),
      outer.bottomRight + const Offset(-h, -b),
    );

    for (final c in [
      outer.topLeft,
      outer.topRight + const Offset(-b, 0),
      outer.bottomLeft + const Offset(0, -b),
      outer.bottomRight + const Offset(-b, -b),
    ]) {
      final corner = c & const Size(b, b);
      canvas
        ..drawRect(corner, Paint()..color = MushafColors.green)
        ..drawCircle(corner.center, 2.6, Paint()..color = Palette.brass);
    }

    canvas
      ..drawRect(outer, green)
      ..drawRect(inner, green)
      ..drawRect(
        inner.deflate(3),
        Paint()
          ..color = Palette.brass
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
  }

  @override
  bool shouldRepaint(_FramePainter old) => false;
}

/// Framed surah title, as at the head of each surah in print.
class SurahCartouche extends StatelessWidget {
  const SurahCartouche({super.key, required this.title, required this.height});

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _CartouchePainter(),
        child: Center(
          child: Text(
            title,
            textDirection: TextDirection.rtl,
            textScaler: TextScaler.noScaling,
            style: Fonts.arabic(
              height * .5,
              color: MushafColors.green,
            ).copyWith(height: 1.2),
          ),
        ),
      ),
    );
  }
}

class _CartouchePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path shape(Rect r) {
      final tip = r.height / 2;
      return Path()
        ..moveTo(r.left + tip, r.top)
        ..lineTo(r.right - tip, r.top)
        ..lineTo(r.right, r.center.dy)
        ..lineTo(r.right - tip, r.bottom)
        ..lineTo(r.left + tip, r.bottom)
        ..lineTo(r.left, r.center.dy)
        ..close();
    }

    final outer = (Offset.zero & size).deflate(1);
    canvas
      ..drawPath(shape(outer), Paint()..color = MushafColors.band)
      ..drawPath(
        shape(outer),
        Paint()
          ..color = MushafColors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      )
      ..drawPath(
        shape(outer.deflate(4)),
        Paint()
          ..color = Palette.brass
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
    final r = size.height * .09;
    _flower(canvas, Offset(outer.left + size.height * .55, outer.center.dy), r);
    _flower(
      canvas,
      Offset(outer.right - size.height * .55, outer.center.dy),
      r,
    );
  }

  @override
  bool shouldRepaint(_CartouchePainter old) => false;
}

/// Page number in a small medallion under the frame.
class PageMedallion extends StatelessWidget {
  const PageMedallion(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
      decoration: BoxDecoration(
        color: MushafColors.band,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MushafColors.green, width: .9),
      ),
      child: Text(
        label,
        textScaler: TextScaler.noScaling,
        style: Fonts.arabic(
          13,
          color: MushafColors.green,
        ).copyWith(height: 1.5),
      ),
    );
  }
}
