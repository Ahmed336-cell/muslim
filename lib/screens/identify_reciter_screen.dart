import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/quran_prefs_cubit.dart';
import '../bloc/quran/recent_reciters_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/quran.dart';
import '../services/quran_text.dart';
import '../services/recite_engine.dart';
import '../services/reciter_id.dart';
import '../services/recitation.dart';
import '../theme.dart';
import 'mushaf_screen.dart';
import 'reciters_screen.dart';

/// Listens for a recitation, names the reciter and the ayah, then opens it.
class IdentifyReciterScreen extends StatefulWidget {
  const IdentifyReciterScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const IdentifyReciterScreen());

  @override
  State<IdentifyReciterScreen> createState() => _IdentifyReciterScreenState();
}

enum _Phase { idle, downloading, listening, matching, result }

class _IdentifyReciterScreenState extends State<IdentifyReciterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late ReciterId _id;
  var _phase = _Phase.idle;
  var _progress = 0.0;
  String? _message;
  ReciterMatch? _match;
  Ayah? _ayah;
  VerseSpan? _span;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_started) _listen();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _id = context.read<ReciterId>();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _id.stop();
    super.dispose();
  }

  Future<void> _listen() async {
    if (_phase == _Phase.listening || _phase == _Phase.downloading) return;
    _started = true;
    final l = context.l;
    final recite = context.read<ReciteEngine>();
    final quran = context.read<QuranText>();
    setState(() {
      _phase = _Phase.downloading;
      _progress = 0;
      _message = null;
      _match = null;
      _ayah = null;
      _span = null;
    });
    try {
      await _id.downloadModel(
        onProgress: (p) {
          if (mounted) setState(() => _progress = p * .5);
        },
      );
      if (!await recite.hasModel()) {
        await recite.downloadModel(
          onProgress: (p) {
            if (mounted) setState(() => _progress = .5 + p * .5);
          },
        );
      }
      await _id.loadCatalog();
      if (!mounted) return;
      if (!_id.catalogReady) {
        setState(() {
          _phase = _Phase.idle;
          _message = l.identifyEmpty;
        });
        return;
      }
      setState(() {
        _phase = _Phase.listening;
        _progress = 0;
      });
      final capture = await _id.listen(
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted || capture == null) {
        if (mounted) setState(() => _phase = _Phase.idle);
        return;
      }
      if (capture.denied || capture.matches.isEmpty) {
        setState(() {
          _phase = _Phase.idle;
          _message = capture.denied ? l.identifyNeedMic : l.identifyUnknown;
        });
        return;
      }
      setState(() => _phase = _Phase.matching);
      final transcript = await recite.transcribePcm(capture.pcm);
      final span = transcript.isEmpty ? null : await quran.locateSpan(transcript);
      if (!mounted) return;
      final top = capture.matches.first;
      setState(() {
        _phase = _Phase.result;
        _match = top;
        _span = span;
        _ayah = span?.start;
        _message = null;
      });
    } catch (error, stack) {
      debugPrint('identify listen failed: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _message = l.identifyFailed;
      });
    }
  }

  Future<void> _open() async {
    final ayah = _ayah;
    final match = _match;
    final lang = context.lang;
    final play = context.read<RecitationCubit>();
    if (ayah != null && match != null) {
      final api = context.read<RecitersApi>();
      final reciters = await api.fetch(lang);
      if (!mounted) return;
      final reciter = reciters
          .where((r) => r.id == match.voice.reciterId)
          .firstOrNull;
      final recording =
          reciter?.recordings
              .where((r) => r.id == match.voice.recordingId)
              .firstOrNull ??
          reciter?.recordings.firstOrNull;
      if (reciter != null &&
          recording != null &&
          recording.surahs.contains(ayah.surah)) {
        final startAt = await api.ayahOffset(
          recording.id,
          ayah.surah,
          ayah.number,
        );
        if (!mounted) return;
        context.read<RecentRecitersCubit>().played(reciter.id);
        await play.playSurahs(
          reciter,
          recording,
          ayah.surah,
          lang,
          ayah: ayah.number,
          startAt: startAt,
        );
        if (!mounted) return;
        await Navigator.of(context).push(
          MushafScreen.route(ayah.surah, ayah: ayah.number, highlight: true),
        );
        return;
      }
    }
    if (ayah != null) {
      final verse =
          match?.voice.ayahReciter ??
          context.read<QuranPrefsCubit>().state.reciter;
      await play.playAyahs(ayah.surah, ayah.number, verse, lang);
      if (!mounted) return;
      if (match != null) {
        context.read<RecentRecitersCubit>().played(match.voice.reciterId);
      }
      await Navigator.of(context).push(
        MushafScreen.route(ayah.surah, ayah: ayah.number, highlight: true),
      );
      return;
    }
    if (match == null || !mounted) return;
    final reciters = await context.read<RecitersApi>().fetch(context.lang);
    if (!mounted) return;
    final reciter = reciters
        .where((r) => r.id == match.voice.reciterId)
        .firstOrNull;
    if (reciter == null) return;
    context.read<RecentRecitersCubit>().played(reciter.id);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ReciterScreen(reciter: reciter)),
    );
  }

  String _place(BuildContext context, VerseSpan span) {
    final l = context.l;
    String name(int surah) {
      final s = surahs[surah - 1];
      return context.isAr ? s.arabic : s.name;
    }

    if (span.start.surah != span.end.surah) {
      return l.identifyCrossing(
        context.n(span.start.number),
        name(span.start.surah),
        context.n(span.end.number),
        name(span.end.surah),
      );
    }
    if (span.start.number != span.end.number) {
      return l.identifySpan(
        context.n(span.start.number),
        name(span.start.surah),
        context.n(span.end.number),
      );
    }
    return l.identifyPlace(
      name(span.start.surah),
      context.n(span.start.number),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final dark = Palette.dark;
    final bg = dark ? const Color(0xFF000000) : const Color(0xFFF4F3EF);
    final ink = dark ? const Color(0xFFF4F4F4) : const Color(0xFF1A1A1A);
    final soft = dark ? const Color(0xFF9A9A9A) : const Color(0xFF8E8E8E);
    final listening = _phase == _Phase.listening;
    final busy = _phase == _Phase.downloading ||
        _phase == _Phase.listening ||
        _phase == _Phase.matching;
    final title = switch (_phase) {
      _Phase.downloading => l.identifyDownloading,
      _Phase.listening => l.identifyListening,
      _Phase.matching => l.identifyMatching,
      _Phase.result when _match != null => _match!.voice.name(context.lang),
      _ => l.identifyTap,
    };
    final span = _span;
    final subtitle = switch (_phase) {
      _Phase.listening => l.identifyHold,
      _Phase.result when span != null => _place(context, span),
      _Phase.result when _match != null => _match!.voice.recordingName,
      _ when _message != null => _message!,
      _ => l.identifyHold,
    };
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          foregroundColor: ink,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: Column(
            children: [
              const Spacer(),
              _ListenOrb(
                pulse: _pulse,
                active: listening,
                progress: listening || _phase == _Phase.downloading
                    ? _progress
                    : null,
                onTap: busy ? null : _listen,
              ),
              const SizedBox(height: 28),
              _Dots(active: listening, pulse: _pulse),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Fonts.body(22, color: ink, weight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Fonts.body(15, color: soft),
              ),
              const Spacer(),
              if (_phase == _Phase.result && (_ayah != null || _match != null))
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _open,
                    style: FilledButton.styleFrom(
                      backgroundColor: _ListenOrb.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      _ayah == null ? l.identifyOpenReciter : l.identifyOpen,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListenOrb extends StatelessWidget {
  const _ListenOrb({
    required this.pulse,
    required this.active,
    required this.progress,
    required this.onTap,
  });

  static const green = Color(0xFF1E7A46);

  final Animation<double> pulse;
  final bool active;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Palette.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
      width: 268,
      height: 268,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final grow = active ? 6 * pulse.value : 0.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 268 + grow,
                height: 268 + grow,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark
                      ? const Color(0xFF161616)
                      : const Color(0xFFE6E8E3),
                ),
              ),
              Container(
                width: 214,
                height: 214,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark
                      ? const Color(0xFF0E0E0E)
                      : const Color(0xFFF7F7F4),
                ),
              ),
              Material(
                color: green,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 156,
                    height: 156,
                    child: CustomPaint(
                      painter: _WavePainter(
                        t: active ? pulse.value : .35,
                      ),
                    ),
                  ),
                ),
              ),
              if (progress != null)
                IgnorePointer(
                  child: SizedBox(
                    width: 188,
                    height: 188,
                    child: CircularProgressIndicator(
                      value: progress == 0 ? null : progress,
                      strokeWidth: 3,
                      color: green,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7;
    final mid = size.center(Offset.zero);
    const base = [18.0, 28.0, 40.0, 30.0, 20.0];
    for (var i = 0; i < base.length; i++) {
      final wave = .55 + .45 * math.sin((t * math.pi) + i * .7);
      final h = base[i] * (.7 + .5 * wave);
      final x = mid.dx + (i - 2) * 16;
      final lean = (i - 2) * .18;
      canvas.save();
      canvas.translate(x, mid.dy);
      canvas.rotate(lean);
      canvas.drawLine(Offset(0, h / 2), Offset(0, -h / 2), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.t != t;
}

class _Dots extends StatelessWidget {
  const _Dots({required this.active, required this.pulse});

  final bool active;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 7),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active && (pulse.value * 4).floor() % 4 == i
                      ? _ListenOrb.green
                      : const Color(0xFFD5D6D2),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
