import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/duas/dua_of_day_cubit.dart';
import '../bloc/friday_cubit.dart';
import '../bloc/fasting/fasting_bloc.dart';
import '../bloc/names/names_bloc.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import 'friday_screen.dart';
import 'ramadan_screen.dart';
import '../widgets/azkar_card.dart';
import '../widgets/common.dart';
import '../widgets/daily_cards.dart';
import '../widgets/dua_of_the_day.dart';
import '../widgets/features.dart';
import '../widgets/home_prayer_hero.dart';
import '../widgets/name_of_the_day.dart';

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
            const HomePrayerHero(),
            const SizedBox(height: 16),
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
