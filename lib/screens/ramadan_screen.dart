import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/extra_reminders_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/ramadan_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/islamic_api.dart';
import '../services/islamic_events.dart';
import '../services/prayer_calc.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/extra_reminder_tile.dart';
import '../widgets/star_pattern.dart';

/// Today's Hijri date, from the prayer day when it's known.
HijriDate hijriToday(BuildContext context, PrayerDay? day, DateTime now) {
  if (day != null && day.hijriMonth > 0) {
    return HijriDate(day.hijriYear, day.hijriMonth, day.hijriDay);
  }
  final shift = context.read<SettingsCubit>().state.hijriShift;
  return HijriDate.of(now, shift: shift);
}

/// What the countdown is counting to, or null outside Ramadan.
({bool iftar, DateTime at, DateTime now})? ramadanCountdown(
  PrayerDay day,
  DateTime now,
) {
  if (day.hijriMonth != 9) return null;
  final cityNow = day.cityNow(now);
  Prayer? find(List<Prayer> ps, String name) =>
      ps.where((p) => p.name == name).firstOrNull;
  final fajr = find(day.prayers, 'Fajr');
  final maghrib = find(day.prayers, 'Maghrib');
  if (fajr == null || maghrib == null) return null;
  if (cityNow.isBefore(fajr.on(cityNow))) {
    return (iftar: false, at: fajr.on(cityNow), now: cityNow);
  }
  if (cityNow.isBefore(maghrib.on(cityNow))) {
    return (iftar: true, at: maghrib.on(cityNow), now: cityNow);
  }
  final tomorrow = DateTime(cityNow.year, cityNow.month, cityNow.day + 1);
  final next = day.following.isEmpty ? fajr : find(day.following.first, 'Fajr');
  return (iftar: false, at: (next ?? fajr).on(tomorrow), now: cityNow);
}

class RamadanScreen extends StatelessWidget {
  const RamadanScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: 'ramadan'),
    builder: (_) => const RamadanScreen(),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final now = context.watch<ClockCubit>().state;
    final day = context.select((PrayerTimesBloc b) => b.state.day);
    final hijri = hijriToday(context, day, now);
    final inRamadan = hijri.month == 9;

    return Scaffold(
      appBar: AppBar(title: Text(l.featRamadan)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          if (inRamadan && day != null)
            const RamadanCard(standalone: true)
          else
            _Until(hijri: hijri, now: now),
          const SizedBox(height: 12),
          _DuaCard(
            title: l.iftarDua,
            arabic: _iftarDua,
            meaning: l.iftarDuaMeaning,
            source: l.iftarDuaSource,
          ),
          if (!inRamadan || hijri.day >= 20) ...[
            const SizedBox(height: 12),
            _DuaCard(
              title: l.qadrDua,
              arabic: _qadrDua,
              meaning: l.qadrDuaMeaning,
              source: l.qadrDuaSource,
            ),
          ],
          const SizedBox(height: 20),
          SectionHeader(l.ramadanTracker(context.n(hijri.year))),
          _Tracker(year: hijri.year, today: inRamadan ? hijri.day : null),
          const SizedBox(height: 20),
          SectionHeader(l.reminders),
          const AppCard(
            padding: EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: Column(
              children: [
                ExtraReminderTile(ExtraKind.suhoor),
                ExtraRemindersDenied(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _iftarDua =
    'ذَهَبَ الظَّمَأُ، وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ';
const _qadrDua = 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي';

/// Iftar or suhoor countdown; shown on Home through Ramadan.
class RamadanCard extends StatelessWidget {
  const RamadanCard({super.key, this.standalone = false});

  /// On the Ramadan screen itself, so tapping doesn't open it again.
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final now = context.watch<ClockCubit>().state;
    final day = context.select((PrayerTimesBloc b) => b.state.day);
    if (day == null) return const SizedBox.shrink();
    final c = ramadanCountdown(day, now);
    if (c == null) return const SizedBox.shrink();

    return AppCard(
      color: Palette.green,
      padding: EdgeInsets.zero,
      onTap: standalone
          ? null
          : () => Navigator.of(context).push(RamadanScreen.route()),
      child: Stack(
        children: [
          const Positioned.fill(
            child: StarPattern(color: Color(0x14F4EFE6), cell: 44),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              children: [
                Icon(
                  c.iftar
                      ? Icons.nights_stay_outlined
                      : Icons.wb_twilight_rounded,
                  color: Palette.brass,
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.ramadanDay(context.n(day.hijriDay)),
                        style: Fonts.body(
                          13,
                          color: Palette.cream.withValues(alpha: .75),
                        ),
                      ),
                      Text(
                        c.iftar ? l.iftarIn : l.suhoorEndsIn,
                        style: Fonts.body(15, color: Palette.cream),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.duration(c.at.difference(c.now)),
                      style: Fonts.display(22, color: Palette.cream),
                    ),
                    Text(
                      context.n(
                        MaterialLocalizations.of(
                          context,
                        ).formatTimeOfDay(TimeOfDay.fromDateTime(c.at)),
                      ),
                      style: Fonts.body(
                        12.5,
                        color: Palette.cream.withValues(alpha: .75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Until extends StatelessWidget {
  const _Until({required this.hijri, required this.now});

  final HijriDate hijri;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final shift = context.select((SettingsCubit c) => c.state.hijriShift);
    final next = upcomingEvents(
      now,
      shift: shift,
    ).where((e) => e.$1 == IslamicEvent.ramadan).firstOrNull;
    final today = DateTime(now.year, now.month, now.day);
    final days = next?.$3.difference(today).inDays;
    return AppCard(
      color: Palette.green,
      child: Row(
        children: [
          Icon(Icons.nightlight_round, color: Palette.brass, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days == null ? l.featRamadan : l.ramadanIn(context.n(days)),
                  style: Fonts.display(22, color: Palette.cream),
                ),
                if (next != null)
                  Text(
                    context.date(next.$3, 'EEEE d MMMM y'),
                    style: Fonts.body(
                      13,
                      color: Palette.cream.withValues(alpha: .75),
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

class _DuaCard extends StatelessWidget {
  const _DuaCard({
    required this.title,
    required this.arabic,
    required this.meaning,
    required this.source,
  });

  final String title;
  final String arabic;
  final String meaning;
  final String source;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Caption(title),
          const SizedBox(height: 10),
          Text(
            arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Fonts.arabic(22, color: Palette.green),
          ),
          if (!context.isAr) ...[
            const SizedBox(height: 8),
            Text(
              meaning,
              textAlign: TextAlign.center,
              style: Fonts.quote(16, color: Palette.ink),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            source,
            textAlign: TextAlign.center,
            style: Fonts.body(12, color: Palette.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// Thirty days, each with fast / taraweeh / juz.
class _Tracker extends StatelessWidget {
  const _Tracker({required this.year, required this.today});

  final int year;

  /// Day of Ramadan, or null outside it.
  final int? today;

  static IconData icon(RamadanDeed d) => switch (d) {
    RamadanDeed.fast => Icons.no_food_outlined,
    RamadanDeed.taraweeh => Icons.mosque_outlined,
    RamadanDeed.quran => Icons.menu_book_rounded,
  };

  static String label(L10n l, RamadanDeed d) => switch (d) {
    RamadanDeed.fast => l.deedFast,
    RamadanDeed.taraweeh => l.deedTaraweeh,
    RamadanDeed.quran => l.deedJuz,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<RamadanCubit>();
    context.watch<RamadanCubit>();
    final log = cubit.of(year);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final d in RamadanDeed.values)
                Expanded(
                  child: Column(
                    children: [
                      Icon(icon(d), size: 20, color: Palette.green),
                      Text(
                        '${context.n(log.count(d))}/${context.n(30)}',
                        style: Fonts.mono(15),
                      ),
                      Text(
                        label(l, d),
                        style: Fonts.body(11.5, color: Palette.inkSoft),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var n = 1; n <= 30; n++)
                _DayCell(
                  day: n,
                  deeds: log.on(n),
                  today: n == today,
                  future: today == null || n > today!,
                  onTap: () => _edit(context, n),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.ramadanTrackerHint,
            style: Fonts.body(12, color: Palette.inkSoft),
          ),
        ],
      ),
    );
  }

  void _edit(BuildContext context, int n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<RamadanCubit>(),
        child: Builder(
          builder: (context) {
            final l = context.l;
            final cubit = context.watch<RamadanCubit>();
            final deeds = cubit.of(year).on(n);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.ramadanDay(context.n(n)), style: Fonts.display(22)),
                    const SizedBox(height: 8),
                    for (final d in RamadanDeed.values)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: deeds.contains(d),
                        activeColor: Palette.green,
                        secondary: Icon(icon(d), color: Palette.green),
                        title: Text(label(l, d), style: Fonts.body(15)),
                        onChanged: (_) => cubit.toggle(year, n, d),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.deeds,
    required this.today,
    required this.future,
    required this.onTap,
  });

  final int day;
  final Set<RamadanDeed> deeds;
  final bool today;
  final bool future;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final all = deeds.length == RamadanDeed.values.length;
    return Material(
      color: all
          ? Palette.green
          : deeds.isNotEmpty
          ? Palette.greenSoft
          : Palette.paperDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: today
            ? BorderSide(color: Palette.brass, width: 1.6)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.n(day),
              style: Fonts.body(
                13,
                weight: FontWeight.w600,
                color: all
                    ? Palette.cream
                    : future && deeds.isEmpty
                    ? Palette.inkSoft
                    : Palette.ink,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final d in RamadanDeed.values)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: deeds.contains(d)
                          ? (all ? Palette.cream : Palette.green)
                          : Palette.rule,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
