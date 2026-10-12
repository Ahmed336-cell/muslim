import 'package:flutter/material.dart';

import '../theme.dart';
import 'common.dart';
import 'listen_style.dart';

/// Colours a skeleton for the surface it sits on.
enum ShimmerTone {
  paper(Palette.paperDeep, Palette.card),
  dark(Color(0x1FFFFFFF), Color(0x40FFFFFF)),
  listen(Listen.surface, Listen.surfaceHi);

  const ShimmerTone(this.base, this.highlight);

  final Color base;
  final Color highlight;
}

/// Sweeps a highlight across the [Bone]s in [child].
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child, this.tone = .paper});

  final Widget child;
  final ShimmerTone tone;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = .5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tone = widget.tone;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (_, child) {
          final t = Curves.easeInOut.transform(_controller.value) * 2 - 1;
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: const Alignment(-1, -.4),
              end: const Alignment(1, .4),
              colors: [tone.base, tone.highlight, tone.base],
              stops: const [.35, .5, .65],
              transform: _Slide(rtl ? -t : t),
            ).createShader(bounds),
            child: child,
          );
        },
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.percent);

  final double percent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent * 1.5, 0, 0);
}

/// A placeholder shape; only visible inside a [Shimmer].
class Bone extends StatelessWidget {
  const Bone({super.key, this.width, this.height = 12, this.radius = 6});

  const Bone.circle(double size, {super.key})
    : width = size,
      height = size,
      radius = size / 2;

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Lines of text, the last one shorter.
class SkeletonLines extends StatelessWidget {
  const SkeletonLines({
    super.key,
    this.lines = 3,
    this.height = 12,
    this.gap = 10,
    this.align = CrossAxisAlignment.start,
  });

  final int lines;
  final double height;
  final double gap;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: align,
    children: [
      for (var i = 0; i < lines; i++) ...[
        if (i > 0) SizedBox(height: gap),
        FractionallySizedBox(
          widthFactor: i == lines - 1 && lines > 1 ? .6 : 1,
          child: Bone(height: height),
        ),
      ],
    ],
  );
}

/// Rows of a list: an optional badge, a title and a subtitle.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.rows = 8,
    this.leading = 34,
    this.tone = .paper,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  });

  final int rows;

  /// Badge size; 0 for none.
  final double leading;
  final ShimmerTone tone;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Shimmer(
    tone: tone,
    child: Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  if (leading > 0) ...[
                    Bone.circle(leading),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: const [.7, .5, .62, .45][i % 4],
                          child: const Bone(height: 14),
                        ),
                        const SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: const [.4, .3, .35, .25][i % 4],
                          child: const Bone(height: 10),
                        ),
                      ],
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

/// The body of a card: a caption, a title and a few lines.
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key, this.lines = 2, this.tone = .paper});

  final int lines;
  final ShimmerTone tone;

  @override
  Widget build(BuildContext context) => Shimmer(
    tone: tone,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Bone(width: 80, height: 10),
        const SizedBox(height: 14),
        const FractionallySizedBox(
          widthFactor: .7,
          child: Bone(height: 18, radius: 8),
        ),
        const SizedBox(height: 14),
        SkeletonLines(lines: lines),
      ],
    ),
  );
}

/// [CardSkeleton] inside an [AppCard], for cards still loading.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.lines = 2});

  final int lines;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
    child: CardSkeleton(lines: lines),
  );
}

/// Centred lines like a mushaf page being typeset.
class PageSkeleton extends StatelessWidget {
  const PageSkeleton({super.key, this.lines = 13});

  final int lines;

  @override
  Widget build(BuildContext context) => Shimmer(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Bone(width: 160, height: 26, radius: 13),
          const SizedBox(height: 26),
          for (var i = 0; i < lines; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: FractionallySizedBox(
                widthFactor: i == lines - 1 ? .45 : const [1.0, .94, .98][i % 3],
                child: const Bone(height: 16, radius: 8),
              ),
            ),
        ],
      ),
    ),
  );
}
