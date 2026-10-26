import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/recitation_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/quran.dart';
import '../services/quran_text.dart';
import '../services/recitation.dart';
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
    final tafsir = s.kind == RecitationKind.tafsir;
    final radio = s.kind == RecitationKind.radio;
    final Surah? surah =
        tawashih ||
            tafsir ||
            radio ||
            track.surah < 1 ||
            track.surah > surahs.length
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
                                    : radio
                                    ? l.radioLive
                                    : tafsir
                                    ? l.featTafsir
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
                      child: tawashih || tafsir || radio
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
                    if (surah != null)
                      AyahBar(
                        cubit: cubit,
                        surah: surah.number,
                        ayah: ayah?.$2,
                        recording: ayah == null ? s.recording : null,
                        clip: track.start ?? Duration.zero,
                        canOpenReader: canOpenReader,
                      ),
                    if (surah != null && !radio) ...[
                      const SizedBox(height: 20),
                      _SeekBar(cubit: cubit, gold: true),
                    ],
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
                    if (radio)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          l.radioLive,
                          style: Fonts.body(
                            14,
                            color: Listen.accent,
                            weight: FontWeight.w700,
                          ),
                        ),
                      )
                    else if (surah == null)
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
    final rtl = context.isAr;
    // Keep slots fixed, then swap skip buttons for Arabic so "next" sits
    // on the leading side and the arrows point with the reading direction.
    Widget mirror(IconData icon) =>
        Transform.flip(flipX: rtl, child: Icon(icon));
    if (s.kind == RecitationKind.radio) {
      return Center(
        child: SizedBox.square(
          dimension: 68,
          child: Material(
            color: Listen.text,
            shape: const CircleBorder(),
            child: s.buffering && s.playing
                ? Padding(
                    padding: const EdgeInsets.all(22),
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
      );
    }
    final skipBack = IconButton(
      tooltip: l.previousTip,
      iconSize: 40,
      color: Listen.text,
      disabledColor: Listen.textFaint,
      icon: mirror(Icons.skip_previous_rounded),
      onPressed: s.hasPrevious ? cubit.previous : null,
    );
    final skipForward = IconButton(
      tooltip: l.nextTip,
      iconSize: 40,
      color: Listen.text,
      disabledColor: Listen.textFaint,
      icon: mirror(Icons.skip_next_rounded),
      onPressed: s.hasNext ? cubit.next : null,
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
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
          rtl ? skipForward : skipBack,
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
                      icon: Transform.flip(
                        flipX: rtl && !s.playing,
                        child: Icon(
                          s.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                      onPressed: cubit.toggle,
                    ),
            ),
          ),
          rtl ? skipBack : skipForward,
          // Balances the repeat button.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.cubit, this.gold = false});

  final RecitationCubit cubit;
  final bool gold;

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
          final gold = widget.gold;
          final at = Duration(milliseconds: p.round());
          final left = t - at;
          final active = gold ? _gold : Listen.text;
          return Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: gold ? 3 : 3.5,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: gold ? 0 : 6.5,
                  ),
                ),
                child: Slider(
                  value: p,
                  max: max,
                  activeColor: active,
                  inactiveColor: gold ? _track : Listen.textFaint,
                  thumbColor: active,
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
                      gold ? context.n(_clock(at)) : formatDuration(at),
                      style: Fonts.body(12, color: Listen.textSoft),
                    ),
                    Text(
                      t == Duration.zero
                          ? (gold ? context.n('--:--') : '--:--')
                          : gold
                          ? context.n(
                              '-${_clock(left.isNegative ? Duration.zero : left)}',
                            )
                          : '-${formatDuration(left.isNegative ? Duration.zero : left)}',
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

const _gold = Color(0xFFC9A45C);
const _track = Color(0xFF3A3A3A);

/// The stamps sit a little after the voice. Step the verse forward so the
/// words on screen meet the words being recited.
const _lead = Duration(milliseconds: 700);

String _clock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// The ayah being recited. Shown on the mini player and under the artwork.
class AyahBar extends StatefulWidget {
  const AyahBar({
    super.key,
    required this.cubit,
    required this.surah,
    required this.ayah,
    required this.recording,
    required this.clip,
    required this.canOpenReader,
    this.top = 16,
  });

  final RecitationCubit cubit;
  final int surah;
  final int? ayah;
  final int? recording;

  /// File offset when playback of this surah starts mid-file.
  final Duration clip;
  final bool canOpenReader;
  final double top;

  @override
  State<AyahBar> createState() => _AyahBarState();
}

class _AyahBarState extends State<AyahBar> {
  Ayah? _verse;
  final _verses = <int, Ayah>{};
  List<({int ayah, Duration start, Duration end})> _timings = const [];
  StreamSubscription<Duration>? _pos;
  StreamSubscription<Duration?>? _dur;
  Duration _audio = Duration.zero;
  Duration _playhead = Duration.zero;
  int? _shown;
  int? _pending;
  var _gen = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gen == 0) _start();
  }

  @override
  void didUpdateWidget(covariant AyahBar old) {
    super.didUpdateWidget(old);
    if (old.surah != widget.surah ||
        old.ayah != widget.ayah ||
        old.recording != widget.recording ||
        old.clip != widget.clip) {
      _start();
    }
  }

  @override
  void dispose() {
    _gen++;
    _pos?.cancel();
    _dur?.cancel();
    super.dispose();
  }

  void _start() {
    final gen = ++_gen;
    _pos?.cancel();
    _dur?.cancel();
    _pos = null;
    _dur = null;
    _timings = const [];
    _verses.clear();
    _pending = null;
    _shown = widget.ayah;
    _loadFixed(gen);
    final id = widget.recording;
    if (widget.ayah != null || id == null) return;
    final api = _maybe<RecitersApi>(context);
    if (api == null) return;
    _follow(api, id, gen);
  }

  Future<void> _loadFixed(int gen) async {
    final n = widget.ayah;
    final text = _maybe<QuranText>(context);
    if (n == null || text == null) return;
    try {
      final verse = await text.ayah(widget.surah, n, Mushaf.uthmani);
      if (!mounted || gen != _gen) return;
      setState(() => _verse = verse);
    } catch (_) {}
  }

  Future<void> _follow(RecitersApi api, int recording, int gen) async {
    final text = _maybe<QuranText>(context);
    final timings = await api.ayahTimings(recording, widget.surah);
    if (!mounted || gen != _gen) return;
    _timings = timings;
    _dur = widget.cubit.duration.listen((d) {
      _audio = d ?? Duration.zero;
      _onPosition(_playhead);
    });
    _pos = widget.cubit.position.listen(_onPosition);
    if (text == null) return;
    final count = surahs[widget.surah - 1].ayahs;
    for (var n = 1; n <= count; n++) {
      if (!mounted || gen != _gen) return;
      final Ayah verse;
      try {
        verse = await text.ayah(widget.surah, n, Mushaf.uthmani);
      } catch (_) {
        return;
      }
      _verses[n] = verse;
      if (n == _pending && n != _shown) _show(verse);
    }
  }

  void _onPosition(Duration position) {
    _playhead = position;
    final timings = _timings;
    if (timings.isEmpty || !mounted) return;
    var at = position + widget.clip;
    if (widget.clip == Duration.zero) {
      at = timingAt(at, _audio, timings.last.end);
    }
    at += _lead;
    int? n;
    for (final t in timings) {
      if (t.start <= at) {
        n = t.ayah;
      } else {
        break;
      }
    }
    if (n == null || n == _shown) return;
    final verse = _verses[n];
    if (verse == null) {
      _pending = n;
      return;
    }
    _show(verse);
  }

  void _show(Ayah verse) {
    _pending = null;
    _shown = verse.number;
    setState(() => _verse = verse);
  }

  @override
  Widget build(BuildContext context) {
    final verse = _verse;
    final surah = surahs[widget.surah - 1];
    final shown =
        verse?.text ?? (context.isAr ? 'سورة ${surah.arabic}' : surah.name);
    final open = widget.canOpenReader && verse != null
        ? () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(
              MushafScreen.route(
                verse.surah,
                ayah: verse.number,
                highlight: true,
              ),
            );
          }
        : null;
    final frame = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _gold.withValues(alpha: .9)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Text(
          shown,
          textAlign: TextAlign.center,
          textDirection: verse == null ? null : TextDirection.rtl,
          style: verse == null
              ? Fonts.body(15, color: Listen.text, weight: FontWeight.w600)
              : Fonts.mushaf(20, color: Listen.text, height: 1.75),
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.only(top: widget.top),
      child: open == null
          ? frame
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: open,
                borderRadius: BorderRadius.circular(22),
                child: frame,
              ),
            ),
    );
  }
}

T? _maybe<T>(BuildContext context) {
  try {
    return context.read<T>();
  } catch (_) {
    return null;
  }
}
