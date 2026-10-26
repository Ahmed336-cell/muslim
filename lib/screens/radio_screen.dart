import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../l10n/l10n.dart';
import '../services/quran_radio.dart';
import '../theme.dart';
import '../widgets/gramophone_disc.dart';
import '../widgets/listen_style.dart';
import '../widgets/mini_player.dart';

/// Live إذاعة القرآن الكريم from Cairo.
class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: 'radio'),
    builder: (_) => const RadioScreen(),
  );

  Future<void> _toggle(BuildContext context) async {
    final l = context.l;
    final cubit = context.read<RecitationCubit>();
    unawaited(context.read<AudioCubit>().stop());
    final on =
        cubit.state.kind == RecitationKind.radio &&
        cubit.state.current?.id == quranRadioId;
    if (on) {
      await cubit.toggle();
    } else {
      await cubit.playRadio(title: l.featRadio, artist: l.radioCity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<RecitationCubit>().state;
    final on = s.kind == RecitationKind.radio && s.current?.id == quranRadioId;
    final playing = on && s.playing;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Listen.bg,
        appBar: AppBar(
          backgroundColor: Listen.bg,
          foregroundColor: Listen.text,
          title: Text(l.featRadio),
        ),
        bottomNavigationBar: const MiniPlayer(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GramophoneDisc(name: l.featRadio, spinning: playing, size: 220),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: playing ? const Color(0xFFC62828) : Listen.surfaceHi,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l.radioLive,
                    style: Fonts.body(
                      12,
                      color: Listen.text,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l.featRadio,
                  textAlign: TextAlign.center,
                  style: Fonts.display(26, color: Listen.text),
                ),
                const SizedBox(height: 6),
                Text(
                  l.featRadioSub,
                  textAlign: TextAlign.center,
                  style: Fonts.body(15, color: Listen.textSoft),
                ),
                if (on && s.error) ...[
                  const SizedBox(height: 12),
                  Text(
                    l.playbackError,
                    textAlign: TextAlign.center,
                    style: Fonts.body(13, color: Palette.clay),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox.square(
                  dimension: 76,
                  child: Material(
                    color: Listen.text,
                    shape: const CircleBorder(),
                    child: on && s.buffering && s.playing
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Listen.bg,
                            ),
                          )
                        : IconButton(
                            tooltip: playing ? l.pauseTip : l.playTip,
                            iconSize: 42,
                            color: Listen.bg,
                            icon: Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                            onPressed: () => _toggle(context),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
