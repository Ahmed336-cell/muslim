import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tasbih_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

class DhikrScreen extends StatelessWidget {
  const DhikrScreen({super.key});

  void _tap(BuildContext context) {
    switch (context.read<TasbihCubit>().tap()) {
      case TasbihTap.counted:
        HapticFeedback.selectionClick();
      case TasbihTap.dhikrDone:
        HapticFeedback.heavyImpact();
      case TasbihTap.setDone:
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l.setComplete)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<TasbihCubit>().state;
    final current = s.current;
    final ar = context.isAr;
    final long = current.arabic.length > 30;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tasbihTitle),
        actions: [
          TextButton.icon(
            onPressed: context.read<TasbihCubit>().reset,
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
            label: Text(
              l.reset,
              style: Fonts.body(
                14,
                color: Palette.clay,
                weight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _tap(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  for (var i = 0; i < adhkar.length; i++) ...[
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: i < s.index
                              ? Palette.green
                              : (i == s.index ? Palette.brass : Palette.rule),
                        ),
                      ),
                    ),
                    if (i != adhkar.length - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.afterSalah(context.n(s.index + 1), context.n(adhkar.length)),
                style: Fonts.body(13, color: Palette.inkSoft),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final size = math.min(280.0, box.biggest.shortestSide);
                    return Center(
                      child: SizedBox.square(
                        dimension: size,
                        child: CustomPaint(
                          painter: _BeadsPainter(
                            target: current.target,
                            count: s.count,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(size * .2),
                            child: FittedBox(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.n(s.count),
                                    style: Fonts.display(
                                      84,
                                      weight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    '/ ${context.n(current.target)}',
                                    style: Fonts.mono(
                                      15,
                                      color: Palette.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey(s.index),
                  children: [
                    Text(
                      current.arabic,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: Fonts.arabic(long ? 22 : 34, color: Palette.green),
                    ),
                    if (!ar) ...[
                      Text(
                        current.translit,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Fonts.quote(long ? 14 : 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        current.meaning,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: Fonts.body(13, color: Palette.inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 18,
                    color: Palette.inkSoft,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l.tapToCount}  ·  ${l.todayTotal(context.n(s.total))}',
                    style: Fonts.body(13, color: Palette.inkSoft),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BeadsPainter extends CustomPainter {
  _BeadsPainter({required this.target, required this.count});

  final int target;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 8;
    final beads = math.max(math.min(target, 33), 12);
    final filled = (count / target * beads).floor();

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Palette.rule
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7,
    );

    for (var i = 0; i < beads; i++) {
      final t = -math.pi / 2 + i * 2 * math.pi / beads;
      final p = c + Offset(math.cos(t), math.sin(t)) * r;
      final on = i < filled;
      canvas.drawCircle(
        p,
        on ? 5.5 : 4.5,
        Paint()..color = on ? Palette.green : Palette.paper,
      );
      if (!on) {
        canvas.drawCircle(
          p,
          4.5,
          Paint()
            ..color = Palette.rule
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }

    // the imam bead
    final top = c + Offset(0, -r - 14);
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy - 6)
        ..lineTo(top.dx + 4, top.dy)
        ..lineTo(top.dx, top.dy + 6)
        ..lineTo(top.dx - 4, top.dy)
        ..close(),
      Paint()..color = Palette.brass,
    );
  }

  @override
  bool shouldRepaint(_BeadsPainter old) =>
      old.count != count || old.target != target;
}
