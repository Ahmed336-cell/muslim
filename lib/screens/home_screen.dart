import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/duas/dua_of_day_cubit.dart';
import '../bloc/friday_cubit.dart';
import '../bloc/fasting/fasting_bloc.dart';
import '../bloc/names/names_bloc.dart';
import '../bloc/prayer_log_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/tab_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/islamic_api.dart';
import '../theme.dart';
import '../widgets/city_picker.dart';
import 'friday_screen.dart';
import 'ramadan_screen.dart';
import 'tracker_screen.dart';
import '../widgets/azkar_card.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';
import '../widgets/daily_cards.dart';
import '../widgets/dua_of_the_day.dart';
import '../widgets/features.dart';
import '../widgets/name_of_the_day.dart';
import '../widgets/star_pattern.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(BuildContext context) {
    final lang = context.read<SettingsCubit>().state.language;
    context.read<FastingBloc>().add(const FastingRequested());
    context.read<NamesBloc>().add(NamesRequested(lang));
    context.read<DuaOfDayCubit>().load(day: DateTime.now(), language: lang);
    final bloc = context.read<PrayerTimesBloc>()
      ..add(const PrayerTimesRefreshed());
    return bloc.stream.firstWhere((s) => !s.isBusy);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return BlocListener<PrayerTimesBloc, PrayerTimesState>(
      listenWhen: (a, b) =>
          b.status == PrayerTimesStatus.failure && b.day != null,
      listener: (context, state) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.refreshFailed))),
      child: RefreshIndicator(
        color: Palette.green,
        backgroundColor: Palette.card,
        edgeOffset: MediaQuery.paddingOf(context).top,
        onRefresh: () => _refresh(context),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _Header(),
            const SizedBox(height: 20),
            SectionHeader(
              l.todayPrayers,
              action: l.seeAll,
              onAction: () => context.read<TabCubit>().select(AppTab.prayer),
            ),
            const _TodayStrip(),
            const SizedBox(height: 12),
            const AzkarNowCard(),
            const _Occasion(),
            const SizedBox(height: 24),
            const FeatureGrid(),
            const SizedBox(height: 24),
            const NameOfTheDay(),
            const DuaOfTheDay(),
            const DailyAyahCard(),
            const SizedBox(height: 16),
            const HadithCard(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final now = context.watch<ClockCubit>().state;
    final state = context.watch<PrayerTimesBloc>().state;
    final day = state.day;
    final top = MediaQuery.paddingOf(context).top;
    final soft = Palette.cream.withValues(alpha: .72);

    final dateLine = [
      context.date(now, 'EEEE d MMMM'),
      if (day != null && context.hijri(day).isNotEmpty) context.hijri(day),
    ].join('  ·  ');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        color: Palette.green,
        child: Stack(
          children: [
            const Positioned.fill(
              child: StarPattern(color: Color(0x14F4EFE6), cell: 52),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, top + 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.greeting,
                              style: Fonts.display(22, color: Palette.cream),
                            ),
                            const SizedBox(height: 4),
                            Text(dateLine, style: Fonts.body(13, color: soft)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CityChip(color: Palette.cream),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      color: Palette.cream.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Palette.cream.withValues(alpha: .14),
                      ),
                    ),
                    child: day != null
                        ? _NextPrayer(day: day, now: now)
                        : SizedBox(
                            height: 112,
                            child: state.status == PrayerTimesStatus.failure
                                ? Center(
                                    child: _HeaderError(error: state.error),
                                  )
                                : const Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: CardSkeleton(
                                      lines: 1,
                                      tone: ShimmerTone.dark,
                                    ),
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPrayer extends StatelessWidget {
  const _NextPrayer({required this.day, required this.now});

  final PrayerDay day;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cityNow = day.cityNow(now);
    final (:next, :at, :since) = upcoming(day.prayers, cityNow);
    final total = at.difference(since).inSeconds;
    final done = cityNow.difference(since).inSeconds;
    final progress = total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Caption(l.nextPrayer, color: Palette.brass),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                context.prayerName(next.name, day: at),
                style: Fonts.display(42, color: Palette.cream),
              ),
            ),
            Text(
              context.clock(next),
              style: Fonts.mono(26, color: Palette.cream),
            ),
            const SizedBox(width: 4),
            Text(
              context.period(next),
              style: Fonts.body(
                13,
                color: Palette.cream.withValues(alpha: .65),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Palette.cream.withValues(alpha: .14),
            valueColor: AlwaysStoppedAnimation(Palette.brass),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.hourglass_bottom_rounded,
              size: 16,
              color: Palette.cream,
            ),
            const SizedBox(width: 6),
            Text(
              l.inDuration(context.duration(at.difference(cityNow))),
              style: Fonts.body(14, color: Palette.cream),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderError extends StatelessWidget {
  const _HeaderError({required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.error(error),
          textAlign: TextAlign.center,
          style: Fonts.body(13, color: Palette.cream.withValues(alpha: .8)),
        ),
        TextButton(
          onPressed: () =>
              context.read<PrayerTimesBloc>().add(const PrayerTimesRequested()),
          child: Text(
            context.l.retry,
            style: Fonts.body(
              14,
              color: Palette.brass,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Five obligatory prayers in one row, each tappable to mark as prayed.
class _TodayStrip extends StatelessWidget {
  const _TodayStrip();

  @override
  Widget build(BuildContext context) {
    final day = context.select((PrayerTimesBloc b) => b.state.day);
    final prayed = context.watch<PrayerLogCubit>().today;
    final now = context.watch<ClockCubit>().state;
    if (day == null) return const SizedBox(height: 92);

    final cityNow = day.cityNow(now);
    final prayers = day.prayers.where((p) => p.isObligatory).toList();
    final next = upcoming(day.prayers, cityNow).next;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
      child: Column(
        children: [
          Row(
            children: [
              for (final p in prayers)
                Expanded(
                  child: _PrayerCell(
                    prayer: p,
                    name: context.prayerName(p.name, day: cityNow),
                    isNext: p == next,
                    prayed: prayed.contains(p.name),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).push(TrackerScreen.route()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prayed.length == prayers.length
                        ? context.l.allPrayed
                        : context.l.prayedCount(context.n(prayed.length)),
                    style: Fonts.body(12, color: Palette.inkSoft),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.insights_rounded, size: 15, color: Palette.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCell extends StatelessWidget {
  const _PrayerCell({
    required this.prayer,
    required this.name,
    required this.isNext,
    required this.prayed,
  });

  final Prayer prayer;
  final String name;
  final bool isNext;
  final bool prayed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.read<PrayerLogCubit>().toggle(prayer.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isNext ? Palette.greenSoft : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Fonts.body(
                12.5,
                color: isNext ? Palette.green : Palette.inkSoft,
                weight: isNext ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Text(context.clock(prayer), style: Fonts.mono(15)),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: prayed ? Palette.green : null,
                border: Border.all(
                  color: prayed ? Palette.green : Palette.rule,
                  width: 1.5,
                ),
              ),
              child: prayed
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Palette.cream,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ramadan countdown, or a Friday reminder on Jumu'ah.
class _Occasion extends StatelessWidget {
  const _Occasion();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final now = context.watch<ClockCubit>().state;
    final day = context.select((PrayerTimesBloc b) => b.state.day);
    if (day != null && day.hijriMonth == 9) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: RamadanCard(),
      );
    }
    if (!isJumuahMood(now, day: day)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppCard(
        onTap: () => Navigator.of(context).push(FridayScreen.route()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Palette.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mosque_outlined, color: Palette.green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.jumuahMubarak,
                    style: Fonts.body(15, weight: FontWeight.w600),
                  ),
                  Text(
                    l.fridayHomeSub,
                    style: Fonts.body(12.5, color: Palette.inkSoft),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
          ],
        ),
      ),
    );
  }
}
