import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/ambient_cubit.dart';
import '../l10n/l10n.dart';
import '../services/ambient.dart';
import '../theme.dart';
import 'listen_style.dart';

/// Pick background sounds and balance their volumes.
class AmbientMixer extends StatelessWidget {
  const AmbientMixer({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<AmbientCubit>();
    final mix = context.watch<AmbientCubit>().state;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.ambientTitle,
                      style: Fonts.body(
                        15.5,
                        color: Listen.text,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l.ambientSub,
                      style: Fonts.body(12.5, color: Listen.textSoft),
                    ),
                  ],
                ),
              ),
              if (mix.volumes.isNotEmpty)
                TextButton(
                  onPressed: cubit.clearMix,
                  style: TextButton.styleFrom(foregroundColor: Listen.textSoft),
                  child: Text(l.ambientClear),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in Ambient.values)
                _SoundChip(
                  sound: a,
                  selected: mix.contains(a),
                  onTap: () => cubit.toggle(a),
                ),
            ],
          ),
          for (final MapEntry(key: a, value: v) in mix.volumes.entries)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(a.icon, size: 18, color: Listen.accent),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 92,
                    child: Text(
                      ambientName(l, a),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Fonts.body(12.5, color: Listen.textSoft),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                      ),
                      child: Slider(
                        value: v,
                        activeColor: Listen.accent,
                        inactiveColor: Listen.textFaint,
                        thumbColor: Listen.text,
                        onChanged: (x) => cubit.setVolume(a, x),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SoundChip extends StatelessWidget {
  const _SoundChip({
    required this.sound,
    required this.selected,
    required this.onTap,
  });

  final Ambient sound;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Listen.accent : Listen.surfaceHi,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                sound.icon,
                size: 18,
                color: selected ? Listen.bg : Listen.text,
              ),
              const SizedBox(width: 6),
              Text(
                ambientName(context.l, sound),
                style: Fonts.body(
                  13,
                  color: selected ? Listen.bg : Listen.text,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
