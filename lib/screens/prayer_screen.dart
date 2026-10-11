import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/fasting/fasting_bloc.dart';
import '../bloc/prayer_log_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/islamic_api.dart';
import '../theme.dart';
import '../widgets/city_picker.dart';
import '../widgets/common.dart';
import '../widgets/fasting_section.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<PrayerTimesBloc>().state;
    final day = state.day;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.prayerTitle),
        actions: const [CityChip(), SizedBox(width: 12)],
      ),
      body: day == null
          ? Center(
              child: state.status == PrayerTimesStatus.failure
                  ? ErrorState(
                      error: state.error,
                      onRetry: () => context.read<PrayerTimesBloc>().add(
                        const PrayerTimesRequested(),
                      ),
                    )
                  : const Spinner(),
            )
          : RefreshIndicator(
              color: Palette.green,
              backgroundColor: Palette.card,
              onRefresh: () {
                context.read<FastingBloc>().add(const FastingRequested());
                final bloc = context.read<PrayerTimesBloc>()
                  ..add(const PrayerTimesRefreshed());
                return bloc.stream.firstWhere((s) => !s.isBusy);
              },
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 28),
                children: [
                  _DayCard(day: day),
                  const SizedBox(height: 12),
                  _PrayerList(day: day),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                    child: Text(
                      l.trackerHint,
                      style: Fonts.body(12, color: Palette.inkSoft),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(l.fastingTitle),
                  const FastingSection(),
                ],
              ),
            ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final PrayerDay day;

  @override
  Widget build(BuildContext context) {
    final now = context.watch<ClockCubit>().state;
    final prayed = context.watch<PrayerLogCubit>().today.length;
    final hijri = context.hijri(day);

    return AppCard(
      color: Palette.green,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.date(day.cityNow(now), 'EEEE'),
                  style: Fonts.body(
                    13,
                    color: Palette.paper.withValues(alpha: .7),
                  ),
                ),
                Text(
                  context.date(day.cityNow(now), 'd MMMM y'),
                  style: Fonts.display(22, color: Palette.paper),
                ),
                if (hijri.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(hijri, style: Fonts.body(13, color: Palette.brass)),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: prayed / 5,
                    strokeWidth: 4,
                    backgroundColor: Palette.paper.withValues(alpha: .15),
                    valueColor: const AlwaysStoppedAnimation(Palette.brass),
                  ),
                ),
                Text(
                  '${context.n(prayed)}/${context.n(5)}',
                  style: Fonts.mono(15, color: Palette.paper),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerList extends StatelessWidget {
  const _PrayerList({required this.day});

  final PrayerDay day;

  static const _icons = {
    'Fajr': Icons.wb_twilight_rounded,
    'Sunrise': Icons.wb_sunny_outlined,
    'Dhuhr': Icons.light_mode_outlined,
    'Asr': Icons.filter_drama_outlined,
    'Maghrib': Icons.nights_stay_outlined,
    'Isha': Icons.dark_mode_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final now = day.cityNow(context.watch<ClockCubit>().state);
    final prayed = context.watch<PrayerLogCubit>().today;
    final next = upcoming(day.prayers, now).next;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final (i, p) in day.prayers.indexed) ...[
            if (i > 0) const RowDivider(indent: 16),
            _PrayerRow(
              prayer: p,
              name: context.prayerName(p.name, day: now),
              icon: _icons[p.name] ?? Icons.schedule,
              isNext: p == next,
              isPast: p.on(now).isBefore(now) && p != next,
              prayed: prayed.contains(p.name),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.name,
    required this.icon,
    required this.isNext,
    required this.isPast,
    required this.prayed,
  });

  final Prayer prayer;
  final String name;
  final IconData icon;
  final bool isNext;
  final bool isPast;
  final bool prayed;

  @override
  Widget build(BuildContext context) {
    final fg = isNext
        ? Palette.green
        : (isPast ? Palette.inkSoft : Palette.ink);

    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsetsDirectional.only(start: 12),
      decoration: BoxDecoration(
        color: isNext ? Palette.greenSoft : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: fg),
          const SizedBox(width: 14),
          Text(
            name,
            style: Fonts.body(
              16,
              color: fg,
              weight: isNext ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isNext) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Palette.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                context.l.nextBadge,
                style: Fonts.body(11, color: Palette.paper),
              ),
            ),
          ],
          const Spacer(),
          Text(context.clock(prayer), style: Fonts.mono(17, color: fg)),
          const SizedBox(width: 4),
          SizedBox(
            width: 22,
            child: Text(
              context.period(prayer),
              style: Fonts.body(12, color: Palette.inkSoft),
            ),
          ),
          if (prayer.isObligatory)
            IconButton(
              onPressed: () =>
                  context.read<PrayerLogCubit>().toggle(prayer.name),
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: prayed ? Palette.green : null,
                  border: Border.all(
                    color: prayed ? Palette.green : Palette.rule,
                    width: 1.6,
                  ),
                ),
                child: prayed
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Palette.paper,
                      )
                    : null,
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
