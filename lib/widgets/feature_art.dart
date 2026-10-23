import 'package:flutter/material.dart';

import 'features.dart';

/// Flat illustrated glyph for Explore tiles — same spirit as mushaf-on-rehal art.
class FeatureArt extends StatelessWidget {
  const FeatureArt({super.key, required this.feature, this.size = 44});

  final Feature feature;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = feature.artAsset;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(size * .28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * .28),
          child: asset != null
              ? Padding(
                  padding: EdgeInsets.all(size * .06),
                  child: Image.asset(asset, fit: BoxFit.contain),
                )
              : CustomPaint(painter: _GlyphPainter(feature)),
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.feature);

  final Feature feature;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    switch (feature) {
      case Feature.quran:
        _quran(canvas, c, s);
      case Feature.prayer:
        _mosque(canvas, c, s);
      case Feature.qibla:
        _compass(canvas, c, s);
      case Feature.tasbih:
        _beads(canvas, c, s);
      case Feature.azkar:
      case Feature.hisn:
        _crescent(canvas, c, s);
      case Feature.sleep:
        _moonStar(canvas, c, s);
      case Feature.reciters:
      case Feature.tawashih:
        _headphones(canvas, c, s, music: feature == Feature.tawashih);
      case Feature.radio:
        _radio(canvas, c, s);
      case Feature.hadith:
      case Feature.books:
      case Feature.duas:
        _book(canvas, c, s, open: feature != Feature.hadith);
      case Feature.fasting:
      case Feature.ramadan:
        _lantern(canvas, c, s);
      case Feature.hajj:
        _kaaba(canvas, c, s);
      case Feature.kids:
        _balloon(canvas, c, s);
      case Feature.names:
        _spark(canvas, c, s);
      case Feature.zakat:
      case Feature.sadaqah:
        _coin(canvas, c, s, heart: feature == Feature.sadaqah);
      case Feature.calendar:
      case Feature.friday:
        _calendar(canvas, c, s);
      case Feature.travel:
        _plane(canvas, c, s);
      case Feature.tracker:
        _chart(canvas, c, s);
      case Feature.ruqyah:
        _shield(canvas, c, s);
      case Feature.learn:
      case Feature.tajweed:
        _school(canvas, c, s);
      case Feature.hifz:
        _brain(canvas, c, s);
      case Feature.khatmah:
        _flag(canvas, c, s);
      case Feature.qada:
        _repeat(canvas, c, s);
    }
  }

  void _quran(Canvas canvas, Offset c, double s) {
    final wood = Paint()..color = const Color(0xFFC47A3A);
    final woodDark = Paint()..color = const Color(0xFF8B5A2B);
    final cover = Paint()..color = const Color(0xFF1E4D3A);
    final page = Paint()..color = const Color(0xFFF5E6B8);
    final line = Paint()
      ..color = const Color(0xFF1E4D3A)
      ..strokeWidth = s * .03
      ..strokeCap = StrokeCap.round;
    final ribbon = Paint()..color = const Color(0xFFC62828);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * .12), width: s * .55, height: s * .18),
        Radius.circular(s * .04),
      ),
      wood,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * .22), width: s * .42, height: s * .1),
        Radius.circular(s * .03),
      ),
      woodDark,
    );
    final left = RRect.fromRectAndRadius(
      Rect.fromLTWH(c.dx - s * .34, c.dy - s * .28, s * .32, s * .34),
      Radius.circular(s * .04),
    );
    final right = RRect.fromRectAndRadius(
      Rect.fromLTWH(c.dx + s * .02, c.dy - s * .28, s * .32, s * .34),
      Radius.circular(s * .04),
    );
    canvas.drawRRect(left.inflate(s * .03), cover);
    canvas.drawRRect(right.inflate(s * .03), cover);
    canvas.drawRRect(left, page);
    canvas.drawRRect(right, page);
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * .16 + i * s * .08;
      canvas.drawLine(Offset(c.dx - s * .28, y), Offset(c.dx - s * .08, y), line);
      canvas.drawLine(Offset(c.dx + s * .08, y), Offset(c.dx + s * .28, y), line);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * .02), width: s * .07, height: s * .2),
        Radius.circular(s * .02),
      ),
      ribbon,
    );
  }

  void _mosque(Canvas canvas, Offset c, double s) {
    final green = Paint()..color = const Color(0xFF1E4D3A);
    final soft = Paint()..color = const Color(0xFF3D7A5A);
    final gold = Paint()..color = const Color(0xFFB0812F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * .12), width: s * .55, height: s * .32),
        Radius.circular(s * .04),
      ),
      green,
    );
    canvas.drawCircle(c.translate(0, -s * .08), s * .18, soft);
    canvas.drawCircle(c.translate(0, -s * .28), s * .05, gold);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * .16), width: s * .16, height: s * .2),
        Radius.circular(s * .03),
      ),
      Paint()..color = const Color(0xFFF5E6B8),
    );
  }

  void _radio(Canvas canvas, Offset c, double s) {
    final body = Paint()..color = const Color(0xFF1E4D3A);
    final gold = Paint()..color = const Color(0xFFB0812F);
    final cream = Paint()..color = const Color(0xFFF5E6B8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c.translate(0, s * .08),
          width: s * .5,
          height: s * .32,
        ),
        Radius.circular(s * .06),
      ),
      body,
    );
    canvas.drawCircle(c.translate(-s * .1, s * .08), s * .07, cream);
    canvas.drawCircle(c.translate(-s * .1, s * .08), s * .03, gold);
    final wave = Paint()
      ..color = const Color(0xFFE0B860)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .025
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i <= 3; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: c.translate(s * .06, s * .02),
          width: s * .1 * i,
          height: s * .12 * i,
        ),
        -0.9,
        1.8,
        false,
        wave,
      );
    }
  }

  void _compass(Canvas canvas, Offset c, double s) {
    final ring = Paint()
      ..color = const Color(0xFF2A7A8C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .07;
    final fill = Paint()..color = const Color(0xFFE8F4F6);
    canvas.drawCircle(c, s * .28, fill);
    canvas.drawCircle(c, s * .28, ring);
    final needle = Path()
      ..moveTo(c.dx, c.dy - s * .22)
      ..lineTo(c.dx + s * .08, c.dy + s * .04)
      ..lineTo(c.dx, c.dy + s * .02)
      ..lineTo(c.dx - s * .08, c.dy + s * .04)
      ..close();
    canvas.drawPath(needle, Paint()..color = const Color(0xFFC62828));
    canvas.drawCircle(c, s * .045, Paint()..color = const Color(0xFFB0812F));
  }

  void _beads(Canvas canvas, Offset c, double s) {
    final bead = Paint()..color = const Color(0xFFB0812F);
    final dark = Paint()..color = const Color(0xFF8B5E3C);
    for (var i = 0; i < 7; i++) {
      final a = -1.2 + i * .4;
      final p = c + Offset.fromDirection(a, s * .22);
      canvas.drawCircle(p, s * .07, i.isEven ? bead : dark);
    }
    canvas.drawCircle(c.translate(0, s * .26), s * .09, Paint()..color = const Color(0xFFA9512F));
  }

  void _crescent(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c, s * .26, Paint()..color = const Color(0xFFC47A2C));
    canvas.drawCircle(
      c.translate(s * .08, -s * .04),
      s * .2,
      Paint()..color = const Color(0xFFF0EBE3),
    );
    canvas.drawCircle(c.translate(s * .16, -s * .14), s * .05, Paint()..color = const Color(0xFFB0812F));
  }

  void _moonStar(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c.translate(-s * .06, 0), s * .24, Paint()..color = const Color(0xFF4A5B8C));
    canvas.drawCircle(
      c.translate(s * .04, -s * .04),
      s * .18,
      Paint()..color = const Color(0xFFF0EBE3),
    );
    final star = Path()
      ..moveTo(c.dx + s * .18, c.dy - s * .18)
      ..lineTo(c.dx + s * .22, c.dy - s * .08)
      ..lineTo(c.dx + s * .32, c.dy - s * .08)
      ..lineTo(c.dx + s * .24, c.dy - s * .02)
      ..lineTo(c.dx + s * .27, c.dy + s * .08)
      ..lineTo(c.dx + s * .18, c.dy + s * .02)
      ..lineTo(c.dx + s * .09, c.dy + s * .08)
      ..lineTo(c.dx + s * .12, c.dy - s * .02)
      ..lineTo(c.dx + s * .04, c.dy - s * .08)
      ..lineTo(c.dx + s * .14, c.dy - s * .08)
      ..close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFB0812F));
  }

  void _headphones(Canvas canvas, Offset c, double s, {required bool music}) {
    final band = Paint()
      ..color = const Color(0xFF8B5E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .08
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: c.translate(0, -s * .02), width: s * .5, height: s * .42),
      3.5,
      2.4,
      false,
      band,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(-s * .22, s * .06), width: s * .12, height: s * .22),
        Radius.circular(s * .04),
      ),
      Paint()..color = const Color(0xFFA9512F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(s * .22, s * .06), width: s * .12, height: s * .22),
        Radius.circular(s * .04),
      ),
      Paint()..color = const Color(0xFFA9512F),
    );
    if (music) {
      canvas.drawCircle(c.translate(s * .02, s * .02), s * .08, Paint()..color = const Color(0xFFB0812F));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(c.dx + s * .02, c.dy - s * .18, s * .05, s * .18),
          Radius.circular(s * .02),
        ),
        Paint()..color = const Color(0xFFB0812F),
      );
    }
  }

  void _book(Canvas canvas, Offset c, double s, {required bool open}) {
    final cover = Paint()..color = const Color(0xFF1E4D3A);
    final page = Paint()..color = const Color(0xFFF5E6B8);
    if (open) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c.translate(-s * .12, 0), width: s * .28, height: s * .4),
          Radius.circular(s * .04),
        ),
        cover,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c.translate(s * .12, 0), width: s * .28, height: s * .4),
          Radius.circular(s * .04),
        ),
        page,
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: s * .42, height: s * .48),
          Radius.circular(s * .05),
        ),
        cover,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c.translate(s * .02, 0), width: s * .32, height: s * .38),
          Radius.circular(s * .03),
        ),
        page,
      );
    }
  }

  void _lantern(Canvas canvas, Offset c, double s) {
    final body = Paint()..color = const Color(0xFFB0812F);
    final glow = Paint()..color = const Color(0xFFF5E6B8);
    final top = Paint()..color = const Color(0xFF8B5E3C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, -s * .22), width: s * .22, height: s * .1),
        Radius.circular(s * .03),
      ),
      top,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * .32, height: s * .38),
        Radius.circular(s * .06),
      ),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * .18, height: s * .22),
        Radius.circular(s * .03),
      ),
      glow,
    );
  }

  void _kaaba(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * .42, height: s * .42),
        Radius.circular(s * .04),
      ),
      Paint()..color = const Color(0xFF1A1A1A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, -s * .08), width: s * .42, height: s * .08),
        Radius.circular(s * .02),
      ),
      Paint()..color = const Color(0xFFB0812F),
    );
  }

  void _balloon(Canvas canvas, Offset c, double s) {
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, -s * .06), width: s * .36, height: s * .42),
      Paint()..color = const Color(0xFFD17A45),
    );
    canvas.drawLine(
      c.translate(0, s * .16),
      c.translate(0, s * .3),
      Paint()
        ..color = const Color(0xFF8B5E3C)
        ..strokeWidth = s * .03,
    );
  }

  void _spark(Canvas canvas, Offset c, double s) {
    final p = Paint()..color = const Color(0xFFB0812F);
    for (var i = 0; i < 4; i++) {
      final a = i * 1.57;
      canvas.drawLine(
        c + Offset.fromDirection(a, s * .06),
        c + Offset.fromDirection(a, s * .28),
        p
          ..strokeWidth = s * .07
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(c, s * .08, Paint()..color = const Color(0xFFF5E6B8));
  }

  void _coin(Canvas canvas, Offset c, double s, {required bool heart}) {
    canvas.drawCircle(c, s * .26, Paint()..color = const Color(0xFFB0812F));
    canvas.drawCircle(c, s * .18, Paint()..color = const Color(0xFFF5E6B8));
    if (heart) {
      canvas.drawCircle(c.translate(-s * .05, -s * .02), s * .07, Paint()..color = const Color(0xFFA9512F));
      canvas.drawCircle(c.translate(s * .05, -s * .02), s * .07, Paint()..color = const Color(0xFFA9512F));
      final h = Path()
        ..moveTo(c.dx - s * .11, c.dy)
        ..lineTo(c.dx, c.dy + s * .12)
        ..lineTo(c.dx + s * .11, c.dy)
        ..close();
      canvas.drawPath(h, Paint()..color = const Color(0xFFA9512F));
    } else {
      canvas.drawCircle(c, s * .08, Paint()..color = const Color(0xFF1E4D3A));
    }
  }

  void _calendar(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * .44, height: s * .42),
        Radius.circular(s * .06),
      ),
      Paint()..color = const Color(0xFF2F6B9A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * .06), width: s * .44, height: s * .28),
        Radius.circular(s * .04),
      ),
      Paint()..color = const Color(0xFFF5E6B8),
    );
  }

  void _plane(Canvas canvas, Offset c, double s) {
    final p = Path()
      ..moveTo(c.dx - s * .28, c.dy + s * .04)
      ..lineTo(c.dx + s * .28, c.dy - s * .02)
      ..lineTo(c.dx + s * .1, c.dy + s * .06)
      ..lineTo(c.dx - s * .05, c.dy + s * .2)
      ..lineTo(c.dx - s * .12, c.dy + s * .08)
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFF3B6EA5));
  }

  void _chart(Canvas canvas, Offset c, double s) {
    final bar = Paint()..color = const Color(0xFF2F6B9A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - s * .22, c.dy + s * .02, s * .1, s * .2),
        Radius.circular(s * .02),
      ),
      bar,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - s * .05, c.dy - s * .1, s * .1, s * .32),
        Radius.circular(s * .02),
      ),
      Paint()..color = const Color(0xFF3D7A5A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx + s * .12, c.dy - s * .02, s * .1, s * .24),
        Radius.circular(s * .02),
      ),
      Paint()..color = const Color(0xFFB0812F),
    );
  }

  void _shield(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx, c.dy - s * .28)
      ..lineTo(c.dx + s * .24, c.dy - s * .14)
      ..lineTo(c.dx + s * .2, c.dy + s * .1)
      ..lineTo(c.dx, c.dy + s * .28)
      ..lineTo(c.dx - s * .2, c.dy + s * .1)
      ..lineTo(c.dx - s * .24, c.dy - s * .14)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF4A5B8C));
    canvas.drawCircle(c, s * .08, Paint()..color = const Color(0xFFF5E6B8));
  }

  void _school(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * .06), width: s * .48, height: s * .32),
        Radius.circular(s * .04),
      ),
      Paint()..color = const Color(0xFF2F6B9A),
    );
    final roof = Path()
      ..moveTo(c.dx - s * .28, c.dy - s * .06)
      ..lineTo(c.dx, c.dy - s * .28)
      ..lineTo(c.dx + s * .28, c.dy - s * .06)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFA9512F));
  }

  void _brain(Canvas canvas, Offset c, double s) {
    canvas.drawOval(
      Rect.fromCenter(center: c, width: s * .48, height: s * .4),
      Paint()..color = const Color(0xFF6B5B95),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(-s * .08, 0), width: s * .2, height: s * .28),
      Paint()..color = const Color(0xFF8B7BB5),
    );
  }

  void _flag(Canvas canvas, Offset c, double s) {
    canvas.drawLine(
      c.translate(-s * .16, -s * .26),
      c.translate(-s * .16, s * .28),
      Paint()
        ..color = const Color(0xFF8B5E3C)
        ..strokeWidth = s * .05
        ..strokeCap = StrokeCap.round,
    );
    final flag = Path()
      ..moveTo(c.dx - s * .14, c.dy - s * .24)
      ..lineTo(c.dx + s * .24, c.dy - s * .12)
      ..lineTo(c.dx - s * .14, c.dy)
      ..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFFB0812F));
  }

  void _repeat(Canvas canvas, Offset c, double s) {
    final p = Paint()
      ..color = const Color(0xFF3D7A5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .07
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: c, width: s * .42, height: s * .42), .4, 4.2, false, p);
    final arrow = Path()
      ..moveTo(c.dx + s * .14, c.dy - s * .22)
      ..lineTo(c.dx + s * .26, c.dy - s * .1)
      ..lineTo(c.dx + s * .1, c.dy - s * .08)
      ..close();
    canvas.drawPath(arrow, Paint()..color = const Color(0xFF3D7A5A));
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) => old.feature != feature;
}
