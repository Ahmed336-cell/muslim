import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc/audio_cubit.dart';
import 'bloc/clock_cubit.dart';
import 'bloc/duas/dua_library_bloc.dart';
import 'bloc/duas/dua_of_day_cubit.dart';
import 'bloc/fasting/fasting_bloc.dart';
import 'bloc/names/names_bloc.dart';
import 'bloc/nisab/nisab_bloc.dart';
import 'bloc/prayer_log_cubit.dart';
import 'bloc/prayer_times/prayer_times_bloc.dart';
import 'bloc/quran_bookmark_cubit.dart';
import 'bloc/ruqyah/ruqyah_bloc.dart';
import 'bloc/settings_cubit.dart';
import 'bloc/tab_cubit.dart';
import 'bloc/tasbih_cubit.dart';
import 'bloc/zakat_cubit.dart';
import 'l10n/l10n.dart';
import 'screens/dhikr_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/qibla_screen.dart';
import 'services/islamic_api.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationSupportDirectory()).path,
          ),
  );
  runApp(const MuslimApp());
}

class MuslimApp extends StatelessWidget {
  const MuslimApp({super.key, this.api});

  /// Injected in tests.
  final IslamicApi? api;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => api ?? IslamicApi(),
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
        BlocProvider(create: (_) => TabCubit()),
        BlocProvider(create: (_) => ClockCubit()),
        BlocProvider(
          create: (c) =>
              PrayerTimesBloc(repository: api(c), place: settings.place)
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
              DuaOfDayCubit(api: api(c))
                ..load(day: DateTime.now(), language: lang),
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
        BlocListener<SettingsCubit, Settings>(
          listenWhen: (a, b) => a.language != b.language,
          listener: (context, s) {
            final lang = s.language;
            context.read<AudioCubit>().stop();
            context.read<NamesBloc>().add(NamesRequested(lang));
            context.read<DuaOfDayCubit>().load(
              day: DateTime.now(),
              language: lang,
            );
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
        BlocListener<SettingsCubit, Settings>(
          listenWhen: (a, b) => a.place != b.place,
          listener: (context, s) {
            context.read<PrayerTimesBloc>().add(
              PrayerTimesRequested(place: s.place),
            );
            context.read<FastingBloc>().add(FastingRequested(place: s.place));
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
    Fonts.arabicUi = lang == 'ar';

    return MaterialApp(
      // New key per language so every widget restyles; the tab survives
      // because it lives in TabCubit above.
      key: ValueKey(lang),
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
      home: const Shell(),
    );
  }
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
        value: tab == AppTab.home
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: IndexedStack(index: tab.index, children: _pages),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Palette.rule, width: .7)),
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
        ),
      ),
    );
  }
}
