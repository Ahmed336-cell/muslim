// Marketing shots for 1.0.0+5 and +6. Does not touch the published set.
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/updates_test.dart -d <device>
//
// PNGs land in store/play/screenshots/raw/updates/{en,ar}/.
// Frame with: swiftc -parse-as-library store/play/frame_updates.swift -o /tmp/frame_updates && /tmp/frame_updates
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
import 'package:muslim/l10n/l10n.dart';
import 'package:muslim/main.dart';
import 'package:muslim/screens/radio_screen.dart';
import 'package:muslim/screens/tawashih_screen.dart';
import 'package:muslim/widgets/share_card.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester tester, [int seconds = 3]) async {
    for (var i = 0; i < seconds * 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
  }

  testWidgets('update screenshots', (tester) async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        (await getApplicationSupportDirectory()).path,
      ),
    );
    await HydratedBloc.storage.clear();

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
    ctx().read<SettingsCubit>()
      ..setTheme(AppTheme.dark)
      ..setCity('cairo')
      ..setLanguage('ar');
    await wait(tester, 6);

    NavigatorState nav() =>
        tester.state<NavigatorState>(find.byType(Navigator).first);

    for (final lang in ['ar', 'en']) {
      ctx().read<SettingsCubit>().setLanguage(lang);
      await wait(tester, 2);
      ctx().read<TabCubit>().select(AppTab.home);
      nav().popUntil((r) => r.isFirst);
      await wait(tester, 3);

      var n = 0;
      Future<void> shot() async {
        n++;
        await binding.takeScreenshot(
          'updates/$lang/${n.toString().padLeft(2, '0')}',
        );
      }

      await shot(); // 1 sky + explore

      ctx().read<TabCubit>().select(AppTab.qibla);
      await wait(tester, 3);
      await shot(); // 2 qibla

      ctx().read<TabCubit>().select(AppTab.tasbih);
      await wait(tester, 2);
      await shot(); // 3 sebha

      ctx().read<TabCubit>().select(AppTab.home);
      await wait(tester, 1);
      nav().push(TawashihScreen.route());
      await wait(tester, 4);
      await shot(); // 4 tawashih
      nav().pop();
      await wait(tester, 1);

      nav().push(RadioScreen.route());
      await wait(tester, 2);
      await shot(); // 5 radio
      nav().pop();
      await wait(tester, 1);

      final l = ctx().l;
      final ar = lang == 'ar';
      showShareCard(
        ctx(),
        sheetTitle: l.shareHadith,
        eyebrow: l.featHadith,
        arabic: 'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى.',
        meaning: ar
            ? null
            : 'Actions are but by intentions, and each person will have only what they intended.',
        citation: ar ? 'البخاري ومسلم' : 'Bukhari & Muslim',
      );
      await wait(tester, 2);
      await shot(); // 6 share card
      nav().pop();
      await wait(tester, 1);
    }
  });
}
