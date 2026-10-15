// Store screenshots. Run on a spare simulator/emulator:
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart -d <device>
//
// PNGs land in store/play/screenshots/raw/{en,ar}/, in the order of the
// captions in store/play/frame.swift.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muslim/bloc/onboarding_cubit.dart';
import 'package:muslim/bloc/settings_cubit.dart';
import 'package:muslim/bloc/tab_cubit.dart';
import 'package:muslim/main.dart';
import 'package:muslim/screens/azkar_screen.dart';
import 'package:muslim/screens/calendar_screen.dart';
import 'package:muslim/screens/credits_screen.dart';
import 'package:muslim/screens/hadith_screen.dart';
import 'package:muslim/screens/hifz_screen.dart';
import 'package:muslim/screens/kids_screen.dart';
import 'package:muslim/screens/mushaf_screen.dart';
import 'package:muslim/services/hisn.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester tester, [int seconds = 3]) async {
    for (var i = 0; i < seconds * 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
  }

  testWidgets('store screenshots', (tester) async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        (await getApplicationSupportDirectory()).path,
      ),
    );
    await HydratedBloc.storage.clear();
    OnboardingCubit().complete();
    SettingsCubit()
      ..setCity('makkah')
      ..setTheme(AppTheme.light)
      ..setLanguage('en');

    var key = const String.fromEnvironment('ISLAMIC_API_KEY');
    if (key.isEmpty) {
      try {
        final env = jsonDecode(
          await rootBundle.loadString('assets/env/env.json'),
        );
        key = (env as Map<String, dynamic>)['ISLAMIC_API_KEY'] as String? ?? '';
      } catch (_) {}
    }
    await tester.pumpWidget(MuslimApp(apiKey: key));
    await wait(tester, 2);

    BuildContext ctx() => tester.element(find.byType(Navigator).first);
    ctx().read<OnboardingCubit>().complete();
    await wait(tester, 6);
    NavigatorState nav() => tester.state<NavigatorState>(find.byType(Navigator).first);

    for (final lang in ['en', 'ar']) {
      ctx().read<SettingsCubit>().setLanguage(lang);
      ctx().read<TabCubit>().select(AppTab.home);
      await wait(tester, 4);

      var n = 0;
      Future<void> shot() async {
        n++;
        await binding.takeScreenshot('$lang/${n.toString().padLeft(2, '0')}');
      }

      Future<void> visit(Route<void> route, [int seconds = 4]) async {
        nav().push(route);
        await wait(tester, seconds);
        await shot();
        nav().pop();
        await wait(tester, 1);
      }

      await shot(); // 1 home
      await visit(MushafScreen.route(2), 6); // 2 mushaf
      await visit(AzkarScreen.route(AzkarSession.morning)); // 3 adhkar
      await visit(HifzScreen.route()); // 4 hifz
      await visit(HadithScreen.route()); // 5 hadith
      await visit(CalendarScreen.route()); // 6 calendar
      await visit(KidsScreen.route()); // 7 kids
      await visit(PrivacyScreen.route()); // 8 privacy
    }
  });
}
