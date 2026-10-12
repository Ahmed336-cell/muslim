import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc/audio_cubit.dart';
import 'bloc/azkar_cubit.dart';
import 'bloc/azkar_reminders_cubit.dart';
import 'bloc/clock_cubit.dart';
import 'bloc/duas/dua_library_bloc.dart';
import 'bloc/duas/dua_of_day_cubit.dart';
import 'bloc/extra_reminders_cubit.dart';
import 'bloc/fasting/fasting_bloc.dart';
import 'bloc/friday_cubit.dart';
import 'bloc/hadith_saved_cubit.dart';
import 'bloc/qada_cubit.dart';
import 'bloc/sadaqah_cubit.dart';
import 'bloc/travel_cubit.dart';
import 'bloc/hisn_cubit.dart';
import 'bloc/lessons_cubit.dart';
import 'bloc/live_activity_cubit.dart';
import 'bloc/location_cubit.dart';
import 'bloc/names/names_bloc.dart';
import 'bloc/onboarding_cubit.dart';
import 'bloc/nisab/nisab_bloc.dart';
import 'bloc/prayer_log_cubit.dart';
import 'bloc/prayer_times/prayer_times_bloc.dart';
import 'bloc/quran/ambient_cubit.dart';
import 'bloc/quran/downloads_cubit.dart';
import 'bloc/quran/quran_prefs_cubit.dart';
import 'bloc/quran/recent_reciters_cubit.dart';
import 'bloc/quran/hifz_cubit.dart';
import 'bloc/quran/khatmah_cubit.dart';
import 'bloc/quran/recent_surahs_cubit.dart';
import 'bloc/quran/recitation_cubit.dart';
import 'bloc/quran_bookmark_cubit.dart';
import 'bloc/ramadan_cubit.dart';
import 'bloc/reminders_cubit.dart';
import 'bloc/ruqyah/ruqyah_bloc.dart';
import 'bloc/settings_cubit.dart';
import 'bloc/tab_cubit.dart';
import 'bloc/tasbih_cubit.dart';
import 'bloc/zakat_cubit.dart';
import 'l10n/l10n.dart';
import 'screens/azkar_screen.dart';
import 'screens/dhikr_screen.dart';
import 'screens/home_screen.dart';
import 'screens/khatmah_screen.dart';
import 'screens/more_screen.dart';
import 'screens/mushaf_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/sadaqah_screen.dart';
import 'services/ambient.dart';
import 'services/clock.dart';
import 'services/hadith.dart';
import 'services/hisn.dart';
import 'services/home_widgets.dart';
import 'services/islamic_api.dart';
import 'services/live_activity.dart';
import 'services/location.dart';
import 'services/notifications.dart';
import 'services/offline_cache.dart';
import 'services/player.dart';
import 'services/quran.dart';
import 'services/quran_text.dart';
import 'services/recitation.dart';
import 'services/recite_engine.dart';
import 'theme.dart';
import 'widgets/home_widget_sync.dart';
import 'widgets/live_activity_sync.dart';
import 'widgets/mini_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationSupportDirectory()).path,
          ),
  );
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.example.muslim.recitation',
      androidNotificationChannelName: 'Quran recitation',
      androidNotificationOngoing: true,
    );
  } catch (_) {
    // Playback still works in the foreground.
  }
  await usePlaybackSession();
  runApp(MuslimApp(apiKey: await _loadApiKey()));
}

/// `--dart-define` wins; otherwise the bundled assets/env/env.json.
Future<String> _loadApiKey() async {
  const defined = String.fromEnvironment('ISLAMIC_API_KEY');
  if (defined.isNotEmpty) return defined;
  try {
    final json = jsonDecode(await rootBundle.loadString('assets/env/env.json'));
    return (json as Map<String, dynamic>)['ISLAMIC_API_KEY'] as String? ?? '';
  } catch (_) {
    return '';
  }
}

class MuslimApp extends StatelessWidget {
  const MuslimApp({
    super.key,
    this.api,
    this.quranApi,
    this.location,
    this.notifier,
    this.audio,
    this.ambient,
    this.recitersApi,
    this.audioStore,
    this.hisn,
    this.homeWidgets,
    this.reciteEngine,
    this.apiKey,
  });

  /// Injected in tests.
  final IslamicApi? api;
  final QuranApi? quranApi;
  final LocationService? location;
  final PrayerNotifier? notifier;
  final AudioEngine? audio;
  final AmbientEngine? ambient;
  final RecitersApi? recitersApi;
  final AudioStore? audioStore;
  final HisnRepository? hisn;
  final HomeWidgets? homeWidgets;
  final ReciteEngine? reciteEngine;
  final String? apiKey;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Text from every API is kept on disk for offline use.
        RepositoryProvider(create: (_) => OfflineClient()),
        RepositoryProvider(
          create: (c) =>
              api ??
              IslamicApi(client: c.read<OfflineClient>(), apiKey: apiKey),
        ),
        RepositoryProvider(create: (_) => QuranText()),
        RepositoryProvider(
          create: (c) =>
              quranApi ??
              QuranApi(
                client: c.read<OfflineClient>(),
                text: c.read<QuranText>(),
              ),
        ),
        RepositoryProvider(create: (_) => homeWidgets ?? HomeWidgets()),
        RepositoryProvider(create: (_) => const LiveActivity()),
        RepositoryProvider(create: (_) => location ?? const LocationService()),
        RepositoryProvider(create: (_) => notifier ?? PrayerNotifier()),
        RepositoryProvider(
          create: (c) =>
              recitersApi ?? RecitersApi(client: c.read<OfflineClient>()),
        ),
        RepositoryProvider(create: (_) => audioStore ?? AudioStore()),
        RepositoryProvider(create: (_) => hisn ?? HisnRepository()),
        RepositoryProvider(create: (_) => HadithRepository()),
        RepositoryProvider(create: (_) => reciteEngine ?? ReciteEngine()),
        RepositoryProvider<AudioEngine>(
          create: (_) => audio ?? JustAudioEngine(),
        ),
        RepositoryProvider<AmbientEngine>(
          create: (_) => ambient ?? AudioplayersAmbient(),
        ),
      ],
      child: BlocProvider(
        create: (_) => SettingsCubit(
          initialLanguage: PlatformDispatcher.instance.locale.languageCode,
        ),
        child: const _Blocs(),
      ),
    );
  }
}

class _Blocs extends StatelessWidget {
  const _Blocs();

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsCubit>().state;
    final lang = settings.language;
    IslamicApi api(BuildContext c) => c.read<IslamicApi>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OnboardingCubit()),
        BlocProvider(
          create: (c) => RemindersCubit(notifier: c.read<PrayerNotifier>()),
        ),
        BlocProvider(
          lazy: false,
          create: (c) =>
              AzkarRemindersCubit(notifier: c.read<PrayerNotifier>())
                ..sync(lang),
        ),
        BlocProvider(
          lazy: false,
          create: (c) =>
              HisnCubit(repository: c.read<HisnRepository>())..load(),
        ),
        BlocProvider(
          lazy: false,
          create: (c) => ExtraRemindersCubit(
            notifier: c.read<PrayerNotifier>(),
            text: c.read<QuranText>(),
          )..sync(null, lang),
        ),
        BlocProvider(create: (_) => RamadanCubit()),
        BlocProvider(create: (_) => HadithSavedCubit()),
        BlocProvider(create: (_) => SadaqahCubit()),
        BlocProvider(create: (_) => QadaCubit()),
        BlocProvider(create: (_) => LessonsCubit()),
        BlocProvider(
          lazy: false,
          create: (_) {
            final p = settings.place;
            return TravelCubit()..observe(p.lat, p.lon);
          },
        ),
        BlocProvider(create: (_) => LiveActivityCubit()),
        BlocProvider(create: (_) => FridayCubit()),
        BlocProvider(create: (_) => AzkarCubit()),
        BlocProvider(create: (_) => TabCubit()),
        BlocProvider(create: (_) => ClockCubit()),
        BlocProvider(
          lazy: false,
          create: (c) => LocationCubit(
            service: c.read<LocationService>(),
            settings: c.read<SettingsCubit>(),
          )..refresh(),
        ),
        BlocProvider(
          create: (c) =>
              PrayerTimesBloc(place: settings.place)
                ..add(const PrayerTimesRequested()),
        ),
        BlocProvider(
          create: (c) =>
              FastingBloc(repository: api(c), place: settings.place)
                ..add(const FastingRequested()),
        ),
        BlocProvider(create: (_) => PrayerLogCubit()),
        BlocProvider(create: (_) => TasbihCubit()),
        BlocProvider(create: (_) => QuranBookmarkCubit()),
        BlocProvider(
          lazy: false,
          create: (c) {
            final prefs = QuranPrefsCubit();
            c.read<QuranApi>().preload(prefs.state.mushaf);
            return prefs;
          },
        ),
        BlocProvider(create: (_) => RecentSurahsCubit()),
        BlocProvider(create: (_) => KhatmahCubit()),
        BlocProvider(create: (_) => HifzCubit()),
        BlocProvider(
          create: (c) => RecitationCubit(engine: c.read<AudioEngine>()),
        ),
        BlocProvider(
          create: (c) => DownloadsCubit(store: c.read<AudioStore>()),
        ),
        BlocProvider(
          create: (c) => AmbientCubit(engine: c.read<AmbientEngine>()),
        ),
        BlocProvider(create: (_) => RecentRecitersCubit()),
        BlocProvider(
          create: (c) =>
              NisabBloc(api: api(c), currency: settings.city.currency)
                ..add(const NisabRequested()),
        ),
        BlocProvider(create: (_) => ZakatCubit()),
        BlocProvider(
          lazy: false,
          create: (c) =>
              NamesBloc(api: api(c), language: lang)
                ..add(const NamesRequested()),
        ),
        BlocProvider(create: (_) => AudioCubit()),
        BlocProvider(
          create: (c) => DuaLibraryBloc(api: api(c), language: lang),
        ),
        BlocProvider(
          create: (c) => RuqyahBloc(api: api(c), language: lang),
        ),
        BlocProvider(
          lazy: false,
          create: (c) =>
              DuaOfDayCubit(api: api(c))..load(day: appNow(), language: lang),
        ),
      ],
      child: const _SettingsSync(child: _App()),
    );
  }
}

/// Pushes setting changes into the blocs that depend on them.
class _SettingsSync extends StatelessWidget {
  const _SettingsSync({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Clips and recitation never play over each other.
        BlocListener<AudioCubit, String?>(
          listenWhen: (a, b) => b != null,
          listener: (context, _) => context.read<RecitationCubit>().pause(),
        ),
        BlocListener<RecitationCubit, RecitationState>(
          listenWhen: (a, b) => !a.playing && b.playing,
          listener: (context, _) => context.read<AudioCubit>().stop(),
        ),
        BlocListener<QuranPrefsCubit, QuranPrefs>(
          listenWhen: (a, b) => a.mushaf != b.mushaf,
          listener: (context, s) => context.read<QuranApi>().preload(s.mushaf),
        ),
        // Background sounds play and pause with the recitation.
        BlocListener<RecitationCubit, RecitationState>(
          listenWhen: (a, b) => a.playing != b.playing,
          listener: (context, s) =>
              context.read<AmbientCubit>().setLive(s.playing),
        ),
        BlocListener<PrayerTimesBloc, PrayerTimesState>(
          listenWhen: (a, b) => a.day != b.day && b.day != null,
          listener: (context, s) {
            final lang = context.read<SettingsCubit>().state.language;
            context.read<RemindersCubit>().sync(s.day, lang);
            context.read<ExtraRemindersCubit>().sync(s.day, lang);
          },
        ),
        BlocListener<SettingsCubit, Settings>(
          listenWhen: (a, b) => a.language != b.language,
          listener: (context, s) {
            final lang = s.language;
            context.read<RemindersCubit>().sync(null, lang);
            context.read<AzkarRemindersCubit>().sync(lang);
            context.read<ExtraRemindersCubit>().sync(null, lang);
            context.read<AudioCubit>().stop();
            context.read<NamesBloc>().add(NamesRequested(lang));
            context.read<DuaOfDayCubit>().load(day: appNow(), language: lang);
            context.read<RuqyahBloc>().add(RuqyahLanguageChanged(lang));
            final duas = context.read<DuaLibraryBloc>();
            // Only refetch the big library if it was opened before.
            duas.add(
              duas.state.library == null
                  ? DuaLibraryLanguageSet(lang)
                  : DuaLibraryRequested(language: lang),
            );
          },
        ),
        // A new day in the city needs new times and a new Hijri date.
        BlocListener<ClockCubit, DateTime>(
          listenWhen: (a, b) {
            final day = context.read<PrayerTimesBloc>().state.day;
            if (day == null) return false;
            return day.cityNow(a).day != day.cityNow(b).day;
          },
          listener: (context, _) =>
              context.read<PrayerTimesBloc>().add(const PrayerTimesRefreshed()),
        ),
        BlocListener<SettingsCubit, Settings>(
          listenWhen: (a, b) => a.place != b.place,
          listener: (context, s) {
            context.read<PrayerTimesBloc>().add(
              PrayerTimesRequested(place: s.place),
            );
            context.read<FastingBloc>().add(FastingRequested(place: s.place));
            context.read<TravelCubit>().observe(s.place.lat, s.place.lon);
          },
        ),
        BlocListener<SettingsCubit, Settings>(
          listenWhen: (a, b) => a.city.currency != b.city.currency,
          listener: (context, s) => context.read<NisabBloc>().add(
            NisabCurrencyChanged(s.city.currency),
          ),
        ),
      ],
      child: child,
    );
  }
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    final lang = context.select((SettingsCubit c) => c.state.language);
    final theme = context.select((SettingsCubit c) => c.state.theme);
    final dark = switch (theme) {
      AppTheme.dark => true,
      AppTheme.light => false,
      AppTheme.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    Fonts.arabicUi = lang == 'ar';
    Palette.dark = dark;

    return MaterialApp(
      // New key per language and theme so every widget restyles; the tab survives
      // because it lives in TabCubit above.
      key: ValueKey((lang, dark)),
      onGenerateTitle: (context) => context.l.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: Locale(lang),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: context.select((OnboardingCubit c) => c.state.done)
          ? const _NotificationTaps(
              child: HomeWidgetSync(child: LiveActivitySync(child: Shell())),
            )
          : const OnboardingScreen(),
    );
  }
}

/// Opens the screen a tapped notification points at.
class _NotificationTaps extends StatefulWidget {
  const _NotificationTaps({required this.child});

  final Widget child;

  @override
  State<_NotificationTaps> createState() => _NotificationTapsState();
}

class _NotificationTapsState extends State<_NotificationTaps> {
  StreamSubscription<String>? _taps;

  @override
  void initState() {
    super.initState();
    final notifier = context.read<PrayerNotifier>();
    _taps = notifier.taps.listen(_open);
    notifier.launchPayload().then((p) {
      if (p != null) _open(p);
    }, onError: (Object _) {});
  }

  void _open(String payload) {
    if (!mounted) return;
    final Route<void>? quran = switch (payload.split(':')) {
      ['kahf'] => MushafScreen.route(18),
      ['khatmah'] => KhatmahScreen.route(),
      ['sadaqah'] => SadaqahScreen.route(),
      ['ayah', final s, final a] => MushafScreen.route(
        int.tryParse(s) ?? 1,
        ayah: int.tryParse(a) ?? 1,
        highlight: true,
      ),
      _ => null,
    };
    if (quran != null) {
      Navigator.of(context)
        ..popUntil((r) => r.isFirst)
        ..push(quran);
      return;
    }
    final session = AzkarSession.values
        .where((s) => payload == 'azkar:${s.name}')
        .firstOrNull;
    if (session == null) return;
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    nav.push(AzkarScreen.route(session));
  }

  @override
  void dispose() {
    _taps?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  static const _pages = [
    HomeScreen(),
    PrayerScreen(),
    QiblaScreen(),
    DhikrScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = context.watch<TabCubit>().state;
    final l = context.l;

    return PopScope(
      canPop: tab == AppTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.read<TabCubit>().select(AppTab.home);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: tab == AppTab.home || Palette.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: IndexedStack(index: tab.index, children: _pages),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayer(safeArea: false),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Palette.rule, width: .7),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: tab.index,
                  onDestinationSelected: (i) =>
                      context.read<TabCubit>().select(AppTab.values[i]),
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home_rounded),
                      label: l.navHome,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.schedule_outlined),
                      selectedIcon: const Icon(Icons.schedule_rounded),
                      label: l.navPrayer,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.explore_outlined),
                      selectedIcon: const Icon(Icons.explore_rounded),
                      label: l.navQibla,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.blur_circular_outlined),
                      selectedIcon: const Icon(Icons.blur_circular_rounded),
                      label: l.navTasbih,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.grid_view_outlined),
                      selectedIcon: const Icon(Icons.grid_view_rounded),
                      label: l.navMore,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
