import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tasbih_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

/// Digital sebha: bead ring + big tap pad after salah adhkar.
class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen>
    with SingleTickerProviderStateMixin {
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    reverseDuration: const Duration(milliseconds: 160),
    lowerBound: 0,
    upperBound: 1,
  );

  void _tap() {
    _press.forward(from: 0).then((_) {
      if (mounted) _press.reverse();
    });
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

  void _customize() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TasbihCubit>(),
        child: const _SebhaCustomizeSheet(),
      ),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<TasbihCubit>().state;
    final current = s.current;
    final ar = context.isAr;
    final long = current.arabic.length > 30;
    final progress = current.target == 0
        ? 0.0
        : (s.count / current.target).clamp(0.0, 1.0);
    final accent = s.color.base;

    return Scaffold(
      backgroundColor: Palette.paper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l.tasbihTitle),
        actions: [
          IconButton(
            tooltip: l.sebhaCustomize,
            onPressed: _customize,
            icon: Icon(Icons.palette_outlined, color: accent),
          ),
          IconButton(
            tooltip: l.reset,
            onPressed: context.read<TasbihCubit>().reset,
            icon: Icon(Icons.restart_alt_rounded, color: Palette.clay),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _DhikrProgress(index: s.index, accent: accent),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  final ring = math.min(320.0, box.maxWidth - 32).clamp(
                    220.0,
                    320.0,
                  );
                  return Center(
                    child: SizedBox.square(
                      dimension: ring,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size.square(ring),
                            painter: _SebhaPainter(
                              target: current.target,
                              count: s.count,
                              dark: Palette.dark,
                              style: s.style,
                              color: s.color,
                            ),
                          ),
                          ScaleTransition(
                            scale: Tween(begin: 1.0, end: .92).animate(
                              CurvedAnimation(
                                parent: _press,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: _TapPad(
                              size: ring * .42,
                              count: s.count,
                              target: current.target,
                              progress: progress,
                              color: s.color,
                              digital: s.style == SebhaStyle.digital,
                              onTap: _tap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _DhikrText(
                  key: ValueKey(s.index),
                  dhikr: current,
                  ar: ar,
                  long: long,
                  accent: accent,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 18,
                    color: Palette.inkSoft,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.tapToCount,
                      style: Fonts.body(13, color: Palette.inkSoft),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: s.color.soft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l.todayTotal(context.n(s.total)),
                      style: Fonts.body(
                        12.5,
                        color: accent,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SebhaCustomizeSheet extends StatelessWidget {
  const _SebhaCustomizeSheet();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<TasbihCubit>().state;
    final cubit = context.read<TasbihCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.sebhaCustomize, style: Fonts.display(22)),
          const SizedBox(height: 6),
          Text(
            l.sebhaCustomizeSub,
            style: Fonts.body(13.5, color: Palette.inkSoft),
          ),
          const SizedBox(height: 18),
          Text(
            l.sebhaType,
            style: Fonts.body(13, color: Palette.inkSoft, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final style in SebhaStyle.values)
                ChoiceChip(
                  selected: s.style == style,
                  label: Text(_styleLabel(l, style)),
                  selectedColor: s.color.soft,
                  checkmarkColor: s.color.base,
                  onSelected: (_) => cubit.setStyle(style),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l.sebhaColor,
            style: Fonts.body(13, color: Palette.inkSoft, weight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final color in SebhaColor.values)
                GestureDetector(
                  onTap: () => cubit.setColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [color.highlight, color.base],
                        center: const Alignment(-0.3, -0.3),
                      ),
                      border: Border.all(
                        color: s.color == color
                            ? Palette.ink
                            : Colors.transparent,
                        width: 2.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.base.withValues(alpha: .35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: s.color == color
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _styleLabel(L10n l, SebhaStyle style) => switch (style) {
    SebhaStyle.wood => l.sebhaStyleWood,
    SebhaStyle.amber => l.sebhaStyleAmber,
    SebhaStyle.stone => l.sebhaStyleStone,
    SebhaStyle.pearl => l.sebhaStylePearl,
    SebhaStyle.digital => l.sebhaStyleDigital,
  };
}

class _DhikrProgress extends StatelessWidget {
  const _DhikrProgress({required this.index, required this.accent});

  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final soft = accent.withValues(alpha: .18);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.afterSalah(context.n(index + 1), context.n(adhkar.length)),
          style: Fonts.body(12.5, color: Palette.inkSoft),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < adhkar.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index
                        ? accent
                        : i < index
                        ? soft
                        : Palette.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: i == index
                          ? accent
                          : i < index
                          ? accent.withValues(alpha: .3)
                          : Palette.rule,
                      width: .8,
                    ),
                  ),
                  child: Text(
                    ar
                        ? (i == 3 ? 'تهليل' : adhkar[i].arabic.split(' ').first)
                        : (i == 3
                              ? 'Tahlil'
                              : adhkar[i].translit.split(' ').first),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Fonts.body(
                      11.5,
                      color: i == index
                          ? Colors.white
                          : i < index
                          ? accent
                          : Palette.inkSoft,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TapPad extends StatelessWidget {
  const _TapPad({
    required this.size,
    required this.count,
    required this.target,
    required this.progress,
    required this.color,
    required this.digital,
    required this.onTap,
  });

  final double size;
  final int count;
  final int target;
  final double progress;
  final SebhaColor color;
  final bool digital;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = color.base;
    final hi = color.highlight;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: digital
                  ? [
                      hi.withValues(alpha: .35),
                      accent.withValues(alpha: .9),
                    ]
                  : [
                      Palette.dark
                          ? const Color(0xFF2A3D34)
                          : const Color(0xFFFFFBF4),
                      Palette.dark
                          ? const Color(0xFF1A2820)
                          : const Color(0xFFE8DFD0),
                    ],
              center: const Alignment(-0.25, -0.3),
              radius: 1.05,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: .3),
                blurRadius: 22,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: Palette.dark ? .45 : .12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: digital ? hi : Palette.brass.withValues(alpha: .55),
              width: 2.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: size * .88,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3.5,
                  color: accent,
                  backgroundColor: Palette.rule.withValues(alpha: .35),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.n(count),
                    style: Fonts.display(
                      size * .28,
                      weight: FontWeight.w500,
                      color: digital ? Colors.white : Palette.ink,
                    ),
                  ),
                  Text(
                    '/ ${context.n(target)}',
                    style: Fonts.mono(
                      13,
                      color: digital
                          ? Colors.white.withValues(alpha: .75)
                          : Palette.inkSoft,
                    ),
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

class _DhikrText extends StatelessWidget {
  const _DhikrText({
    super.key,
    required this.dhikr,
    required this.ar,
    required this.long,
    required this.accent,
  });

  final Dhikr dhikr;
  final bool ar;
  final bool long;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Palette.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Palette.rule, width: .7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Palette.dark ? .25 : .06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            dhikr.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Fonts.arabic(long ? 20 : 32, color: accent).copyWith(
              height: 1.7,
            ),
          ),
          if (!ar) ...[
            const SizedBox(height: 8),
            Text(
              dhikr.translit,
              textAlign: TextAlign.center,
              style: Fonts.quote(long ? 14 : 17),
            ),
            const SizedBox(height: 4),
            Text(
              dhikr.meaning,
              textAlign: TextAlign.center,
              style: Fonts.body(13, color: Palette.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

class _SebhaPainter extends CustomPainter {
  _SebhaPainter({
    required this.target,
    required this.count,
    required this.dark,
    required this.style,
    required this.color,
  });

  final int target;
  final int count;
  final bool dark;
  final SebhaStyle style;
  final SebhaColor color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 18;
    final beads = math.max(math.min(target <= 1 ? 16 : target, 33), 12);
    final filled = target <= 1
        ? (count >= 1 ? beads : 0)
        : (count / target * beads).floor().clamp(0, beads);

    final cord = switch (style) {
      SebhaStyle.digital => color.highlight.withValues(alpha: .55),
      SebhaStyle.pearl => const Color(0xFFB8B0A4),
      _ => dark ? const Color(0xFF3A2E22) : const Color(0xFF8B6914),
    };

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = cord
        ..style = PaintingStyle.stroke
        ..strokeWidth = style == SebhaStyle.digital ? 2 : 3.2
        ..strokeCap = StrokeCap.round,
    );

    final idle = _idleColors();
    final active = color.base;
    final activeHi = color.highlight;

    for (var i = 0; i < beads; i++) {
      final t = -math.pi / 2 + (i + .5) * 2 * math.pi / beads;
      final p = c + Offset(math.cos(t), math.sin(t)) * r;
      final on = i < filled;
      final beadR = style == SebhaStyle.digital
          ? (on ? 6.5 : 5.0)
          : (on ? 9.5 : 8.2);

      if (style != SebhaStyle.digital) {
        canvas.drawCircle(
          p.translate(0, 1.6),
          beadR,
          Paint()..color = Colors.black.withValues(alpha: dark ? .35 : .14),
        );
      }

      if (style == SebhaStyle.digital) {
        canvas.drawCircle(
          p,
          beadR,
          Paint()..color = on ? activeHi : Palette.rule.withValues(alpha: .55),
        );
        if (on) {
          canvas.drawCircle(
            p,
            beadR * .45,
            Paint()..color = Colors.white.withValues(alpha: .55),
          );
        }
      } else {
        final fill = Paint()
          ..shader = RadialGradient(
            colors: on ? [activeHi, active] : idle,
            center: const Alignment(-0.35, -0.4),
          ).createShader(Rect.fromCircle(center: p, radius: beadR));
        canvas.drawCircle(p, beadR, fill);
        canvas.drawCircle(
          p.translate(-beadR * .28, -beadR * .32),
          beadR * .28,
          Paint()
            ..color = Colors.white.withValues(
              alpha: style == SebhaStyle.pearl ? .55 : (on ? .22 : .35),
            ),
        );
      }
    }

    if (style == SebhaStyle.digital) return;

    final top = c + Offset(0, -r - 2);
    final imam = Path()
      ..moveTo(top.dx, top.dy - 16)
      ..quadraticBezierTo(top.dx + 11, top.dy - 4, top.dx + 7, top.dy + 10)
      ..quadraticBezierTo(top.dx, top.dy + 14, top.dx - 7, top.dy + 10)
      ..quadraticBezierTo(top.dx - 11, top.dy - 4, top.dx, top.dy - 16)
      ..close();
    canvas.drawShadow(imam, Colors.black.withValues(alpha: .25), 4, true);
    canvas.drawPath(
      imam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.highlight, color.base],
        ).createShader(Rect.fromCircle(center: top, radius: 18)),
    );
    canvas.drawCircle(
      top.translate(-3, -4),
      3.2,
      Paint()..color = Colors.white.withValues(alpha: .35),
    );
  }

  List<Color> _idleColors() => switch (style) {
    SebhaStyle.wood => dark
        ? const [Color(0xFF8A6A42), Color(0xFF6B4E2E)]
        : const [Color(0xFFE2B86A), Color(0xFFC4954A)],
    SebhaStyle.amber => dark
        ? const [Color(0xFFC9A227), Color(0xFF8A6A1E)]
        : const [Color(0xFFFFD56A), Color(0xFFE0A030)],
    SebhaStyle.stone => dark
        ? const [Color(0xFF6A6F76), Color(0xFF3E444C)]
        : const [Color(0xFFB8BEC6), Color(0xFF7A828C)],
    SebhaStyle.pearl => dark
        ? const [Color(0xFFE8E2D8), Color(0xFFB8B0A4)]
        : const [Color(0xFFFFFCF7), Color(0xFFE5DDD0)],
    SebhaStyle.digital => [color.highlight, color.base],
  };

  @override
  bool shouldRepaint(_SebhaPainter old) =>
      old.count != count ||
      old.target != target ||
      old.dark != dark ||
      old.style != style ||
      old.color != color;
}
