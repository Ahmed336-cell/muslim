import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/fasting/fasting_bloc.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/islamic_api.dart';
import '../theme.dart';
import 'common.dart';

class FastingSection extends StatelessWidget {
  const FastingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FastingBloc>().state;
    final day = state.day;

    if (day != null) return _Body(day: day);
    return AppCard(
      child: SizedBox(
        height: 120,
        child: Center(
          child: state.status == FastingStatus.failure
              ? ErrorState(
                  error: state.error,
                  onRetry: () =>
                      context.read<FastingBloc>().add(const FastingRequested()),
                )
              : const Spinner(),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.day});

  final FastingDay day;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final now = context.watch<ClockCubit>().state;
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sunnah = switch (tomorrow.weekday) {
      DateTime.monday => l.sunnahMonday,
      DateTime.thursday => l.sunnahThursday,
      _ => null,
    };

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Time(
                      icon: Icons.wb_twilight_rounded,
                      label: l.sahurEnds,
                      time: day.sahur,
                    ),
                  ),
                  Container(width: .7, height: 52, color: Palette.rule),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Time(
                      icon: Icons.nights_stay_outlined,
                      label: l.iftar,
                      time: day.iftar,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                l.fastLength(context.duration(day.duration)),
                style: Fonts.body(13, color: Palette.inkSoft),
              ),
              if (sunnah != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.greenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        size: 18,
                        color: Palette.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sunnah,
                          style: Fonts.body(13, color: Palette.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (day.whiteDays.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.whiteDays,
                        style: Fonts.body(16, weight: FontWeight.w600),
                      ),
                    ),
                    if (day.whiteDaysEstimated)
                      Text(
                        l.approx,
                        style: Fonts.body(12, color: Palette.inkSoft),
                      ),
                  ],
                ),
                Text(
                  l.whiteDaysHint,
                  style: Fonts.body(12, color: Palette.inkSoft),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final (i, w) in day.whiteDays.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _WhiteDay(date: w, past: w.isBefore(today)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({required this.icon, required this.label, required this.time});

  final IconData icon;
  final String label;
  final Prayer time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Palette.inkSoft),
            const SizedBox(width: 6),
            Text(label, style: Fonts.body(13, color: Palette.inkSoft)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(context.clock(time), style: Fonts.display(30)),
            const SizedBox(width: 4),
            Text(
              context.period(time),
              style: Fonts.body(12, color: Palette.inkSoft),
            ),
          ],
        ),
      ],
    );
  }
}

class _WhiteDay extends StatelessWidget {
  const _WhiteDay({required this.date, required this.past});

  final DateTime date;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final fg = past ? Palette.inkSoft : Palette.ink;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: past ? null : Palette.paperDeep,
        border: Border.all(color: Palette.rule, width: .7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            context.date(date, 'EEE'),
            style: Fonts.body(12, color: Palette.inkSoft),
          ),
          Text(context.n(date.day), style: Fonts.display(24, color: fg)),
          Text(
            context.date(date, 'MMM'),
            style: Fonts.body(12, color: Palette.inkSoft),
          ),
        ],
      ),
    );
  }
}
