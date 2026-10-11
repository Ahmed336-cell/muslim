import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tab_cubit.dart';
import '../l10n/l10n.dart';
import '../screens/duas_screen.dart';
import '../screens/fasting_screen.dart';
import '../screens/names_screen.dart';
import '../screens/quran_screen.dart';
import '../screens/ruqyah_screen.dart';
import '../screens/zakat_screen.dart';
import '../theme.dart';

enum Feature {
  prayer(Icons.schedule_rounded),
  quran(Icons.menu_book_rounded),
  qibla(Icons.explore_outlined),
  tasbih(Icons.blur_circular_rounded),
  duas(Icons.volunteer_activism_outlined),
  names(Icons.auto_awesome_outlined),
  zakat(Icons.savings_outlined),
  ruqyah(Icons.shield_moon_outlined),
  fasting(Icons.nightlight_round);

  const Feature(this.icon);

  final IconData icon;

  String title(L10n l) => switch (this) {
    prayer => l.featPrayer,
    quran => l.featQuran,
    qibla => l.featQibla,
    tasbih => l.featTasbih,
    duas => l.featDuas,
    names => l.featNames,
    zakat => l.featZakat,
    ruqyah => l.featRuqyah,
    fasting => l.featFasting,
  };

  String subtitle(L10n l) => switch (this) {
    prayer => l.featPrayerSub,
    quran => l.featQuranSub,
    qibla => l.featQiblaSub,
    tasbih => l.featTasbihSub,
    duas => l.featDuasSub,
    names => l.featNamesSub,
    zakat => l.featZakatSub,
    ruqyah => l.featRuqyahSub,
    fasting => l.featFastingSub,
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
      case quran:
        route = QuranScreen.route();
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
    }
    if (route != null) Navigator.push(context, route);
  }
}

/// 3-column grid of every feature, used on Home.
class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.02,
        children: [for (final f in Feature.values) _FeatureTile(feature: f)],
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
        side: const BorderSide(color: Palette.rule, width: .7),
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
                decoration: const BoxDecoration(
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
        decoration: const BoxDecoration(
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
      trailing: const Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
    );
  }
}
