import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colourways for the AR prayer mat.
enum MatStyle {
  emerald(
    field: Color(0xFF1E4D3A),
    band: Color(0xFF0F2E22),
    ornament: Color(0xFFE8C06A),
    accent: Color(0xFFB0812F),
  ),
  navy(
    field: Color(0xFF1B2238),
    band: Color(0xFFC8955A),
    ornament: Color(0xFFE2B47A),
    accent: Color(0xFF7A4B26),
  ),
  crimson(
    field: Color(0xFF8E1B24),
    band: Color(0xFF2A1830),
    ornament: Color(0xFFF1D9A6),
    accent: Color(0xFF3F6E8C),
  ),
  royal(
    field: Color(0xFF55206A),
    band: Color(0xFF8E1B4E),
    ornament: Color(0xFFF2C46B),
    accent: Color(0xFFE77FB0),
  );

  const MatStyle({
    required this.field,
    required this.band,
    required this.ornament,
    required this.accent,
  });

  final Color field;
  final Color band;
  final Color ornament;
  final Color accent;
}

/// A prayer mat with its head (the mihrab) at the top of the canvas.
class PrayerMatPainter extends CustomPainter {
  const PrayerMatPainter({required this.style, this.glow = false});

  final MatStyle style;

  /// Brightens the gold when the mat faces the Qibla.
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final gold = glow
        ? Color.lerp(style.ornament, Colors.white, .35)!
        : style.ornament;
    final outer = Rect.fromLTWH(0, 0, w, h);

    canvas.drawRect(
      outer.shift(Offset(0, w * .04)),
      Paint()
        ..color = Colors.black.withValues(alpha: .4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * .05),
    );
    canvas.drawRect(outer, Paint()..color = style.band);

    // Border band with a repeating motif.
    final bandW = w * .12;
    final field = outer.deflate(bandW);
    final line = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke;
    canvas.drawRect(outer.deflate(w * .025), line..strokeWidth = w * .008);
    canvas.drawRect(field.inflate(w * .02), line..strokeWidth = w * .006);
    final motif = Paint()..color = gold;
    final step = bandW * 1.1;
    void bandRow(double y, double from, double to) {
      for (var x = from + step / 2; x < to; x += step) {
        _diamond(canvas, Offset(x, y), bandW * .26, motif);
      }
    }

    void bandCol(double x, double from, double to) {
      for (var y = from + step / 2; y < to; y += step) {
        _diamond(canvas, Offset(x, y), bandW * .26, motif);
      }
    }

    bandRow(bandW / 2, bandW, w - bandW);
    bandRow(h - bandW / 2, bandW, w - bandW);
    bandCol(bandW / 2, 0, h);
    bandCol(w - bandW / 2, 0, h);

    canvas.drawRect(field, Paint()..color = style.field);

    // Faint lattice across the field.
    canvas.save();
    canvas.clipRect(field);
    final lattice = Paint()
      ..color = gold.withValues(alpha: .12)
      ..strokeWidth = w * .004;
    final cell = w * .11;
    for (var d = -h; d < w + h; d += cell) {
      canvas.drawLine(Offset(d, 0), Offset(d + h, h), lattice);
      canvas.drawLine(Offset(d, 0), Offset(d - h, h), lattice);
    }
    canvas.restore();

    // Mihrab arch at the head.
    final ax = field.left + field.width * .12;
    final aw = field.width * .76;
    final top = field.top + field.height * .04;
    final base = field.top + field.height * .3;
    final arch = Path()
      ..moveTo(ax, base)
      ..lineTo(ax, top + field.height * .12)
      ..quadraticBezierTo(ax, top + field.height * .02, ax + aw / 2, top)
      ..quadraticBezierTo(
        ax + aw,
        top + field.height * .02,
        ax + aw,
        top + field.height * .12,
      )
      ..lineTo(ax + aw, base)
      ..close();
    canvas.drawPath(
      arch,
      Paint()..color = Color.lerp(style.field, Colors.black, .25)!,
    );
    canvas.drawPath(
      arch,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .012,
    );
    final lamp = Offset(ax + aw / 2, top + field.height * .17);
    canvas.drawLine(
      Offset(lamp.dx, top + field.height * .015),
      lamp,
      Paint()
        ..color = gold
        ..strokeWidth = w * .006,
    );
    final lampPath = Path()
      ..moveTo(lamp.dx - w * .045, lamp.dy)
      ..lineTo(lamp.dx + w * .045, lamp.dy)
      ..lineTo(lamp.dx + w * .025, lamp.dy + w * .06)
      ..lineTo(lamp.dx - w * .025, lamp.dy + w * .06)
      ..close();
    canvas.drawPath(lampPath, Paint()..color = gold);
    canvas.drawCircle(
      Offset(lamp.dx, lamp.dy + w * .075),
      w * .012,
      Paint()..color = style.accent,
    );

    // Central medallion.
    final c = Offset(field.center.dx, field.top + field.height * .64);
    final r = field.width * .3;
    _star(canvas, c, r, Paint()..color = gold);
    _star(canvas, c, r * .82, Paint()..color = style.field);
    canvas.drawCircle(c, r * .55, Paint()..color = style.accent);
    canvas.drawCircle(
      c,
      r * .55,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .008,
    );
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * r * .35,
        r * .1,
        Paint()..color = gold,
      );
    }
    canvas.drawCircle(c, r * .14, Paint()..color = gold);

    // Corner quarter-medallions at the foot.
    final corner = Paint()..color = gold.withValues(alpha: .85);
    canvas.save();
    canvas.clipRect(field);
    canvas.drawCircle(field.bottomLeft, field.width * .16, corner);
    canvas.drawCircle(field.bottomRight, field.width * .16, corner);
    canvas.drawCircle(
      field.bottomLeft,
      field.width * .11,
      Paint()..color = style.field,
    );
    canvas.drawCircle(
      field.bottomRight,
      field.width * .11,
      Paint()..color = style.field,
    );
    canvas.restore();

    // Fringe at both ends.
    final fringe = Paint()
      ..color = const Color(0xFFF4EFE6).withValues(alpha: .85)
      ..strokeWidth = w * .007;
    final len = w * .05;
    for (var x = w * .03; x <= w * .97; x += w * .035) {
      canvas.drawLine(Offset(x, 0), Offset(x, -len), fringe);
      canvas.drawLine(Offset(x, h), Offset(x, h + len), fringe);
    }
  }

  void _diamond(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy)
        ..close(),
      paint,
    );
  }

  /// Eight-pointed star from two overlapping squares.
  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final s = r * .72;
    canvas.drawRect(
      Rect.fromCenter(center: c, width: s * 2, height: s * 2),
      paint,
    );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: s * 2, height: s * 2),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(PrayerMatPainter old) =>
      old.style != style || old.glow != glow;
}
