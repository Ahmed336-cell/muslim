import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/qada_cubit.dart';
import '../bloc/ramadan_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../services/prayer_calc.dart';
import '../theme.dart';
import '../widgets/common.dart';

String _money(double v) =>
    v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Missed fasts to make up, fidyah and kaffarah.
class QadaScreen extends StatelessWidget {
  const QadaScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const QadaScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.featQada)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          const _Owed(),
          const _FromRamadan(),
          const SizedBox(height: 20),
          SectionHeader(l.qadaFidyah),
          const _Fidyah(),
          const SizedBox(height: 20),
          SectionHeader(l.qadaKaffarah),
          const _Kaffarah(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              l.qadaDisclaimer,
              textAlign: TextAlign.center,
              style: Fonts.body(12, color: Palette.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Owed extends StatelessWidget {
  const _Owed();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final q = context.watch<QadaCubit>().state;
    final now = context.watch<ClockCubit>().state;
    final cubit = context.read<QadaCubit>();
    final today = q.madeOn(now);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Caption(l.qadaRemaining),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(context.n(q.remaining), style: Fonts.display(40)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.qadaMadeOf(context.n(q.made.length), context.n(q.owed)),
                  style: Fonts.body(13.5, color: Palette.inkSoft),
                ),
              ),
              IconButton.outlined(
                tooltip: l.qadaLess,
                onPressed: q.owed > q.made.length
                    ? () => cubit.setOwed(q.owed - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                tooltip: l.qadaMore,
                onPressed: () => cubit.setOwed(q.owed + 1),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          if (q.owed > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: q.made.length / q.owed,
                minHeight: 8,
                color: Palette.green,
                backgroundColor: Palette.green.withValues(alpha: .12),
              ),
            ),
            const SizedBox(height: 14),
            if (today || q.remaining > 0)
              FilledButton.icon(
                style: today
                    ? FilledButton.styleFrom(
                        backgroundColor: Palette.greenSoft,
                        foregroundColor: Palette.green,
                      )
                    : null,
                onPressed: cubit.toggleToday,
                icon: Icon(
                  today ? Icons.check_circle_rounded : Icons.check_rounded,
                ),
                label: Text(today ? l.qadaFastedToday : l.qadaMarkToday),
              )
            else
              Text(
                l.qadaAllDone,
                textAlign: TextAlign.center,
                style: Fonts.body(14, color: Palette.green),
              ),
            const SizedBox(height: 8),
            Text(l.qadaTip, style: Fonts.body(12.5, color: Palette.inkSoft)),
          ] else ...[
            const SizedBox(height: 8),
            Text(l.qadaIntro, style: Fonts.body(13.5, color: Palette.inkSoft)),
          ],
        ],
      ),
    );
  }
}

/// Offers the days not marked as fasted in the last Ramadan tracker.
class _FromRamadan extends StatelessWidget {
  const _FromRamadan();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final log = context.watch<RamadanCubit>().state;
    final q = context.watch<QadaCubit>().state;
    final now = HijriDate.of(context.watch<ClockCubit>().state);
    final over = log.year > 0 && (now.year > log.year || now.month > 9);
    if (!over || q.imported.contains(log.year)) return const SizedBox.shrink();
    final fasted = log.count(RamadanDeed.fast);
    if (fasted == 0) return const SizedBox.shrink();
    final missed = (HijriDate(log.year, 9, 1).monthLength - fasted).clamp(
      0,
      30,
    );
    if (missed == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppCard(
        child: Row(
          children: [
            Icon(Icons.nightlight_round, color: Palette.clay),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.qadaFromRamadan(context.n(missed), context.n(log.year)),
                style: Fonts.body(13.5),
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.read<QadaCubit>().importRamadan(log.year, missed),
              child: Text(l.qadaAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fidyah extends StatelessWidget {
  const _Fidyah();

  Future<void> _setCost(
    BuildContext context,
    double cost,
    String currency,
  ) async {
    final cubit = context.read<QadaCubit>();
    final value = await showAmountDialog(
      context,
      title: context.l.qadaMealCost,
      initial: cost > 0 ? _money(cost) : '',
      currency: currency,
      clearLabel: context.l.cancel,
    );
    if (value != null) cubit.setMealCost(value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final q = context.watch<QadaCubit>().state;
    final currency = context.select((SettingsCubit c) => c.state.city.currency);
    final days = q.remaining;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.qadaFidyahInfo, style: Fonts.body(13.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  q.mealCost > 0
                      ? l.qadaFidyahTotal(
                          context.n(days),
                          '${context.n(_money(days * q.mealCost))} $currency',
                        )
                      : l.qadaFidyahMeals(context.n(days)),
                  style: Fonts.body(14.5, weight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => _setCost(context, q.mealCost, currency),
                child: Text(
                  q.mealCost > 0
                      ? '${context.n(_money(q.mealCost))} $currency'
                      : l.qadaMealCost,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Kaffarah extends StatelessWidget {
  const _Kaffarah();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final q = context.watch<QadaCubit>().state;
    final now = context.watch<ClockCubit>().state;
    final cubit = context.read<QadaCubit>();
    final start = q.kaffarahStart;
    if (start == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.qadaKaffarahInfo, style: Fonts.body(13.5)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: cubit.startKaffarah,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l.qadaKaffarahStart),
            ),
          ],
        ),
      );
    }
    final streak = q.kaffarahStreak(now);
    final broken = q.kaffarahBroken(now);
    final done = streak >= QadaLog.kaffarahLength;
    final today = q.kaffarahDays.contains(
      DateTime(now.year, now.month, now.day),
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.qadaKaffarahProgress(
                    context.n(streak),
                    context.n(QadaLog.kaffarahLength),
                  ),
                  style: Fonts.body(16, weight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: l.khatmahEnd,
                onPressed: cubit.stopKaffarah,
                icon: Icon(Icons.close_rounded, color: Palette.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: streak / QadaLog.kaffarahLength,
              minHeight: 8,
              color: broken ? Palette.clay : Palette.green,
              backgroundColor: Palette.green.withValues(alpha: .12),
            ),
          ),
          const SizedBox(height: 12),
          if (done)
            Text(
              l.qadaKaffarahDone,
              textAlign: TextAlign.center,
              style: Fonts.body(14, color: Palette.green),
            )
          else if (broken) ...[
            Text(
              l.qadaKaffarahBroken,
              style: Fonts.body(13.5, color: Palette.clay),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: cubit.startKaffarah,
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(l.qadaKaffarahRestart),
            ),
          ] else
            FilledButton.icon(
              style: today
                  ? FilledButton.styleFrom(
                      backgroundColor: Palette.greenSoft,
                      foregroundColor: Palette.green,
                    )
                  : null,
              onPressed: cubit.toggleKaffarahToday,
              icon: Icon(
                today ? Icons.check_circle_rounded : Icons.check_rounded,
              ),
              label: Text(today ? l.qadaFastedToday : l.qadaMarkToday),
            ),
        ],
      ),
    );
  }
}
