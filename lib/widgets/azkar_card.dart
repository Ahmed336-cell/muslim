import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/azkar_cubit.dart';
import '../bloc/clock_cubit.dart';
import '../bloc/hisn_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../l10n/l10n.dart';
import '../screens/azkar_screen.dart';
import '../screens/hisn_screen.dart';
import '../screens/sleep_screen.dart';
import '../services/hisn.dart';
import '../services/islamic_api.dart';
import '../theme.dart';
import 'azkar_reminder_settings.dart';
import 'common.dart';

/// Which adhkar are due now, from today's prayer times when known.
AzkarTime azkarTimeNow(BuildContext context) => azkarTimeOf(
  context.select((PrayerTimesBloc b) => b.state.day),
  context.watch<ClockCubit>().state,
);

AzkarTime azkarTimeOf(PrayerDay? day, DateTime now) {
  if (day == null) return AzkarTime.atHour(now);
  final cityNow = day.cityNow(now);
  DateTime? time(String name) =>
      day.prayers.where((p) => p.name == name).firstOrNull?.on(cityNow);
  final (fajr, dhuhr, maghrib) = (time('Fajr'), time('Dhuhr'), time('Maghrib'));
  if (fajr == null || dhuhr == null || maghrib == null) {
    return AzkarTime.atHour(cityNow);
  }
  return AzkarTime.at(cityNow, fajr: fajr, dhuhr: dhuhr, maghrib: maghrib);
}

/// Home card for whichever adhkar fit the time of day.
class AzkarNowCard extends StatelessWidget {
  const AzkarNowCard({super.key});

  @override
  Widget build(BuildContext context) {
    final time = azkarTimeNow(context);
    if (time == AzkarTime.sleep) return const _SleepAzkarCard();
    return AzkarSessionCard(session: time.session, wide: true);
  }
}

class _SleepAzkarCard extends StatelessWidget {
  const _SleepAzkarCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final chapter = context
        .select((HisnCubit c) => c.state.book?.chapters)
        ?.where((c) => c.id == sleepChapter)
        .firstOrNull;
    return AppCard(
      color: Palette.green,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: () => Navigator.push(
        context,
        chapter == null
            ? SleepScreen.route()
            : MaterialPageRoute<void>(
                builder: (_) => HisnChapterScreen(chapter: chapter),
              ),
      ),
      child: Row(
        children: [
          Icon(Icons.bedtime_rounded, color: Palette.brass, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.sleepAdhkar,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Fonts.body(
                    16,
                    color: Palette.cream,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.azkarSleepSub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Fonts.body(
                    12.5,
                    color: Palette.cream.withValues(alpha: .75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.arrow_forward_rounded, color: Palette.brass),
        ],
      ),
    );
  }
}

class AzkarSessionCard extends StatelessWidget {
  const AzkarSessionCard({super.key, required this.session, this.wide = false});

  final AzkarSession session;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final items = context.select(
      (HisnCubit c) => c.state.book?.session(session),
    );
    final azkar = context.watch<AzkarCubit>();
    final done = items == null ? 0 : azkar.doneIn(session, items);
    final total = items?.length ?? 0;
    final finished = total > 0 && done == total;
    final evening = session == AzkarSession.evening;
    final fg = evening ? Palette.cream : Palette.green;

    return AppCard(
      margin: wide
          ? const EdgeInsets.symmetric(horizontal: 16)
          : EdgeInsets.zero,
      color: evening ? Palette.green : Palette.greenSoft,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: () => Navigator.push(context, AzkarScreen.route(session)),
      child: Row(
        children: [
          Icon(
            azkarIcon(session),
            color: evening ? Palette.brass : fg,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wide
                      ? azkarTitle(l, session)
                      : evening
                      ? l.evening
                      : l.morning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Fonts.body(16, color: fg, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  finished
                      ? l.azkarAllDone
                      : total == 0
                      ? ''
                      : l.azkarProgress(context.n(done), context.n(total)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Fonts.body(12.5, color: fg.withValues(alpha: .75)),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: done / total,
                      minHeight: 3,
                      color: evening ? Palette.brass : Palette.green,
                      backgroundColor: fg.withValues(alpha: .15),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (wide) ...[
            const SizedBox(width: 12),
            Icon(
              finished
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_rounded,
              color: evening ? Palette.brass : fg,
            ),
          ],
        ],
      ),
    );
  }
}
