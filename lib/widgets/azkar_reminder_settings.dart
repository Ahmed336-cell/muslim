import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/azkar_reminders_cubit.dart';
import '../l10n/l10n.dart';
import '../services/hisn.dart';
import '../theme.dart';

String azkarTitle(L10n l, AzkarSession s) => switch (s) {
  AzkarSession.morning => l.morningAzkar,
  AzkarSession.evening => l.eveningAzkar,
};

IconData azkarIcon(AzkarSession s) => switch (s) {
  AzkarSession.morning => Icons.wb_twilight_rounded,
  AzkarSession.evening => Icons.nights_stay_outlined,
};

/// A switch and time per session for the daily adhkar notification.
class AzkarReminderSettings extends StatelessWidget {
  const AzkarReminderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final r = context.watch<AzkarRemindersCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in AzkarSession.values)
          _SessionRow(session: s, on: r.on.contains(s), minutes: r.timeOf(s)),
        if (r.denied)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.notificationsDenied,
              style: Fonts.body(12.5, color: Palette.clay),
            ),
          ),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.on,
    required this.minutes,
  });

  final AzkarSession session;
  final bool on;
  final int minutes;

  Future<void> _pickTime(BuildContext context) async {
    final cubit = context.read<AzkarRemindersCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (picked == null) return;
    await cubit.setTime(session, picked.hour * 60 + picked.minute);
    if (!on) await cubit.setEnabled(session, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final time = context.n(
      MaterialLocalizations.of(
        context,
      ).formatTimeOfDay(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60)),
    );

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: on,
      activeThumbColor: Palette.cream,
      activeTrackColor: Palette.green,
      onChanged: (v) =>
          context.read<AzkarRemindersCubit>().setEnabled(session, v),
      secondary: Icon(azkarIcon(session), color: Palette.green),
      title: Text(azkarTitle(l, session), style: Fonts.body(15)),
      subtitle: InkWell(
        onTap: () => _pickTime(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  l.azkarRemindAt(time),
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
      ),
    );
  }
}

Future<void> showAzkarReminders(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l.azkarReminders, style: Fonts.display(22)),
            const SizedBox(height: 4),
            Text(
              context.l.azkarRemindersSub,
              style: Fonts.body(13, color: Palette.inkSoft),
            ),
            const SizedBox(height: 8),
            const AzkarReminderSettings(),
          ],
        ),
      ),
    );
