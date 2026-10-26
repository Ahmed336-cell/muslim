import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/quran_prefs_cubit.dart';
import '../services/quran.dart';
import '../theme.dart';

/// Colours of one mushaf page: paper, ink, and the illuminated border.
class MushafColors {
  const MushafColors({
    required this.page,
    required this.green,
    required this.band,
    required this.flower,
    required this.brass,
    required this.ink,
    required this.highlight,
    required this.mark,
  });

  final Color page;
  final Color green;
  final Color band;
  final Color flower;
  final Color brass;
  final Color ink;
  final Color highlight;
  final Color mark;

  static MushafColors forStyle(MushafStyle style) => switch (style) {
    MushafStyle.classic => MushafColors(
      page: Palette.dark ? const Color(0xFF0A0A0A) : const Color(0xFFFFFCF3),
      green: Palette.dark ? const Color(0xFFFFFFFF) : const Color(0xFF2F6B4F),
      band: Palette.dark ? const Color(0xFF0F2219) : const Color(0xFFDCEBD3),
      flower: Palette.dark ? const Color(0xFFFFFFFF) : const Color(0xFFCF7895),
      brass: Palette.brass,
      ink: Palette.ink,
      highlight: Palette.greenSoft,
      mark: Palette.clay,
    ),
    MushafStyle.madinah => const MushafColors(
      page: Color(0xFFFFFCF3),
      green: Color(0xFF1F6B4A),
      band: Color(0xFFE4F0E4),
      flower: Color(0xFFD4789A),
      brass: Color(0xFFC4A35A),
      ink: Color(0xFF1C1915),
      highlight: Color(0x332F6B4F),
      mark: Color(0xFF8C4A32),
    ),
    MushafStyle.night => const MushafColors(
      page: Color(0xFF0E1110),
      green: Color(0xFFE0B860),
      band: Color(0xFF1A2420),
      flower: Color(0xFFC47890),
      brass: Color(0xFFE0B860),
      ink: Color(0xFFF3EDE2),
      highlight: Color(0x33E0B860),
      mark: Color(0xFFE08A6A),
    ),
    MushafStyle.sepia => const MushafColors(
      page: Color(0xFFF3E6D0),
      green: Color(0xFF7A4E2D),
      band: Color(0xFFE7D3B5),
      flower: Color(0xFFA56B6B),
      brass: Color(0xFFA68448),
      ink: Color(0xFF3E2C1C),
      highlight: Color(0x337A4E2D),
      mark: Color(0xFF8B3A2F),
    ),
    MushafStyle.ottoman => const MushafColors(
      page: Color(0xFFF7F1E3),
      green: Color(0xFF1E3A5F),
      band: Color(0xFFD9E2EF),
      flower: Color(0xFFC4A0A8),
      brass: Color(0xFFB08D57),
      ink: Color(0xFF1A2744),
      highlight: Color(0x331E3A5F),
      mark: Color(0xFF8C3A3A),
    ),
    MushafStyle.emerald => const MushafColors(
      page: Color(0xFF0E3B2E),
      green: Color(0xFFE4C56A),
      band: Color(0xFF0A2E24),
      flower: Color(0xFFE7A0B4),
      brass: Color(0xFFE4C56A),
      ink: Color(0xFFF6E7C1),
      highlight: Color(0x33E4C56A),
      mark: Color(0xFFF0C9A0),
    ),
    MushafStyle.royal => const MushafColors(
      page: Color(0xFF101828),
      green: Color(0xFFD4AF6A),
      band: Color(0xFF1A2438),
      flower: Color(0xFFC98B9A),
      brass: Color(0xFFD4AF6A),
      ink: Color(0xFFF4E8C8),
      highlight: Color(0x33D4AF6A),
      mark: Color(0xFFE8B4A2),
    ),
    MushafStyle.rose => const MushafColors(
      page: Color(0xFFF8E8E4),
      green: Color(0xFF8E3D55),
      band: Color(0xFFF3D5D0),
      flower: Color(0xFFE090A4),
      brass: Color(0xFFB08D57),
      ink: Color(0xFF4A2430),
      highlight: Color(0x338E3D55),
      mark: Color(0xFF6E2E22),
    ),
    MushafStyle.ink => const MushafColors(
      page: Color(0xFFFFFFFF),
      green: Color(0xFF333333),
      band: Color(0xFFF2F2F2),
      flower: Color(0xFFC8C8C8),
      brass: Color(0xFF888888),
      ink: Color(0xFF111111),
      highlight: Color(0x22111111),
      mark: Color(0xFF9A3B2F),
    ),
  };

  /// Selected style, or classic when the prefs cubit is not in the tree.
  static MushafColors watch(BuildContext context) {
    // Rebuild when the app theme flips so classic tracks light and dark.
    Theme.of(context);
    try {
      return forStyle(
        context.select<QuranPrefsCubit, MushafStyle>((c) => c.state.style),
      );
    } on ProviderNotFoundException {
      return forStyle(MushafStyle.classic);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is MushafColors &&
      other.page == page &&
      other.green == green &&
      other.band == band &&
      other.flower == flower &&
      other.brass == brass &&
      other.ink == ink &&
      other.highlight == highlight &&
      other.mark == mark;

  @override
  int get hashCode => Object.hash(
    page,
    green,
    band,
    flower,
    brass,
    ink,
    highlight,
    mark,
  );
}

/// Small four-petal flower used along the borders.
void _flower(Canvas canvas, Offset c, double r, MushafColors colors) {
  final petal = Paint()..color = colors.flower;
  for (var i = 0; i < 4; i++) {
    final t = i * math.pi / 2 + math.pi / 4;
    canvas.drawCircle(c + Offset(math.cos(t), math.sin(t)) * r, r * .8, petal);
  }
  canvas.drawCircle(c, r * .6, Paint()..color = colors.brass);
}

/// Illuminated border around a mushaf page.
class MushafFrame extends StatelessWidget {
  const MushafFrame({super.key, required this.child});

  final Widget child;

  static const band = 12.0;

  @override
  Widget build(BuildContext context) {
    final colors = MushafColors.watch(context);
    return CustomPaint(
      painter: _FramePainter(colors),
      child: Padding(padding: const EdgeInsets.all(band + 8), child: child),
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter(this.colors);

  final MushafColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    const b = MushafFrame.band;
    final outer = (Offset.zero & size).deflate(1);
    final inner = outer.deflate(b);
    final green = Paint()
      ..color = colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas
      ..drawRect(outer, Paint()..color = colors.band)
      ..drawRect(inner, Paint()..color = colors.page);

    const step = 15.0;
    void along(Offset from, Offset to) {
      final len = (to - from).distance;
      final n = (len / step).floor();
      if (n < 1) return;
      final gap = len / n;
      final dir = (to - from) / len;
      for (var i = 0; i < n; i++) {
        _flower(canvas, from + dir * (gap * (i + .5)), 2.4, colors);
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
        ..drawRect(corner, Paint()..color = colors.green)
        ..drawCircle(corner.center, 2.6, Paint()..color = colors.brass);
    }

    canvas
      ..drawRect(outer, green)
      ..drawRect(inner, green)
      ..drawRect(
        inner.deflate(3),
        Paint()
          ..color = colors.brass
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.colors != colors;
}

/// Framed surah title, as at the head of each surah in print.
class SurahCartouche extends StatelessWidget {
  const SurahCartouche({super.key, required this.title, required this.height});

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = MushafColors.watch(context);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _CartouchePainter(colors),
        child: Center(
          child: Text(
            title,
            textDirection: TextDirection.rtl,
            textScaler: TextScaler.noScaling,
            style: Fonts.arabic(
              height * .5,
              color: colors.green,
            ).copyWith(height: 1.2),
          ),
        ),
      ),
    );
  }
}

class _CartouchePainter extends CustomPainter {
  const _CartouchePainter(this.colors);

  final MushafColors colors;

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
      ..drawPath(shape(outer), Paint()..color = colors.band)
      ..drawPath(
        shape(outer),
        Paint()
          ..color = colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      )
      ..drawPath(
        shape(outer.deflate(4)),
        Paint()
          ..color = colors.brass
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
    final r = size.height * .09;
    _flower(canvas, Offset(outer.left + size.height * .55, outer.center.dy), r, colors);
    _flower(
      canvas,
      Offset(outer.right - size.height * .55, outer.center.dy),
      r,
      colors,
    );
  }

  @override
  bool shouldRepaint(_CartouchePainter old) => old.colors != colors;
}

/// Page number in a small medallion under the frame.
class PageMedallion extends StatelessWidget {
  const PageMedallion(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = MushafColors.watch(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
      decoration: BoxDecoration(
        color: colors.band,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.green, width: .9),
      ),
      child: Text(
        label,
        textScaler: TextScaler.noScaling,
        style: Fonts.arabic(13, color: colors.green).copyWith(height: 1.5),
      ),
    );
  }
}
