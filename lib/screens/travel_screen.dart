import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/tab_cubit.dart';
import '../bloc/travel_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Rak'ahs of each fard prayer for a traveller.
const _rakahs = {
  'Fajr': (2, 2),
  'Dhuhr': (4, 2),
  'Asr': (4, 2),
  'Maghrib': (3, 3),
  'Isha': (4, 2),
};

/// Shortening and combining prayers, and duas for the road.
class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const TravelScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = context.watch<TravelCubit>().state;
    final day = context.select((PrayerTimesBloc b) => b.state.day);
    return Scaffold(
      appBar: AppBar(title: Text(l.featTravel)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          const _Status(),
          if (t.travelling && day != null) ...[
            const SizedBox(height: 20),
            SectionHeader(l.travelToday),
            _Prayers(prayers: day.prayers),
            const SizedBox(height: 12),
            _Combine(prayers: day.prayers),
          ],
          const SizedBox(height: 20),
          SectionHeader(l.travelRules),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final rule in [
                  l.travelRuleDistance,
                  l.travelRuleQasr,
                  l.travelRuleJam,
                  l.travelRuleStay,
                  l.travelRuleSunnah,
                  l.travelRuleImam,
                  l.travelRuleFast,
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Icon(
                            Icons.circle,
                            size: 6,
                            color: Palette.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(rule, style: Fonts.body(13.5))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(l.travelDuas),
          for (final (title, arabic, meaning) in [
            (l.travelDuaSetOff, _safarDua, l.travelDuaSetOffMeaning),
            (l.travelDuaTown, _townDua, l.travelDuaTownMeaning),
            (l.travelDuaStop, _stopDua, l.travelDuaStopMeaning),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Caption(title),
                    const SizedBox(height: 8),
                    Text(
                      arabic,
                      textDirection: TextDirection.rtl,
                      style: Fonts.arabic(19),
                    ),
                    if (!context.isAr) ...[
                      const SizedBox(height: 8),
                      Text(
                        meaning,
                        style: Fonts.body(13.5, color: Palette.inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
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

class _Status extends StatelessWidget {
  const _Status();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = context.watch<TravelCubit>().state;
    final now = context.watch<ClockCubit>().state;
    final cubit = context.read<TravelCubit>();
    final km = t.kmFromHome;
    final tripDay = t.travelling ? t.dayOf(now) : null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                t.travelling
                    ? Icons.flight_takeoff_rounded
                    : Icons.home_rounded,
                color: Palette.green,
                size: 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.travelling ? l.travelOn : l.travelOff,
                      style: Fonts.body(17, weight: FontWeight.w600),
                    ),
                    if (km != null)
                      Text(
                        l.travelFromHome(context.n(km.round())),
                        style: Fonts.body(13, color: Palette.inkSoft),
                      ),
                    if (tripDay != null)
                      Text(
                        l.travelDay(context.n(tripDay)),
                        style: Fonts.body(
                          13,
                          color: tripDay > 4 ? Palette.clay : Palette.green,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<bool?>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: null, label: Text(l.travelAuto)),
              ButtonSegment(value: true, label: Text(l.travelModeOn)),
              ButtonSegment(value: false, label: Text(l.travelModeOff)),
            ],
            selected: {t.manual},
            onSelectionChanged: (s) => cubit.setManual(s.first),
          ),
          const SizedBox(height: 6),
          Text(l.travelAutoHint, style: Fonts.body(12, color: Palette.inkSoft)),
          Row(
            children: [
              if (t.here != null && t.here != t.home)
                TextButton.icon(
                  onPressed: cubit.setHomeHere,
                  icon: const Icon(Icons.home_outlined, size: 18),
                  label: Text(l.travelSetHome),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  context.read<TabCubit>().select(AppTab.qibla);
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                icon: const Icon(Icons.explore_outlined, size: 18),
                label: Text(l.featQibla),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Prayers extends StatelessWidget {
  const _Prayers({required this.prayers});

  final List<Prayer> prayers;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          for (final p in prayers)
            if (_rakahs[p.name] case (final full, final short))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.prayerName(p.name),
                        style: Fonts.body(15, weight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${context.clock(p)} ${context.period(p)}',
                      style: Fonts.body(13.5, color: Palette.inkSoft),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 92,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (full != short)
                              TextSpan(
                                text: '${context.n(full)} ',
                                style: Fonts.body(13, color: Palette.inkSoft)
                                    .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                            TextSpan(
                              text: l.travelRakahs(context.n(short)),
                              style: Fonts.body(
                                14,
                                weight: FontWeight.w600,
                                color: full != short
                                    ? Palette.green
                                    : Palette.ink,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.end,
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

class _Combine extends StatelessWidget {
  const _Combine({required this.prayers});

  final List<Prayer> prayers;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    Prayer? find(String name) =>
        prayers.where((p) => p.name == name).firstOrNull;
    String at(String name) => switch (find(name)) {
      final p? => '${context.clock(p)} ${context.period(p)}',
      null => '—',
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.travelCombine, style: Fonts.body(15, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(
            l.travelCombineDay(
              context.prayerName('Dhuhr'),
              context.prayerName('Asr'),
              at('Dhuhr'),
              at('Maghrib'),
            ),
            style: Fonts.body(13.5),
          ),
          const SizedBox(height: 6),
          Text(
            l.travelCombineNight(
              context.prayerName('Maghrib'),
              context.prayerName('Isha'),
              at('Maghrib'),
              at('Fajr'),
            ),
            style: Fonts.body(13.5),
          ),
          const SizedBox(height: 8),
          Text(
            l.travelCombineHint,
            style: Fonts.body(12, color: Palette.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// A banner on the prayer tab when the user seems to be away from home.
class TravelBanner extends StatelessWidget {
  const TravelBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TravelCubit>().state;
    if (!t.away || t.manual != null || t.dismissed) {
      return const SizedBox.shrink();
    }
    final l = context.l;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => Navigator.push(context, TravelScreen.route()),
        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
        child: Row(
          children: [
            Icon(Icons.flight_takeoff_rounded, color: Palette.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.travelBanner(context.n(t.kmFromHome?.round() ?? 0)),
                style: Fonts.body(13.5),
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: context.read<TravelCubit>().dismiss,
              icon: Icon(Icons.close_rounded, color: Palette.inkSoft, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

const _safarDua =
    'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، سُبْحَانَ الَّذِي سَخَّرَ '
    'لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ، '
    'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ '
    'الْعَمَلِ مَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا '
    'بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ، وَالْخَلِيفَةُ فِي الْأَهْلِ';

const _townDua =
    'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ، وَرَبَّ الْأَرَضِينَ '
    'السَّبْعِ وَمَا أَقْلَلْنَ، أَسْأَلُكَ خَيْرَ هَذِهِ الْقَرْيَةِ وَخَيْرَ أَهْلِهَا، '
    'وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ أَهْلِهَا';

const _stopDua =
    'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ';
