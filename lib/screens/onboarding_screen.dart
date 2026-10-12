import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/location_cubit.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/quran/quran_prefs_cubit.dart';
import '../bloc/reminders_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../services/location.dart';
import '../services/notifications.dart';
import '../theme.dart';
import '../widgets/city_picker.dart';
import '../widgets/reminder_settings.dart';
import '../widgets/star_pattern.dart';
import 'mushaf_screen.dart';

/// First-run setup: language, location, reminders and mushaf.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final _pages = PageController(
    initialPage: context.read<OnboardingCubit>().state.step,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<OnboardingCubit>();
    final step = context.select((OnboardingCubit c) => c.state.step);
    final last = step == OnboardingCubit.steps - 1;

    return BlocListener<OnboardingCubit, Onboarding>(
      listenWhen: (a, b) => a.step != b.step && !b.done,
      listener: (_, s) => _pages.animateToPage(
        s.step,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 8, 0),
                  child: Row(
                    children: [
                      for (var i = 0; i < OnboardingCubit.steps; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsetsDirectional.only(end: 6),
                          width: i == step ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i <= step ? Palette.green : Palette.rule,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      const Spacer(),
                      SizedBox(
                        height: 48,
                        child: last
                            ? null
                            : TextButton(
                                onPressed: cubit.complete,
                                child: Text(
                                  l.obSkip,
                                  style: Fonts.body(
                                    14,
                                    color: Palette.inkSoft,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      _WelcomeStep(),
                      _LocationStep(),
                      _RemindersStep(),
                      _MushafStep(),
                      _DoneStep(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 24, 16),
                  child: Row(
                    children: [
                      if (step > 0)
                        TextButton.icon(
                          onPressed: () => cubit.goTo(step - 1),
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                          label: Text(l.obBack),
                          style: TextButton.styleFrom(
                            foregroundColor: Palette.inkSoft,
                            minimumSize: const Size(0, 52),
                          ),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: last
                            ? cubit.complete
                            : () => cubit.goTo(step + 1),
                        style: FilledButton.styleFrom(
                          backgroundColor: Palette.green,
                          minimumSize: const Size(150, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          last ? l.obStart : l.obNext,
                          style: Fonts.body(
                            16,
                            color: Palette.paper,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon, title and explanation shared by every step.
class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.icon,
    required this.title,
    required this.body,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox.square(
              dimension: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const StarMark(size: 64, color: Palette.greenSoft),
                  Icon(icon, size: 28, color: Palette.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(title, style: Fonts.display(30)),
          const SizedBox(height: 8),
          Text(body, style: Fonts.body(15, color: Palette.inkSoft)),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final settings = context.read<SettingsCubit>();
    final lang = context.select((SettingsCubit c) => c.state.language);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Palette.ink,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: StarPattern(color: Color(0x26B0812F), cell: 44),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'السَّلَامُ عَلَيْكُمْ',
                        textDirection: TextDirection.rtl,
                        style: Fonts.arabic(40, color: Palette.brass),
                      ),
                      Text(
                        l.appName,
                        style: Fonts.display(20, color: Palette.paper),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(l.obWelcomeTitle, style: Fonts.display(30)),
          const SizedBox(height: 8),
          Text(l.obWelcomeBody, style: Fonts.body(15, color: Palette.inkSoft)),
          const SizedBox(height: 28),
          Text(
            l.obChooseLanguage,
            style: Fonts.body(14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (final e in supportedLanguages.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChoiceCard(
                selected: lang == e.key,
                onTap: () => settings.setLanguage(e.key),
                child: Text(
                  e.value,
                  style: e.key == 'ar'
                      ? Fonts.arabic(20).copyWith(height: 1.4)
                      : Fonts.body(17, weight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final settings = context.watch<SettingsCubit>().state;
    final locate = context.watch<LocationCubit>().state;
    final settingsCubit = context.read<SettingsCubit>();

    final error = switch (locate.error) {
      null => null,
      LocationException.disabled => l.locDisabled,
      LocationException.denied => l.locDenied,
      LocationException.blocked => l.locBlocked,
      _ => l.locFailed,
    };

    return _StepLayout(
      icon: Icons.my_location_rounded,
      title: l.obLocationTitle,
      body: l.obLocationBody,
      children: [
        FilledButton.icon(
          onPressed: locate.locating
              ? null
              : () => context.read<LocationCubit>().locate(),
          style: FilledButton.styleFrom(
            backgroundColor: Palette.green,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: locate.locating
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Palette.paper,
                  ),
                )
              : const Icon(Icons.near_me_rounded),
          label: Text(
            locate.locating ? l.locating : l.useMyLocation,
            style: Fonts.body(
              16,
              color: Palette.paper,
              weight: FontWeight.w600,
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error, style: Fonts.body(13, color: Palette.clay)),
          if (locate.error == LocationException.blocked ||
              locate.error == LocationException.disabled)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: context.read<LocationCubit>().openSettings,
                child: Text(l.openSettings),
              ),
            ),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => showCityPicker(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Palette.green,
            side: const BorderSide(color: Palette.rule),
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.location_city_rounded),
          label: Text(l.obChooseCity, style: Fonts.body(15)),
        ),
        const SizedBox(height: 16),
        _ChoiceCard(
          selected: true,
          onTap: () => showCityPicker(context),
          child: Row(
            children: [
              Icon(
                settings.usesLocation
                    ? Icons.my_location_rounded
                    : Icons.location_on_rounded,
                color: Palette.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeName(context, settings),
                      style: Fonts.body(16, weight: FontWeight.w600),
                    ),
                    if (settings.usesLocation)
                      Text(
                        l.nearCity(settings.city.name(context.isAr)),
                        style: Fonts.body(12.5, color: Palette.inkSoft),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(l.asrMethod, style: Fonts.body(14, weight: FontWeight.w600)),
        const SizedBox(height: 10),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: false, label: Text(l.asrStandard)),
            ButtonSegment(value: true, label: Text(l.asrHanafi)),
          ],
          selected: {settings.hanafiAsr},
          onSelectionChanged: (s) => settingsCubit.setHanafiAsr(s.first),
        ),
        const SizedBox(height: 8),
        Text(l.asrHint, style: Fonts.body(12, color: Palette.inkSoft)),
      ],
    );
  }
}

class _RemindersStep extends StatelessWidget {
  const _RemindersStep();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final r = context.watch<RemindersCubit>().state;

    return _StepLayout(
      icon: Icons.notifications_active_outlined,
      title: l.obNotifyTitle,
      body: l.obNotifyBody,
      children: [
        // A preview of what a reminder looks like.
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Palette.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Palette.rule, width: .7),
            boxShadow: [
              BoxShadow(
                color: Palette.ink.withValues(alpha: .06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Palette.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Palette.paper,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.reminderTitle(l.maghrib),
                      style: Fonts.body(14.5, weight: FontWeight.w600),
                    ),
                    Text(
                      l.reminderBody,
                      style: Fonts.body(13, color: Palette.inkSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!r.enabled)
          FilledButton.icon(
            onPressed: context.read<RemindersCubit>().enable,
            style: FilledButton.styleFrom(
              backgroundColor: Palette.green,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.notifications_rounded),
            label: Text(
              l.obAllowNotifications,
              style: Fonts.body(
                16,
                color: Palette.paper,
                weight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 8),
        const ReminderSettings(),
      ],
    );
  }
}

class _MushafStep extends StatelessWidget {
  const _MushafStep();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return _StepLayout(
      icon: Icons.menu_book_rounded,
      title: l.obMushafTitle,
      body: l.obMushafBody,
      children: const [ReadingSettingsPanel(showTitle: false)],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final onboarding = context.read<OnboardingCubit>();
    final settings = context.watch<SettingsCubit>().state;
    final reminders = context.watch<RemindersCubit>().state;
    final prefs = context.watch<QuranPrefsCubit>().state;

    Widget row(IconData icon, String label, String value, int step) => ListTile(
      onTap: () => onboarding.goTo(step),
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Palette.green),
      title: Text(label, style: Fonts.body(13, color: Palette.inkSoft)),
      subtitle: Text(value, style: Fonts.body(15.5, weight: FontWeight.w600)),
      trailing: const Icon(
        Icons.edit_outlined,
        size: 18,
        color: Palette.inkSoft,
      ),
    );

    return _StepLayout(
      icon: Icons.check_rounded,
      title: l.obDoneTitle,
      body: l.obDoneBody,
      children: [
        row(
          Icons.translate_rounded,
          l.language,
          supportedLanguages[settings.language]!,
          0,
        ),
        row(
          settings.usesLocation
              ? Icons.my_location_rounded
              : Icons.location_on_outlined,
          l.city,
          placeName(context, settings),
          1,
        ),
        row(
          Icons.notifications_none_rounded,
          l.prayerReminders,
          reminders.enabled
              ? l.remindersCount(
                  context.n(reminders.prayers.length),
                  context.n(reminderPrayers.length),
                )
              : l.remindersOff,
          2,
        ),
        row(
          Icons.menu_book_rounded,
          l.mushafType,
          '${context.mushafName(prefs.mushaf)} · '
          '${context.n(prefs.fontSize.round())}',
          3,
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Palette.greenSoft : Palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? Palette.green : Palette.rule,
          width: selected ? 1.2 : .7,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(child: child),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: Palette.green),
            ],
          ),
        ),
      ),
    );
  }
}
