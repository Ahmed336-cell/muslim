import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/recitation_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/ambient_mixer.dart';
import '../widgets/gramophone_disc.dart';
import '../widgets/listen_style.dart';
import '../widgets/reciter_art.dart';
import '../widgets/sleep_timer.dart';
import 'mushaf_screen.dart';

Future<void> showNowPlaying(
  BuildContext context, {
  bool canOpenReader = true,
}) => Navigator.of(context).push(
  PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => NowPlayingScreen(canOpenReader: canOpenReader),
    transitionsBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);

/// Full-screen player: artwork, seek bar, controls and background sounds.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key, this.canOpenReader = true});

  /// False when opened from the mushaf itself.
  final bool canOpenReader;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<RecitationCubit>();
    final s = context.watch<RecitationCubit>().state;
    final track = s.current;

    if (track == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return ColoredBox(color: Listen.bg);
    }

    final (light, _) = coverColors(track.artist);
    final ayah = s.ayah;
    final tawashih = s.kind == RecitationKind.tawashih;
    final Surah? surah = tawashih || track.surah < 1 || track.surah > surahs.length
        ? null
        : surahs[track.surah - 1];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Listen.bg,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [light, Listen.bg],
              stops: const [0, .62],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final art = math.min(c.maxWidth - 56, c.maxHeight * .42);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          color: Listen.text,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 32,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                l.nowPlaying.toUpperCase(),
                                style: Fonts.body(
                                  11,
                                  color: Listen.textSoft,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                ayah != null
                                    ? l.fromMushaf
                                    : tawashih
                                    ? l.featTawashih
                                    : track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Fonts.body(
                                  13,
                                  color: Listen.text,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              if (s.sleepOn)
                                SleepCountdown(
                                  style: Fonts.body(11.5, color: Listen.accent),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l.sleepTimer,
                          color: s.sleepOn ? Listen.accent : Listen.textSoft,
                          icon: Icon(
                            s.sleepOn
                                ? Icons.bedtime_rounded
                                : Icons.bedtime_outlined,
                          ),
                          onPressed: () => showSleepTimer(context),
                        ),
                        IconButton(
                          tooltip: l.stop,
                          color: Listen.textSoft,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: cubit.stop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: tawashih
                          ? GramophoneDisc(
                              name: track.artist,
                              spinning: s.playing,
                              size: art,
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .45),
                                    blurRadius: 36,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: ReciterArt(
                                name: track.artist,
                                size: art,
                                label: surah != null
                                    ? 'سورة ${surah.arabic}'
                                    : null,
                                photo: track.art,
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Fonts.body(
                                  22,
                                  color: Listen.text,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Fonts.body(15, color: Listen.textSoft),
                              ),
                            ],
                          ),
                        ),
                        if (ayah != null && canOpenReader)
                          IconButton(
                            tooltip: l.openInMushaf,
                            color: Listen.text,
                            icon: const Icon(Icons.menu_book_rounded),
                            onPressed: () {
                              final nav = Navigator.of(context);
                              nav.pop();
                              nav.push(
                                MushafScreen.route(ayah.$1, ayah: ayah.$2),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SeekBar(cubit: cubit),
                    if (s.error)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          l.playbackError,
                          textAlign: TextAlign.center,
                          style: Fonts.body(13, color: Palette.clay),
                        ),
                      ),
                    _Controls(state: s, cubit: cubit),
                    const SizedBox(height: 26),
                    const AmbientMixer(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state, required this.cubit});

  final RecitationState state;
  final RecitationCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: l.repeatTip,
          color: s.repeat ? Listen.accent : Listen.textSoft,
          icon: Icon(
            s.repeat ? Icons.repeat_one_rounded : Icons.repeat_rounded,
          ),
          onPressed: cubit.toggleRepeat,
        ),
        IconButton(
          tooltip: l.previousTip,
          iconSize: 40,
          color: Listen.text,
          disabledColor: Listen.textFaint,
          icon: const Icon(Icons.skip_previous_rounded),
          onPressed: s.hasPrevious ? cubit.previous : null,
        ),
        SizedBox.square(
          dimension: 68,
          child: Material(
            color: Listen.text,
            shape: const CircleBorder(),
            child: s.buffering && s.playing
                ? Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Listen.bg,
                    ),
                  )
                : IconButton(
                    tooltip: s.playing ? l.pauseTip : l.playTip,
                    iconSize: 38,
                    color: Listen.bg,
                    icon: Icon(
                      s.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    onPressed: cubit.toggle,
                  ),
          ),
        ),
        IconButton(
          tooltip: l.nextTip,
          iconSize: 40,
          color: Listen.text,
          disabledColor: Listen.textFaint,
          icon: const Icon(Icons.skip_next_rounded),
          onPressed: s.hasNext ? cubit.next : null,
        ),
        // Balances the repeat button.
        const SizedBox(width: 48),
      ],
    );
  }
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.cubit});

  final RecitationCubit cubit;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: widget.cubit.duration,
      builder: (context, total) => StreamBuilder<Duration>(
        stream: widget.cubit.position,
        builder: (context, pos) {
          final t = total.data ?? Duration.zero;
          final max = math.max(t.inMilliseconds.toDouble(), 1.0);
          final p =
              _dragging ??
              (pos.data?.inMilliseconds.toDouble() ?? 0).clamp(0.0, max);
          return Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3.5,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6.5,
                  ),
                ),
                child: Slider(
                  value: p,
                  max: max,
                  activeColor: Listen.text,
                  inactiveColor: Listen.textFaint,
                  thumbColor: Listen.text,
                  onChanged: t == Duration.zero
                      ? null
                      : (v) => setState(() => _dragging = v),
                  onChangeEnd: (v) {
                    widget.cubit.seek(Duration(milliseconds: v.round()));
                    setState(() => _dragging = null);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(Duration(milliseconds: p.round())),
                      style: Fonts.body(12, color: Listen.textSoft),
                    ),
                    Text(
                      t == Duration.zero
                          ? '--:--'
                          : '-${formatDuration(t - Duration(milliseconds: p.round()))}',
                      style: Fonts.body(12, color: Listen.textSoft),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
