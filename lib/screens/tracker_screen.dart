import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/prayer_log_cubit.dart';
import '../l10n/l10n.dart';
import '../services/notifications.dart' show reminderPrayers;
import '../theme.dart';
import '../widgets/common.dart';

/// Streaks, history and qada for the five daily prayers.
class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const TrackerScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.tracker)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          const _Summary(),
          const SizedBox(height: 20),
          SectionHeader(l.trackerWeek),
          const _Week(),
          const SizedBox(height: 20),
          SectionHeader(l.trackerByPrayer),
          const _ByPrayer(),
          const SizedBox(height: 20),
          SectionHeader(l.qadaTitle),
          const _Qada(),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final log = context.watch<PrayerLogCubit>().state;
    final now = context.watch<ClockCubit>().state;
    String pct(double v) => '${context.n((v * 100).round())}%';

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              icon: Icons.local_fire_department_rounded,
              value: context.n(log.streak(now)),
              label: l.trackerStreak,
            ),
          ),
          Container(width: .7, height: 48, color: Palette.rule),
          Expanded(
            child: _Stat(
              icon: Icons.date_range_rounded,
              value: pct(log.rate(now, 7)),
              label: l.trackerLast7,
            ),
          ),
          Container(width: .7, height: 48, color: Palette.rule),
          Expanded(
            child: _Stat(
              icon: Icons.calendar_month_outlined,
              value: pct(log.rate(now, 30)),
              label: l.trackerLast30,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Palette.green),
        const SizedBox(height: 4),
        Text(value, style: Fonts.display(24)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Fonts.body(11.5, color: Palette.inkSoft),
        ),
      ],
    );
  }
}

/// The last seven days; tapping a circle logs a prayer on that day.
class _Week extends StatelessWidget {
  const _Week();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<PrayerLogCubit>();
    final log = context.watch<PrayerLogCubit>().state;
    final now = context.watch<ClockCubit>().state;
    final days = [
      for (var i = 6; i >= 0; i--) DateTime(now.year, now.month, now.day - i),
    ];

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 64),
              for (final d in days)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        context.date(d, 'EEE'),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: Fonts.body(11, color: Palette.inkSoft),
                      ),
                      Text(
                        context.n(d.day),
                        style: Fonts.body(
                          12.5,
                          weight: FontWeight.w600,
                          color: d == days.last ? Palette.green : null,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (final p in reminderPrayers)
            Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    context.prayerName(p),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Fonts.body(12.5),
                  ),
                ),
                for (final d in days)
                  Expanded(
                    child: _Dot(
                      on: log.on(d).contains(p),
                      onTap: () => cubit.toggleOn(d, p),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Text(l.trackerTapHint, style: Fonts.body(12, color: Palette.inkSoft)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? Palette.green : null,
              border: Border.all(
                color: on ? Palette.green : Palette.rule,
                width: 1.5,
              ),
            ),
            child: on
                ? const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Palette.cream,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _ByPrayer extends StatelessWidget {
  const _ByPrayer();

  @override
  Widget build(BuildContext context) {
    final log = context.watch<PrayerLogCubit>().state;
    final now = context.watch<ClockCubit>().state;
    if (log.firstDay == null) {
      return AppCard(
        child: Text(
          context.l.trackerEmpty,
          style: Fonts.body(14, color: Palette.inkSoft),
        ),
      );
    }
    return AppCard(
      child: Column(
        children: [
          for (final (i, p) in reminderPrayers.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(context.prayerName(p), style: Fonts.body(13)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: log.rate(now, 30, prayer: p),
                      minHeight: 10,
                      color: Palette.green,
                      backgroundColor: Palette.green.withValues(alpha: .12),
                    ),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '${context.n((log.rate(now, 30, prayer: p) * 100).round())}%',
                    textAlign: TextAlign.end,
                    style: Fonts.mono(13),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Qada extends StatelessWidget {
  const _Qada();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<PrayerLogCubit>();
    final log = context.watch<PrayerLogCubit>().state;
    final total = log.qadaTotal;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            total == 0 ? l.qadaNone : l.qadaLeft(context.n(total)),
            style: Fonts.body(
              15,
              weight: FontWeight.w600,
              color: total == 0 ? Palette.green : Palette.ink,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Text(
              l.qadaHint,
              style: Fonts.body(12.5, color: Palette.inkSoft),
            ),
          ),
          const SizedBox(height: 6),
          for (final p in reminderPrayers)
            Row(
              children: [
                Expanded(
                  child: Text(context.prayerName(p), style: Fonts.body(15)),
                ),
                IconButton(
                  tooltip: l.qadaMadeUp,
                  onPressed: (log.qada[p] ?? 0) == 0
                      ? null
                      : () => cubit.addQada(p, -1),
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: Palette.green,
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    context.n(log.qada[p] ?? 0),
                    textAlign: TextAlign.center,
                    style: Fonts.mono(17),
                  ),
                ),
                IconButton(
                  tooltip: l.qadaAdd,
                  onPressed: () => cubit.addQada(p, 1),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: Palette.green,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
