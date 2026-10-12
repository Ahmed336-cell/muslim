import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim/bloc/onboarding_cubit.dart';
import 'package:muslim/bloc/quran/hifz_cubit.dart';
import 'package:muslim/main.dart';
import 'package:muslim/screens/hifz_screen.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/services/recite_engine.dart';

import 'fake_audio.dart';
import 'helpers.dart';

class _OfflineApi extends IslamicApi {
  _OfflineApi() : super(apiKey: 'test');
}

class _FakeRecite extends ReciteEngine {
  final partials = StreamController<String>();
  String last = '';

  @override
  Future<bool> hasModel() async => true;

  @override
  Future<Stream<String>?> start() async => partials.stream;

  @override
  Future<String> finish() async => last;

  @override
  Future<void> cancel() async {}

  @override
  Future<void> release() async {}
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
      'xyz.luan/audioplayers',
      'home_widget/updates',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(channel), (_) async {
        return null;
      });
    }
  });

  testWidgets('recite live reveal + feedback with semantics on', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    // Real async (asset loading) also lets audio plugins reach their
    // missing platform channels.
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is! MissingPluginException) onError?.call(details);
    };
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    useMemoryStorage();
    OnboardingCubit().complete();
    final recite = _FakeRecite();
    await tester.pumpWidget(
      MuslimApp(
        api: _OfflineApi(),
        audio: FakeEngine(),
        ambient: FakeAmbient(),
        audioStore: FakeStore(),
        reciteEngine: recite,
      ),
    );
    await tester.pump();
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(HifzScreen.route());
    await tester.pump(const Duration(milliseconds: 400));
    for (
      var i = 0;
      i < 20 &&
          find.text('سمّع واختبر').evaluate().isEmpty &&
          find.text('Recite & check').evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    tester.element(find.byType(HifzScreen)).read<HifzCubit>()
      ..setRange(2, 7)
      ..setHide(HifzHide.all);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }

    final button = find.byIcon(Icons.mic_none_rounded);
    await tester.ensureVisible(button.first);
    await tester.tap(button.first);
    await tester.pump();
    await tester.pump();

    const words = [
      'الحمد',
      'لله',
      'رب',
      'العالمين',
      'الرحمن',
      'الرحيم',
      'مالك',
      'يوم',
      'الدين',
    ];
    for (var n = 1; n <= words.length; n++) {
      recite.last = words.take(n).join(' ');
      recite.partials.add(recite.last);
      await tester.pump();
      await tester.pump();
    }
    await tester.ensureVisible(find.byIcon(Icons.stop_rounded));
    await tester.tap(find.byIcon(Icons.stop_rounded));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('9 of 9 words matched'), findsOneWidget);
    expect(find.text('Your recitation'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    await tester.ensureVisible(find.text('Done'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Your recitation'), findsNothing);
    FlutterError.onError = onError;
    semantics.dispose();
  });
}
