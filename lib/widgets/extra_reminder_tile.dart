import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/extra_reminders_cubit.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

/// On/off switch for one [ExtraKind] notification.
class ExtraReminderTile extends StatelessWidget {
  const ExtraReminderTile(this.kind, {super.key});

  final ExtraKind kind;

  Future<void> _pickTime(BuildContext context, int minutes) async {
    final cubit = context.read<ExtraRemindersCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (picked == null) return;
    await cubit.setTime(kind, picked.hour * 60 + picked.minute);
    if (!cubit.state.on.contains(kind)) await cubit.setEnabled(kind, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<ExtraRemindersCubit>().state;
    final on = s.on.contains(kind);
    final (icon, title, sub) = switch (kind) {
      ExtraKind.ayah => (
        Icons.auto_stories_outlined,
        l.dailyAyahReminder,
        null,
      ),
      ExtraKind.kahf => (
        Icons.menu_book_rounded,
        l.kahfReminder,
        l.kahfReminderSub,
      ),
      ExtraKind.salawat => (
        Icons.favorite_outline_rounded,
        l.salawatReminder,
        l.salawatReminderSub,
      ),
      ExtraKind.fridayHour => (
        Icons.hourglass_bottom_rounded,
        l.fridayHourReminder,
        l.fridayHourReminderSub,
      ),
      ExtraKind.tahajjud => (
        Icons.nightlight_round,
        l.tahajjudReminder,
        l.tahajjudReminderSub,
      ),
      ExtraKind.sleepAzkar => (
        Icons.bedtime_outlined,
        l.sleepAzkarReminder,
        l.sleepAzkarReminderSub,
      ),
      ExtraKind.duha => (
        Icons.wb_sunny_outlined,
        l.duhaReminder,
        l.duhaReminderSub,
      ),
      ExtraKind.suhoor => (
        Icons.wb_twilight_rounded,
        l.suhoorReminder,
        l.suhoorReminderSub,
      ),
      ExtraKind.wird => (Icons.menu_book_rounded, l.wirdReminder, null),
      ExtraKind.sadaqah => (
        Icons.volunteer_activism_outlined,
        l.sadaqahReminder,
        null,
      ),
    };

    final Widget? subtitle;
    if (kind.defaultTime != null) {
      final minutes = s.timeOf(kind);
      final time = context.n(
        MaterialLocalizations.of(
          context,
        ).formatTimeOfDay(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60)),
      );
      subtitle = InkWell(
        onTap: () => _pickTime(context, minutes),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  kind == ExtraKind.sadaqah
                      ? l.sadaqahRemindAt(time)
                      : l.azkarRemindAt(time),
                  style: Fonts.body(
                    12.5,
                    color: on ? Palette.green : Palette.inkSoft,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.edit_outlined,
                size: 14,
                color: on ? Palette.green : Palette.inkSoft,
              ),
            ],
          ),
        ),
      );
    } else {
      subtitle = Text(sub!, style: Fonts.body(12.5, color: Palette.inkSoft));
    }

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: on,
      activeThumbColor: Palette.cream,
      activeTrackColor: Palette.green,
      onChanged: (v) => context.read<ExtraRemindersCubit>().setEnabled(kind, v),
      secondary: Icon(icon, color: Palette.green),
      title: Text(title, style: Fonts.body(15)),
      subtitle: subtitle,
    );
  }
}

/// Shown under the switches when notifications were refused.
class ExtraRemindersDenied extends StatelessWidget {
  const ExtraRemindersDenied({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.watch<ExtraRemindersCubit>().state.denied) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        context.l.notificationsDenied,
        style: Fonts.body(12.5, color: Palette.clay),
      ),
    );
  }
}
