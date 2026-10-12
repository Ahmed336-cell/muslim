import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'adhan.dart';
import 'hisn.dart';
import 'islamic_api.dart';

class PrayerReminder {
  const PrayerReminder({
    required this.id,
    required this.prayer,
    required this.at,
  });

  final int id;

  /// API key, e.g. 'Fajr'.
  final String prayer;

  /// UTC instant of the adhan.
  final DateTime at;
}

const reminderPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

/// Today's remaining reminders for [prayers]. Times are wall-clock in the
/// city, so they're converted with the city's UTC offset when known.
List<PrayerReminder> remindersFor(
  PrayerDay day,
  Set<String> prayers,
  DateTime now,
) {
  final cityNow = day.cityNow(now);
  return [
    for (final (i, p) in day.prayers.indexed)
      if (prayers.contains(p.name))
        if (_instant(day, cityNow, p.hour, p.minute) case final at
            when at.isAfter(now.toUtc()))
          PrayerReminder(id: i + 1, prayer: p.name, at: at),
  ];
}

DateTime _instant(PrayerDay day, DateTime cityNow, int hour, int minute) {
  final offset = day.utcOffset;
  if (offset == null) {
    return DateTime(
      cityNow.year,
      cityNow.month,
      cityNow.day,
      hour,
      minute,
    ).toUtc();
  }
  return DateTime.utc(
    cityNow.year,
    cityNow.month,
    cityNow.day,
    hour,
    minute,
  ).subtract(offset);
}

class AzkarReminder {
  const AzkarReminder({
    required this.id,
    required this.session,
    required this.at,
  });

  final int id;
  final AzkarSession session;

  /// UTC instant.
  final DateTime at;

  String get payload => 'azkar:${session.name}';
}

/// One reminder per enabled session for each of the next [days] days, at
/// device-local [times] (minutes after midnight). Rescheduled on every app
/// start, so the window keeps rolling forward.
List<AzkarReminder> azkarRemindersFor(
  Map<AzkarSession, int> times,
  DateTime now, {
  int days = 7,
}) {
  final local = now.toLocal();
  return [
    for (var d = 0; d <= days; d++)
      for (final MapEntry(key: session, value: minutes) in times.entries)
        if (DateTime(
              local.year,
              local.month,
              local.day + d,
              minutes ~/ 60,
              minutes % 60,
            )
            case final at when at.isAfter(local))
          AzkarReminder(
            id: azkarIdBase + d * 2 + session.index,
            session: session,
            at: at.toUtc(),
          ),
  ];
}

/// Prayer reminders use ids below this; adhkar reminders from it upwards.
const azkarIdBase = 100;

/// Local notifications at prayer times; replaced by a fake in tests.
class PrayerNotifier {
  PrayerNotifier();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  Future<void>? _ready;
  bool _launchRead = false;

  /// Payloads of notifications tapped while the app is running.
  Stream<String> get taps => _taps.stream;

  Future<void> _init() => _ready ??= () async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload case final p? when p.isNotEmpty) _taps.add(p);
      },
    );
  }();

  /// Payload of the notification that launched the app; null after the
  /// first call so the app opens it only once.
  Future<String?> launchPayload() async {
    if (_launchRead) return null;
    _launchRead = true;
    await _init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false
        ? details?.notificationResponse?.payload
        : null;
  }

  Future<bool> requestPermission() async {
    await _init();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true) ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    return false;
  }

  /// Replaces every pending reminder with [reminders]; [voice] null uses
  /// the system notification sound.
  Future<void> schedule(
    List<PrayerReminder> reminders, {
    required String Function(String prayer) title,
    required String body,
    AdhanVoice? voice,
  }) async {
    await _init();
    await _cancelWhere((id) => id < azkarIdBase);
    if (voice != null) await installIosSound(voice);
    final details = NotificationDetails(
      android: voice == null
          ? const AndroidNotificationDetails(
              'prayer_times',
              'Prayer times',
              channelDescription: 'A reminder when each prayer time begins',
              importance: Importance.high,
              priority: Priority.high,
            )
          : AndroidNotificationDetails(
              voice.channel,
              'Adhan · ${voice.english}',
              channelDescription: 'The adhan when each prayer time begins',
              importance: Importance.max,
              priority: Priority.max,
              sound: RawResourceAndroidNotificationSound(voice.sound),
              category: AndroidNotificationCategory.alarm,
            ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
        sound: voice == null ? null : '${voice.sound}.caf',
      ),
    );
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        scheduledDate: tz.TZDateTime.from(r.at, tz.UTC),
        title: title(r.prayer),
        body: body,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> _cancelWhere(bool Function(int id) test) async {
    for (final p in await _plugin.pendingNotificationRequests()) {
      if (test(p.id)) await _plugin.cancel(id: p.id);
    }
  }

  /// Replaces every pending adhkar reminder with [reminders].
  Future<void> scheduleAzkar(
    List<AzkarReminder> reminders, {
    required String Function(AzkarSession session) title,
    required String body,
  }) async {
    await _init();
    await _cancelWhere((id) => id >= azkarIdBase);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'azkar',
        'Morning & evening adhkar',
        channelDescription: 'A daily reminder to read the adhkar',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(presentSound: true),
    );
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        scheduledDate: tz.TZDateTime.from(r.at, tz.UTC),
        title: title(r.session),
        body: body,
        payload: r.payload,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
