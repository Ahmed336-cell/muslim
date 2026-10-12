import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/extra_reminders_cubit.dart';
import '../bloc/live_activity_cubit.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/quran/quran_prefs_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../services/live_activity.dart';
import '../theme.dart';
import '../widgets/calculation_settings.dart';
import 'credits_screen.dart';
import '../widgets/city_picker.dart';
import '../widgets/azkar_reminder_settings.dart';
import '../widgets/common.dart';
import '../widgets/extra_reminder_tile.dart';
import '../widgets/features.dart';
import '../widgets/home_widget_picker.dart';
import '../widgets/reminder_settings.dart';
import 'mushaf_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(l.moreTitle)),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        children: [
          SectionHeader(l.allFeatures),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final (i, f) in visibleFeatures(context).indexed) ...[
                  if (i > 0) const RowDivider(indent: 76),
                  FeatureRow(feature: f),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(l.settings),
          AppCard(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Label(icon: Icons.translate_rounded, text: l.language),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    for (final e in supportedLanguages.entries)
                      ButtonSegment(value: e.key, label: Text(e.value)),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (s) => cubit.setLanguage(s.first),
                ),
                const SizedBox(height: 20),
                _Label(icon: Icons.contrast_rounded, text: l.appearance),
                const SizedBox(height: 10),
                SegmentedButton<AppTheme>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: AppTheme.system,
                      icon: const Icon(Icons.brightness_auto_outlined),
                      label: Text(l.themeSystem),
                    ),
                    ButtonSegment(
                      value: AppTheme.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(l.themeLight),
                    ),
                    ButtonSegment(
                      value: AppTheme.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(l.themeDark),
                    ),
                  ],
                  selected: {settings.theme},
                  onSelectionChanged: (s) => cubit.setTheme(s.first),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => showCityPicker(context),
                  leading: Icon(
                    settings.usesLocation
                        ? Icons.my_location_rounded
                        : Icons.location_on_outlined,
                    color: Palette.green,
                  ),
                  title: Text(l.city, style: Fonts.body(15)),
                  subtitle: Text(
                    placeName(context, settings),
                    style: Fonts.body(13, color: Palette.inkSoft),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Palette.inkSoft,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                _Label(icon: Icons.wb_sunny_outlined, text: l.asrMethod),
                const SizedBox(height: 10),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: false, label: Text(l.asrStandard)),
                    ButtonSegment(value: true, label: Text(l.asrHanafi)),
                  ],
                  selected: {settings.hanafiAsr},
                  onSelectionChanged: (s) => cubit.setHanafiAsr(s.first),
                ),
                const SizedBox(height: 8),
                Text(l.asrHint, style: Fonts.body(12, color: Palette.inkSoft)),
                const SizedBox(height: 8),
                const Divider(),
                const CalculationTiles(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(l.prayerReminders),
          const AppCard(
            padding: EdgeInsets.fromLTRB(18, 6, 18, 16),
            child: ReminderSettings(),
          ),
          const SizedBox(height: 24),
          SectionHeader(l.azkarReminders),
          const AppCard(
            padding: EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: AzkarReminderSettings(),
          ),
          const SizedBox(height: 24),
          SectionHeader(l.moreReminders),
          const AppCard(
            padding: EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: Column(
              children: [
                ExtraReminderTile(ExtraKind.ayah),
                ExtraReminderTile(ExtraKind.kahf),
                ExtraReminderTile(ExtraKind.fridayHour),
                ExtraReminderTile(ExtraKind.suhoor),
                ExtraRemindersDenied(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(l.widgetsTitle),
          const AppCard(
            padding: EdgeInsets.fromLTRB(18, 4, 18, 4),
            child: HomeWidgetPicker(),
          ),
          if (context.read<LiveActivity>().supported) ...[
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: context.watch<LiveActivityCubit>().state,
                activeThumbColor: Palette.cream,
                activeTrackColor: Palette.green,
                onChanged: context.read<LiveActivityCubit>().set,
                secondary: Icon(
                  Icons.lock_clock_outlined,
                  color: Palette.green,
                ),
                title: Text(l.liveActivity, style: Fonts.body(15)),
                subtitle: Text(
                  l.liveActivitySub,
                  style: Fonts.body(12.5, color: Palette.inkSoft),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => showReadingSettings(context),
                  leading: Icon(Icons.menu_book_rounded, color: Palette.green),
                  title: Text(l.quranReading, style: Fonts.body(15)),
                  subtitle: Text(
                    context.mushafName(
                      context.watch<QuranPrefsCubit>().state.mushaf,
                    ),
                    style: Fonts.body(13, color: Palette.inkSoft),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Palette.inkSoft,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: context.read<OnboardingCubit>().restart,
                  leading: Icon(
                    Icons.auto_awesome_outlined,
                    color: Palette.green,
                  ),
                  title: Text(l.replayTour, style: Fonts.body(15)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(l.about),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.aboutBody,
                  style: Fonts.body(14, color: Palette.inkSoft),
                ),
                const SizedBox(height: 8),
                const Divider(),
                for (final (icon, title, sub, route) in [
                  (
                    Icons.volunteer_activism_outlined,
                    l.credits,
                    l.creditsSub,
                    CreditsScreen.route,
                  ),
                  (
                    Icons.privacy_tip_outlined,
                    l.privacyPolicy,
                    l.privacyPolicySub,
                    PrivacyScreen.route,
                  ),
                ])
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.push(context, route()),
                    leading: Icon(icon, color: Palette.green),
                    title: Text(title, style: Fonts.body(15)),
                    subtitle: Text(
                      sub,
                      style: Fonts.body(13, color: Palette.inkSoft),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: Palette.inkSoft,
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

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Palette.green),
        const SizedBox(width: 14),
        Text(text, style: Fonts.body(15)),
      ],
    );
  }
}
