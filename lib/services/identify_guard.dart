import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Keeps the process alive so the mic and models can finish while the
/// user is in another app. Work still runs on the main isolate.
class IdentifyGuard {
  static var _ready = false;

  static void init() {
    if (_ready || kIsWeb) return;
    _ready = true;
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'identify_reciter',
        channelName: 'Identify reciter',
        channelDescription: 'Listens for a recitation in the background',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Starts the Android microphone foreground service. No-op on iOS/web.
  static Future<void> start({
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    init();
    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: body,
      );
      return;
    }
    final result = await FlutterForegroundTask.startService(
      serviceId: 2601,
      notificationTitle: title,
      notificationText: body,
      callback: identifyGuardCallback,
      serviceTypes: const [ForegroundServiceTypes.microphone],
    );
    if (result is ServiceRequestFailure) {
      debugPrint('identify guard start: ${result.error}');
    }
  }

  static Future<void> update({
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (!await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: body,
    );
  }

  static Future<void> stop() async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

@pragma('vm:entry-point')
void identifyGuardCallback() {
  FlutterForegroundTask.setTaskHandler(_KeepAliveHandler());
}

/// Empty handler — the identify work stays on the UI isolate.
class _KeepAliveHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
