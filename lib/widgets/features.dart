import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/friday_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/tab_cubit.dart';
import '../l10n/l10n.dart';
import '../screens/azkar_screen.dart';
import '../screens/books_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/duas_screen.dart';
import '../screens/fasting_screen.dart';
import '../screens/friday_screen.dart';
import '../screens/hifz_screen.dart';
import '../screens/hadith_screen.dart';
import '../screens/hisn_screen.dart';
import '../screens/khatmah_screen.dart';
import '../screens/kids_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/names_screen.dart';
import '../screens/qada_screen.dart';
import '../screens/identify_reciter_screen.dart';
import '../screens/quran_screen.dart';
import '../screens/radio_screen.dart';
import '../screens/ramadan_screen.dart';
import '../screens/reciters_screen.dart';
import '../screens/ruqyah_screen.dart';
import '../screens/sadaqah_screen.dart';
import '../screens/sleep_screen.dart';
import '../screens/tawashih_screen.dart';
import '../screens/tracker_screen.dart';
import '../screens/travel_screen.dart';
import '../screens/zakat_screen.dart';
import '../services/hajj_lessons.dart';
import '../services/lessons.dart';
import '../services/tajweed_lessons.dart';
import '../services/prayer_calc.dart';
import '../bloc/feature_news_cubit.dart';
import '../theme.dart';
import 'azkar_card.dart';
import 'common.dart';
import 'feature_art.dart';

enum Feature {
  prayer(Icons.schedule_rounded),
  tracker(Icons.insights_rounded),
  quran(Icons.menu_book_rounded, artAsset: 'assets/features/quran_rehal.png'),
  identify(Icons.graphic_eq_rounded),
  khatmah(Icons.flag_rounded),
  hifz(Icons.psychology_rounded),
  tajweed(Icons.record_voice_over_rounded),
  reciters(Icons.headphones_rounded),
  tawashih(Icons.music_note_rounded, highlight: 'tawashih-2026-10'),
  radio(Icons.radio_rounded, highlight: 'radio-2026-10'),
  qibla(Icons.explore_rounded),
  travel(Icons.flight_takeoff_rounded),
  tasbih(Icons.blur_circular_rounded),
  azkar(Icons.wb_twilight_rounded),
  hisn(Icons.fort_rounded),
  sleep(Icons.bedtime_rounded),
  hadith(Icons.format_quote_rounded),
  books(Icons.auto_stories_rounded, highlight: 'books-2026-10'),
  duas(Icons.volunteer_activism_rounded),
  learn(Icons.school_rounded),
  hajj(Icons.landscape_rounded),
  kids(Icons.child_care_rounded),
  names(
    Icons.auto_awesome_rounded,
    artAsset: 'assets/features/asma_allah.jpg',
  ),
  zakat(Icons.savings_rounded),
  sadaqah(Icons.favorite_rounded),
  ruqyah(Icons.shield_moon_rounded),
  fasting(Icons.nightlight_round),
  qada(Icons.event_repeat_rounded),
  ramadan(Icons.mosque_rounded),
  friday(Icons.event_available_rounded),
  calendar(Icons.calendar_month_rounded);

  const Feature(this.icon, {this.artAsset, this.highlight});

  final IconData icon;

  /// Optional flat illustration asset (e.g. mushaf on rehal).
  final String? artAsset;

  /// When set, Explore shows a red "New" badge until dismissed.
  final String? highlight;

  String title(L10n l) => switch (this) {
    prayer => l.featPrayer,
    quran => l.featQuran,
    identify => l.featIdentify,
    reciters => l.featReciters,
    tawashih => l.featTawashih,
    radio => l.featRadio,
    qibla => l.featQibla,
    travel => l.featTravel,
    tasbih => l.featTasbih,
    azkar => l.featAzkar,
    hisn => l.featHisn,
    sleep => l.featSleep,
    hadith => l.featHadith,
    books => l.featBooks,
    duas => l.featDuas,
    learn => l.featLearn,
    hajj => l.featHajj,
    kids => l.featKids,
    names => l.featNames,
    zakat => l.featZakat,
    sadaqah => l.featSadaqah,
    ruqyah => l.featRuqyah,
    fasting => l.featFasting,
    qada => l.featQada,
    khatmah => l.featKhatmah,
    hifz => l.featHifz,
    tajweed => l.featTajweed,
    calendar => l.featCalendar,
    tracker => l.featTracker,
    ramadan => l.featRamadan,
    friday => l.featFriday,
  };

  String subtitle(L10n l) => switch (this) {
    prayer => l.featPrayerSub,
    quran => l.featQuranSub,
    identify => l.featIdentifySub,
    reciters => l.featRecitersSub,
    tawashih => l.featTawashihSub,
    radio => l.featRadioSub,
    qibla => l.featQiblaSub,
    travel => l.featTravelSub,
    tasbih => l.featTasbihSub,
    azkar => l.featAzkarSub,
    hisn => l.featHisnSub,
    sleep => l.featSleepSub,
    hadith => l.featHadithSub,
    books => l.featBooksSub,
    duas => l.featDuasSub,
    learn => l.featLearnSub,
    hajj => l.featHajjSub,
    kids => l.featKidsSub,
    names => l.featNamesSub,
    zakat => l.featZakatSub,
    sadaqah => l.featSadaqahSub,
    ruqyah => l.featRuqyahSub,
    fasting => l.featFastingSub,
    qada => l.featQadaSub,
    khatmah => l.featKhatmahSub,
    hifz => l.featHifzSub,
    tajweed => l.featTajweedSub,
    calendar => l.featCalendarSub,
    tracker => l.featTrackerSub,
    ramadan => l.featRamadanSub,
    friday => l.featFridaySub,
  };

  void open(BuildContext context) {
    final l = context.l;
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
        final day = context.read<PrayerTimesBloc>().state.day;
        final now = context.read<ClockCubit>().state;
        route = AzkarScreen.route(azkarTimeOf(day, now).session);
      case hisn:
        route = HisnScreen.route();
      case sleep:
        route = SleepScreen.route();
      case hadith:
        route = HadithScreen.route();
      case books:
        route = BooksScreen.route();
      case travel:
        route = TravelScreen.route();
      case quran:
        route = QuranScreen.route();
      case identify:
        route = IdentifyReciterScreen.route();
      case reciters:
        route = RecitersScreen.route();
      case tawashih:
        route = TawashihScreen.route();
      case radio:
        route = RadioScreen.route();
      case duas:
        route = DuasScreen.route();
      case kids:
        route = KidsScreen.route();
      case learn:
        route = LessonsScreen.route(l.featLearn, const [
          wuduLesson,
          salahLesson,
        ]);
      case hajj:
        route = LessonsScreen.route(l.featHajj, const [
          umrahLesson,
          hajjLesson,
        ]);
      case names:
        route = NamesScreen.route();
      case zakat:
        route = ZakatScreen.route();
      case sadaqah:
        route = SadaqahScreen.route();
      case ruqyah:
        route = RuqyahScreen.route();
      case fasting:
        route = FastingScreen.route();
      case qada:
        route = QadaScreen.route();
      case khatmah:
        route = KhatmahScreen.route();
      case hifz:
        route = HifzScreen.route();
      case tajweed:
        route = LessonsScreen.route(l.featTajweed, tajweedLessons);
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

/// Features for today: Ramadan only in Ramadan and Jumu'ah from Maghrib
/// Thursday to Maghrib Friday, each first while it's on.
List<Feature> visibleFeatures(BuildContext context) {
  final now = context.watch<ClockCubit>().state;
  final day = context.select((PrayerTimesBloc b) => b.state.day);
  final friday = isJumuahMood(now, day: day);
  final month = day?.hijriMonth ?? 0;
  final ramadan = (month > 0 ? month : HijriDate.of(DateTime.now()).month) == 9;
  return [
    if (ramadan) Feature.ramadan,
    if (friday) Feature.friday,
    Feature.identify,
    for (final f in Feature.values)
      if (f != Feature.identify &&
          f != Feature.ramadan &&
          f != Feature.friday &&
          f != Feature.books &&
          (qiblaEnabled || f != Feature.qibla))
        f,
  ];
}

/// 3-column grid of today's features, used on Home.
/// The Explore section on Home: two rows of features, expandable to all.
class FeatureGrid extends StatefulWidget {
  const FeatureGrid({super.key});

  static const columns = 4;
  static const collapsedRows = 2;

  @override
  State<FeatureGrid> createState() => _FeatureGridState();
}

class _FeatureGridState extends State<FeatureGrid> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final all = visibleFeatures(context);
    const collapsed = FeatureGrid.columns * FeatureGrid.collapsedRows;
    final canExpand = all.length > collapsed;
    final shown = _expanded || !canExpand ? all : all.take(collapsed);
    return Column(
      children: [
        SectionHeader(
          l.explore,
          action: canExpand ? (_expanded ? l.showLess : l.seeAll) : null,
          onAction: () => setState(() => _expanded = !_expanded),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: FeatureGrid.columns,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: .9,
              children: [for (final f in shown) _FeatureTile(feature: f)],
            ),
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Palette.rule, width: .7),
      ),
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: () => feature.open(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
          child: Column(
            children: [
              _FeatureGlyph(feature: feature, size: 44),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  feature.title(context.l),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Fonts.body(
                    11.5,
                    weight: FontWeight.w500,
                  ).copyWith(height: 1.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Illustrated icon + optional red "New" pill (whole first day only).
class _FeatureGlyph extends StatelessWidget {
  const _FeatureGlyph({required this.feature, this.size = 44});

  final Feature feature;
  final double size;

  @override
  Widget build(BuildContext context) {
    final news = context.watch<FeatureNewsCubit>();
    final key = feature.highlight;
    final showNew = news.isFresh(key);
    if (key != null && !news.state.containsKey(key)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.read<FeatureNewsCubit>().noteShown(key);
      });
    }
    return SizedBox(
      width: size + 12,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: FeatureArt(feature: feature, size: size),
          ),
          if (showNew)
            Positioned(
              top: -8,
              child: _NewBadge(label: context.l.badgeNew),
            ),
        ],
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: Fonts.body(
          9.5,
          color: Colors.white,
          weight: FontWeight.w700,
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
      leading: _FeatureGlyph(feature: feature, size: 42),
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
