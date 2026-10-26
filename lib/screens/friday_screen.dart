import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/extra_reminders_cubit.dart';
import '../bloc/friday_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/extra_reminder_tile.dart';
import 'mushaf_screen.dart';

const _salawat = 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ';

/// The day of Jumu'ah: its deeds in order of priority, salawat and the
/// last hour.
class FridayScreen extends StatelessWidget {
  const FridayScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: 'friday'),
    builder: (_) => const FridayScreen(),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final done = context.watch<FridayCubit>().today.done.length;
    final total = FridayDeed.values.length;

    return Scaffold(
      appBar: AppBar(title: Text(l.featFriday)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          AppCard(
            color: Palette.green,
            child: Row(
              children: [
                const Icon(
                  Icons.mosque_outlined,
                  color: Palette.cream,
                  size: 36,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.jumuahMubarak,
                        style: Fonts.display(22, color: Palette.cream),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.fridayIntro,
                        style: Fonts.body(
                          13,
                          color: Palette.cream.withValues(alpha: .75),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox.square(
                  dimension: 54,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: done / total,
                        strokeWidth: 4,
                        color: Palette.brass,
                        backgroundColor: Palette.cream.withValues(alpha: .15),
                      ),
                      Center(
                        child: Text(
                          '${context.n(done)}/${context.n(total)}',
                          style: Fonts.mono(14, color: Palette.cream),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(l.fridayPriorities),
          const _Checklist(),
          const SizedBox(height: 12),
          const _LastHour(),
          const SizedBox(height: 12),
          const _SalawatCounter(),
          const SizedBox(height: 20),
          SectionHeader(l.reminders),
          const AppCard(
            padding: EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: Column(
              children: [
                ExtraReminderTile(ExtraKind.kahf),
                ExtraReminderTile(ExtraKind.salawat),
                ExtraReminderTile(ExtraKind.fridayHour),
                ExtraRemindersDenied(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _Rank { fard, muakkad, sunnah }

/// Friday's deeds, most important first, each with a tick for today.
class _Checklist extends StatelessWidget {
  const _Checklist();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final done = context.watch<FridayCubit>().today.done;
    final cubit = context.read<FridayCubit>();

    (IconData, String, _Rank) info(FridayDeed d) => switch (d) {
      FridayDeed.prayer => (Icons.mosque_outlined, l.deedJumuah, _Rank.fard),
      FridayDeed.ghusl => (Icons.shower_outlined, l.sunnahGhusl, _Rank.muakkad),
      FridayDeed.kahf => (Icons.menu_book_rounded, l.sunnahKahf, _Rank.sunnah),
      FridayDeed.salawat => (
        Icons.favorite_outline_rounded,
        l.sunnahSalawat,
        _Rank.sunnah,
      ),
      FridayDeed.early => (
        Icons.directions_walk_rounded,
        l.sunnahEarly,
        _Rank.sunnah,
      ),
      FridayDeed.clothes => (
        Icons.checkroom_outlined,
        l.sunnahClothes,
        _Rank.sunnah,
      ),
      FridayDeed.dua => (
        Icons.volunteer_activism_outlined,
        l.sunnahDua,
        _Rank.sunnah,
      ),
    };

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final (i, d) in FridayDeed.values.indexed) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            Builder(
              builder: (context) {
                final (icon, text, rank) = info(d);
                final ticked = done.contains(d);
                final (tag, tagColor) = switch (rank) {
                  _Rank.fard => (l.tagFard, Palette.clay),
                  _Rank.muakkad => (l.tagMuakkad, Palette.green),
                  _Rank.sunnah => (l.tagSunnah, Palette.inkSoft),
                };
                return InkWell(
                  onTap: () => cubit.toggle(d),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            context.n(i + 1),
                            style: Fonts.mono(13, color: Palette.inkSoft),
                          ),
                        ),
                        Icon(icon, size: 22, color: Palette.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style:
                                    Fonts.body(
                                      14.5,
                                      color: ticked ? Palette.inkSoft : null,
                                    ).copyWith(
                                      decoration: ticked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tag,
                                style: Fonts.body(
                                  11.5,
                                  color: tagColor,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (d == FridayDeed.kahf)
                          TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).push(MushafScreen.route(18)),
                            child: Text(l.kahfOpen),
                          ),
                        Checkbox(
                          value: ticked,
                          activeColor: Palette.green,
                          onChanged: (_) => cubit.toggle(d),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SalawatCounter extends StatelessWidget {
  const _SalawatCounter();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<FridayCubit>();
    final count = context.watch<FridayCubit>().today.salawat;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.salawatCounter,
                  style: Fonts.body(15, weight: FontWeight.w600),
                ),
              ),
              if (count > 0)
                IconButton(
                  tooltip: l.reset,
                  onPressed: cubit.resetSalawat,
                  icon: Icon(Icons.refresh_rounded, color: Palette.inkSoft),
                ),
            ],
          ),
          Text(
            _salawat,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Fonts.arabic(22, color: Palette.green),
          ),
          const SizedBox(height: 14),
          Material(
            color: Palette.green,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.lightImpact();
                cubit.salawat();
              },
              child: SizedBox.square(
                dimension: 110,
                child: Center(
                  child: Text(
                    context.n(count),
                    style: Fonts.display(38, color: Palette.cream),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(l.salawatHint, style: Fonts.body(12.5, color: Palette.inkSoft)),
        ],
      ),
    );
  }
}

class _LastHour extends StatelessWidget {
  const _LastHour();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final day = context.select((PrayerTimesBloc b) => b.state.day);
    final maghrib = day?.prayers.where((p) => p.name == 'Maghrib').firstOrNull;
    if (day == null || maghrib == null) return const SizedBox.shrink();
    final start = maghrib.hour * 60 + maghrib.minute - 60;
    final from = TimeOfDay(hour: start ~/ 60, minute: start % 60);
    final loc = MaterialLocalizations.of(context);
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.hourglass_bottom_rounded, color: Palette.brass, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.fridayHourTitle,
                  style: Fonts.body(15, weight: FontWeight.w600),
                ),
                Text(
                  l.fridayHourRange(
                    context.n(loc.formatTimeOfDay(from)),
                    context.n(
                      loc.formatTimeOfDay(
                        TimeOfDay(hour: maghrib.hour, minute: maghrib.minute),
                      ),
                    ),
                  ),
                  style: Fonts.body(13, color: Palette.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
