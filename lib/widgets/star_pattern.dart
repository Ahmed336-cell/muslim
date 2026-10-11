import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Line-work tiling of eight-pointed stars (khatam), drawn as a single stroke.
class StarPattern extends StatelessWidget {
  const StarPattern({
    super.key,
    this.color = const Color(0x22000000),
    this.cell = 44,
    this.stroke = 0.8,
  });

  final Color color;
  final double cell;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(color, cell, stroke),
      size: Size.infinite,
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.color, this.cell, this.stroke);

  final Color color;
  final double cell;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final r = cell * 0.42;
    for (double y = 0; y < size.height + cell; y += cell) {
      for (double x = 0; x < size.width + cell; x += cell) {
        _star(canvas, Offset(x, y), r, paint);
      }
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final a = Path();
    final b = Path();
    for (var i = 0; i < 4; i++) {
      final t1 = i * math.pi / 2;
      final t2 = t1 + math.pi / 4;
      final p1 = c + Offset(math.cos(t1), math.sin(t1)) * r;
      final p2 = c + Offset(math.cos(t2), math.sin(t2)) * r;
      i == 0 ? a.moveTo(p1.dx, p1.dy) : a.lineTo(p1.dx, p1.dy);
      i == 0 ? b.moveTo(p2.dx, p2.dy) : b.lineTo(p2.dx, p2.dy);
    }
    a.close();
    b.close();
    canvas.drawPath(a, paint);
    canvas.drawPath(b, paint);
    canvas.drawCircle(c, r * 0.28, paint);
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.color != color || old.cell != cell;
}

/// Small eight-point star used as a bullet / ornament.
class StarMark extends StatelessWidget {
  const StarMark({
    super.key,
    this.size = 10,
    this.color = const Color(0xFFB0812F),
    this.filled = true,
  });

  final double size;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MarkPainter(color, filled)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color, this.filled);

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final t = i * math.pi / 8 - math.pi / 2;
      final rr = i.isEven ? r : r * 0.62;
      final p = c + Offset(math.cos(t), math.sin(t)) * rr;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.color != color || old.filled != filled;
}
