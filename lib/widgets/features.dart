import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/tab_cubit.dart';
import '../l10n/l10n.dart';
import '../screens/azkar_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/duas_screen.dart';
import '../screens/fasting_screen.dart';
import '../screens/friday_screen.dart';
import '../screens/hifz_screen.dart';
import '../screens/hisn_screen.dart';
import '../screens/khatmah_screen.dart';
import '../screens/names_screen.dart';
import '../screens/quran_screen.dart';
import '../screens/ramadan_screen.dart';
import '../screens/reciters_screen.dart';
import '../screens/ruqyah_screen.dart';
import '../screens/tracker_screen.dart';
import '../screens/zakat_screen.dart';
import '../services/hisn.dart';
import '../services/prayer_calc.dart';
import '../theme.dart';

enum Feature {
  prayer(Icons.schedule_rounded),
  tracker(Icons.insights_rounded),
  quran(Icons.menu_book_rounded),
  khatmah(Icons.flag_outlined),
  hifz(Icons.psychology_outlined),
  reciters(Icons.headphones_rounded),
  qibla(Icons.explore_outlined),
  tasbih(Icons.blur_circular_rounded),
  azkar(Icons.wb_twilight_rounded),
  hisn(Icons.fort_outlined),
  duas(Icons.volunteer_activism_outlined),
  names(Icons.auto_awesome_outlined),
  zakat(Icons.savings_outlined),
  ruqyah(Icons.shield_moon_outlined),
  fasting(Icons.nightlight_round),
  ramadan(Icons.mosque_outlined),
  friday(Icons.event_available_rounded),
  calendar(Icons.calendar_month_outlined);

  const Feature(this.icon);

  final IconData icon;

  String title(L10n l) => switch (this) {
    prayer => l.featPrayer,
    quran => l.featQuran,
    reciters => l.featReciters,
    qibla => l.featQibla,
    tasbih => l.featTasbih,
    azkar => l.featAzkar,
    hisn => l.featHisn,
    duas => l.featDuas,
    names => l.featNames,
    zakat => l.featZakat,
    ruqyah => l.featRuqyah,
    fasting => l.featFasting,
    khatmah => l.featKhatmah,
    hifz => l.featHifz,
    calendar => l.featCalendar,
    tracker => l.featTracker,
    ramadan => l.featRamadan,
    friday => l.featFriday,
  };

  String subtitle(L10n l) => switch (this) {
    prayer => l.featPrayerSub,
    quran => l.featQuranSub,
    reciters => l.featRecitersSub,
    qibla => l.featQiblaSub,
    tasbih => l.featTasbihSub,
    azkar => l.featAzkarSub,
    hisn => l.featHisnSub,
    duas => l.featDuasSub,
    names => l.featNamesSub,
    zakat => l.featZakatSub,
    ruqyah => l.featRuqyahSub,
    fasting => l.featFastingSub,
    khatmah => l.featKhatmahSub,
    hifz => l.featHifzSub,
    calendar => l.featCalendarSub,
    tracker => l.featTrackerSub,
    ramadan => l.featRamadanSub,
    friday => l.featFridaySub,
  };

  void open(BuildContext context) {
    final tabs = context.read<TabCubit>();
    Route<void>? route;
    switch (this) {
      case prayer:
        tabs.select(AppTab.prayer);
      case qibla:
        tabs.select(AppTab.qibla);
      case tasbih:
        tabs.select(AppTab.tasbih);
      case azkar:
        route = AzkarScreen.route(AzkarSession.forHour(DateTime.now().hour));
      case hisn:
        route = HisnScreen.route();
      case quran:
        route = QuranScreen.route();
      case reciters:
        route = RecitersScreen.route();
      case duas:
        route = DuasScreen.route();
      case names:
        route = NamesScreen.route();
      case zakat:
        route = ZakatScreen.route();
      case ruqyah:
        route = RuqyahScreen.route();
      case fasting:
        route = FastingScreen.route();
      case khatmah:
        route = KhatmahScreen.route();
      case hifz:
        route = HifzScreen.route();
      case calendar:
        route = CalendarScreen.route();
      case tracker:
        route = TrackerScreen.route();
      case ramadan:
        route = RamadanScreen.route();
      case friday:
        route = FridayScreen.route();
    }
    if (route != null) Navigator.push(context, route);
  }
}

/// Features for today: Ramadan only in Ramadan and Jumu'ah only on
/// Friday, each first while it's on.
List<Feature> visibleFeatures(BuildContext context) {
  final friday = context.select(
    (ClockCubit c) => c.state.weekday == DateTime.friday,
  );
  final month =
      context.select((PrayerTimesBloc b) => b.state.day?.hijriMonth) ?? 0;
  final ramadan = (month > 0 ? month : HijriDate.of(DateTime.now()).month) == 9;
  return [
    if (ramadan) Feature.ramadan,
    if (friday) Feature.friday,
    for (final f in Feature.values)
      if (f != Feature.ramadan && f != Feature.friday) f,
  ];
}

/// 3-column grid of today's features, used on Home.
class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.02,
        children: [
          for (final f in visibleFeatures(context)) _FeatureTile(feature: f),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Palette.rule, width: .7),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => feature.open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Palette.greenSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(feature.icon, color: Palette.green, size: 23),
              ),
              const SizedBox(height: 8),
              Text(
                feature.title(context.l),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Fonts.body(13, weight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width list row, used on the More tab.
class FeatureRow extends StatelessWidget {
  const FeatureRow({super.key, required this.feature});

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return ListTile(
      onTap: () => feature.open(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Palette.greenSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(feature.icon, color: Palette.green, size: 22),
      ),
      title: Text(
        feature.title(l),
        style: Fonts.body(16, weight: FontWeight.w500),
      ),
      subtitle: Text(
        feature.subtitle(l),
        style: Fonts.body(13, color: Palette.inkSoft),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
    );
  }
}
