import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/extra_reminders_cubit.dart';
import '../bloc/quran/khatmah_cubit.dart';
import '../l10n/l10n.dart';
import '../services/mushaf_pages.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/extra_reminder_tile.dart';
import 'mushaf_screen.dart';

/// Plan, today's portion and progress for finishing the Quran.
class KhatmahScreen extends StatelessWidget {
  const KhatmahScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const KhatmahScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final k = context.watch<KhatmahCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.khatmah),
        actions: [
          if (k.active)
            IconButton(
              tooltip: l.khatmahEnd,
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: () => _confirmEnd(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          if (!k.active)
            const _Planner()
          else if (k.done)
            const _Finished()
          else
            const _Progress(),
        ],
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context) async {
    final l = context.l;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: Text(l.khatmahEndConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text(l.khatmahEnd),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      if (context.mounted) context.read<KhatmahCubit>().stop();
    }
  }
}

class _Planner extends StatefulWidget {
  const _Planner();

  @override
  State<_Planner> createState() => _PlannerState();
}

class _PlannerState extends State<_Planner> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final completed = context.watch<KhatmahCubit>().state.completed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_stories_rounded, color: Palette.green, size: 36),
              const SizedBox(height: 10),
              Text(l.khatmahIntro, style: Fonts.body(14.5)),
              if (completed > 0) ...[
                const SizedBox(height: 8),
                Text(
                  l.khatmahCompleted(context.n(completed)),
                  style: Fonts.body(13, color: Palette.green),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(l.khatmahFinishIn),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in KhatmahCubit.durations)
                ChoiceChip(
                  label: Text(l.khatmahDays(context.n(d))),
                  selected: d == _days,
                  onSelected: (_) => setState(() => _days = d),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l.khatmahPerDay(context.n((pageCount / _days).ceil())),
            style: Fonts.body(13.5, color: Palette.inkSoft),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: () => context.read<KhatmahCubit>().startPlan(_days),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l.khatmahStart),
          ),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final k = context.watch<KhatmahCubit>().state;
    final now = context.watch<ClockCubit>().state;
    final target = k.todayTarget(now);
    final today = k.readOn(now);
    final behind = k.expectedBy(now) - k.read.length;
    final status = behind <= 0
        ? (k.read.length > k.expectedBy(now)
              ? l.khatmahAhead
              : l.khatmahOnTrack)
        : l.khatmahBehind(context.n(behind));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Row(
            children: [
              SizedBox.square(
                dimension: 96,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: k.progress,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      color: Palette.green,
                      backgroundColor: Palette.green.withValues(alpha: .12),
                    ),
                    Center(
                      child: Text(
                        '${context.n((k.progress * 100).floor())}%',
                        style: Fonts.display(22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.khatmahDayOf(
                        context.n(k.dayOf(now)),
                        context.n(k.days),
                      ),
                      style: Fonts.body(16, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.khatmahPages(
                        context.n(k.read.length),
                        context.n(pageCount),
                      ),
                      style: Fonts.body(13.5, color: Palette.inkSoft),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status,
                      style: Fonts.body(
                        13,
                        weight: FontWeight.w600,
                        color: behind > 0 ? Palette.clay : Palette.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.khatmahToday,
                      style: Fonts.body(15, weight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    l.khatmahTodayGoal(context.n(today), context.n(target)),
                    style: Fonts.body(13.5, color: Palette.inkSoft),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: target == 0 ? 1 : (today / target).clamp(0, 1),
                  minHeight: 8,
                  color: Palette.green,
                  backgroundColor: Palette.green.withValues(alpha: .12),
                ),
              ),
              if (today >= target) ...[
                const SizedBox(height: 10),
                Text(
                  l.khatmahTodayDone,
                  style: Fonts.body(13, color: Palette.green),
                ),
              ] else if (k.portion(now) case (final first, final last)) ...[
                const SizedBox(height: 10),
                Text(
                  first == last
                      ? l.wirdPortionOne(context.n(first))
                      : l.wirdPortion(context.n(first), context.n(last)),
                  style: Fonts.body(13.5, weight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => Navigator.of(
                  context,
                ).push(MushafScreen.routeToPage(k.nextPage)),
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(l.khatmahContinue(context.n(k.nextPage))),
              ),
              if (today < target) ...[
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: context.read<KhatmahCubit>().readPortion,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l.wirdMarkDone),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: Palette.clay),
              const SizedBox(width: 12),
              Expanded(child: Text(l.khatmahStreak, style: Fonts.body(15))),
              Text(
                l.khatmahStreakDays(context.n(k.streak(now))),
                style: Fonts.body(15, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const AppCard(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              ExtraReminderTile(ExtraKind.wird),
              ExtraRemindersDenied(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _ReadUpTo(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Text(
            l.khatmahHint,
            style: Fonts.body(12.5, color: Palette.inkSoft),
          ),
        ),
      ],
    );
  }
}

class _ReadUpTo extends StatefulWidget {
  const _ReadUpTo();

  @override
  State<_ReadUpTo> createState() => _ReadUpToState();
}

class _ReadUpToState extends State<_ReadUpTo> {
  double? _page;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final next = context.watch<KhatmahCubit>().state.nextPage;
    final page = (_page ?? next.toDouble()).clamp(1.0, pageCount.toDouble());
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(l.khatmahReadUpTo, style: Fonts.body(15)),
          children: [
            Slider(
              value: page,
              min: 1,
              max: pageCount.toDouble(),
              divisions: pageCount - 1,
              label: context.n(page.round()),
              onChanged: (v) => setState(() => _page = v),
            ),
            Text(
              l.khatmahReadUpToSub(context.n(page.round())),
              style: Fonts.body(13, color: Palette.inkSoft),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton(
                onPressed: () {
                  context.read<KhatmahCubit>().readUpTo(page.round());
                  setState(() => _page = null);
                },
                child: Text(l.khatmahMark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final k = context.watch<KhatmahCubit>().state;
    return AppCard(
      child: Column(
        children: [
          Icon(Icons.celebration_rounded, color: Palette.green, size: 48),
          const SizedBox(height: 12),
          Text(
            l.khatmahDone,
            textAlign: TextAlign.center,
            style: Fonts.body(16, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            l.khatmahCompleted(context.n(k.completed)),
            style: Fonts.body(13.5, color: Palette.inkSoft),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: context.read<KhatmahCubit>().stop,
            child: Text(l.khatmahNew),
          ),
        ],
      ),
    );
  }
}

/// Compact khatmah status for the Quran screen.
class KhatmahCard extends StatelessWidget {
  const KhatmahCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final k = context.watch<KhatmahCubit>().state;
    final now = context.watch<ClockCubit>().state;
    final String subtitle;
    if (!k.active) {
      subtitle = l.khatmahSub;
    } else if (k.done) {
      subtitle = l.khatmahDone;
    } else {
      subtitle =
          '${l.khatmahToday}: ${l.khatmahTodayGoal(context.n(k.readOn(now)), context.n(k.todayTarget(now)))}';
    }
    return AppCard(
      onTap: () => Navigator.of(context).push(KhatmahScreen.route()),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 40,
            child: k.active
                ? CircularProgressIndicator(
                    value: k.progress,
                    strokeWidth: 4,
                    color: Palette.green,
                    backgroundColor: Palette.green.withValues(alpha: .12),
                  )
                : Icon(Icons.flag_outlined, color: Palette.green, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k.active
                      ? '${l.khatmah} · ${context.n((k.progress * 100).floor())}%'
                      : l.khatmah,
                  style: Fonts.body(15, weight: FontWeight.w600),
                ),
                Text(subtitle, style: Fonts.body(12.5, color: Palette.inkSoft)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
        ],
      ),
    );
  }
}
