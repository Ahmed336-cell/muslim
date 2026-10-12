import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_cubit.dart';
import '../l10n/l10n.dart';
import '../services/hisn.dart';
import '../theme.dart';

/// One dhikr: Arabic, then (English UI) transliteration and meaning, with
/// listen / copy actions. With [count] it becomes a tap counter.
class DhikrCard extends StatelessWidget {
  const DhikrCard({super.key, required this.dhikr, this.count, this.onTap});

  final Dhikr dhikr;

  /// Times recited today; null hides the counter.
  final int? count;
  final VoidCallback? onTap;

  bool get _done => count != null && count! >= dhikr.repeat;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final audioKey = 'hisn:${dhikr.id}';
    final playing = context.select((AudioCubit c) => c.state == audioKey);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _done ? .6 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Material(
          color: Palette.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _done ? Palette.green : Palette.rule,
              width: _done ? 1.2 : .7,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Text(
                      dhikr.arabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.start,
                      style: Fonts.arabic(
                        21,
                        color: Palette.ink,
                      ).copyWith(height: 1.9),
                    ),
                  ),
                  if (!ar && dhikr.translit.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(dhikr.translit, style: Fonts.quote(14.5)),
                  ],
                  if (!ar && dhikr.translation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      dhikr.translation,
                      style: Fonts.body(13.5, color: Palette.inkSoft),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        tooltip: l.listenTip,
                        color: Palette.green,
                        icon: Icon(
                          playing
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline_rounded,
                        ),
                        onPressed: () => context.read<AudioCubit>().toggle(
                          audioKey,
                          dhikr.audio,
                        ),
                      ),
                      IconButton(
                        tooltip: l.copyTip,
                        color: Palette.inkSoft,
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: () => _copy(context),
                      ),
                      const Spacer(),
                      if (count case final c?)
                        _Counter(count: c, target: dhikr.repeat)
                      else if (dhikr.repeat > 1)
                        _RepeatBadge(repeat: dhikr.repeat),
                      const SizedBox(width: 6),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final text = [
      dhikr.arabic,
      if (!context.isAr && dhikr.translation.isNotEmpty) dhikr.translation,
    ].join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l.copied)));
  }
}

class _RepeatBadge extends StatelessWidget {
  const _RepeatBadge({required this.repeat});

  final int repeat;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Palette.greenSoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      context.l.timesCount(context.n(repeat)),
      style: Fonts.body(12.5, color: Palette.green, weight: FontWeight.w600),
    ),
  );
}

class _Counter extends StatelessWidget {
  const _Counter({required this.count, required this.target});

  final int count;
  final int target;

  @override
  Widget build(BuildContext context) {
    final done = count >= target;
    return SizedBox.square(
      dimension: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 46,
            child: CircularProgressIndicator(
              value: math.min(1, count / target),
              strokeWidth: 3,
              color: Palette.green,
              backgroundColor: Palette.rule.withValues(alpha: .5),
            ),
          ),
          if (done)
            const Icon(Icons.check_rounded, color: Palette.green, size: 24)
          else
            Text(
              context.n(target - count),
              style: Fonts.mono(target - count > 99 ? 12 : 15),
            ),
        ],
      ),
    );
  }
}
