import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_cubit.dart';
import '../bloc/reminders_cubit.dart';
import '../l10n/l10n.dart';
import '../services/adhan.dart';
import '../services/notifications.dart';
import '../theme.dart';

/// On/off switch and per-prayer choice for prayer-time notifications.
class ReminderSettings extends StatelessWidget {
  const ReminderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<RemindersCubit>();
    final r = context.watch<RemindersCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: r.enabled,
          activeThumbColor: Palette.cream,
          activeTrackColor: Palette.green,
          onChanged: (on) => on ? cubit.enable() : cubit.disable(),
          secondary: Icon(
            r.enabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_none_rounded,
            color: Palette.green,
          ),
          title: Text(l.prayerReminders, style: Fonts.body(15)),
          subtitle: Text(
            r.denied ? l.notificationsDenied : l.prayerRemindersSub,
            style: Fonts.body(
              12.5,
              color: r.denied ? Palette.clay : Palette.inkSoft,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in reminderPrayers)
              FilterChip(
                label: Text(context.prayerName(p)),
                selected: r.prayers.contains(p),
                onSelected: r.enabled ? (_) => cubit.toggle(p) : null,
                showCheckmark: true,
                checkmarkColor: Palette.green,
                selectedColor: Palette.greenSoft,
                backgroundColor: Palette.card,
                side: BorderSide(color: Palette.rule),
                labelStyle: Fonts.body(13.5),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: r.enabled,
          onTap: () => showAdhanVoices(context),
          leading: Icon(Icons.mosque_outlined, color: Palette.green),
          title: Text(l.adhanVoice, style: Fonts.body(15)),
          subtitle: Text(
            r.voice?.label(context.lang) ?? l.adhanPlainSound,
            style: Fonts.body(12.5, color: Palette.inkSoft),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
        ),
      ],
    );
  }
}

Future<void> showAdhanVoices(BuildContext context) async {
  final audio = context.read<AudioCubit>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AdhanVoices(),
  );
  // Stop a preview when the sheet closes.
  if ('${audio.state}'.startsWith('adhan:')) await audio.stop();
}

class _AdhanVoices extends StatelessWidget {
  const _AdhanVoices();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<RemindersCubit>();
    final selected = context.watch<RemindersCubit>().state.voice;
    final playing = context.watch<AudioCubit>().state;

    Widget option(AdhanVoice? v) {
      final key = 'adhan:${v?.name}';
      final isSelected = v == selected;
      return ListTile(
        onTap: () => cubit.setVoice(v),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 0, 8, 0),
        leading: Icon(
          isSelected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_off_rounded,
          color: isSelected ? Palette.green : Palette.rule,
        ),
        title: Text(
          v?.label(context.lang) ?? l.adhanPlainSound,
          style: Fonts.body(
            15,
            weight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: v == null || context.isAr
            ? null
            : Text(v.arabic, style: Fonts.arabic(14, color: Palette.inkSoft)),
        trailing: v == null
            ? null
            : IconButton(
                tooltip: l.previewTip,
                color: Palette.green,
                icon: Icon(
                  playing == key
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline_rounded,
                  size: 30,
                ),
                onPressed: () =>
                    context.read<AudioCubit>().toggle(key, Uri.parse(v.url)),
              ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(l.adhanVoice, style: Fonts.display(22)),
          ),
          for (final v in AdhanVoice.values) option(v),
          option(null),
          if (defaultTargetPlatform == TargetPlatform.iOS)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                l.adhanIosNote,
                style: Fonts.body(12.5, color: Palette.inkSoft),
              ),
            ),
        ],
      ),
    );
  }
}
