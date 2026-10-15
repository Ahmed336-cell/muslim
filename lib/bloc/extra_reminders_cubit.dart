import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../data.dart';
import '../l10n/l10n.dart';
import '../services/daily_content.dart';
import '../services/islamic_api.dart';
import '../services/notifications.dart';
import '../services/prayer_calc.dart';
import '../services/quran.dart';
import '../services/quran_text.dart';

enum ExtraKind {
  ayah(8 * 60),
  kahf(null),
  salawat(11 * 60),
  fridayHour(null),
  suhoor(null),
  wird(21 * 60),
  sadaqah(12 * 60);

  const ExtraKind(this.defaultTime);

  /// Minutes after midnight for kinds the user can time; null otherwise.
  final int? defaultTime;
}

/// Kahf, salawat and the last hour — on by default for new installs.
const _fridayOnByDefault = {
  ExtraKind.kahf,
  ExtraKind.salawat,
  ExtraKind.fridayHour,
};

final class ExtraReminders extends Equatable {
  const ExtraReminders({
    this.on = _fridayOnByDefault,
    this.times = const {},
    this.denied = false,
  });

  final Set<ExtraKind> on;

  /// Chosen times, minutes after midnight, device time.
  final Map<ExtraKind, int> times;

  /// The last permission request was refused.
  final bool denied;

  int timeOf(ExtraKind kind) => times[kind] ?? kind.defaultTime ?? 0;

  int get ayahTime => timeOf(ExtraKind.ayah);

  @override
  List<Object?> get props => [on, times, denied];
}

/// Ayah of the day, daily Quran wird, Friday Kahf / salawat / last-hour
/// dua, sadaqah on Friday and, in Ramadan, suhoor.
class ExtraRemindersCubit extends HydratedCubit<ExtraReminders> {
  ExtraRemindersCubit({
    required this._notifier,
    this._text,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(const ExtraReminders());

  /// Kahf reminder, device time on Friday.
  static const kahfTime = 10 * 60;

  /// Suhoor reminder this long before Fajr.
  static const suhoorLead = Duration(minutes: 45);

  final PrayerNotifier _notifier;
  final QuranText? _text;
  final DateTime Function() _now;
  PrayerDay? _day;
  String _language = 'en';

  Future<void> setEnabled(ExtraKind kind, bool enabled) async {
    if (enabled) {
      bool granted;
      try {
        granted = await _notifier.requestPermission();
      } catch (_) {
        granted = false;
      }
      if (!granted) {
        emit(ExtraReminders(on: state.on, times: state.times, denied: true));
        return;
      }
    }
    emit(
      ExtraReminders(
        on: enabled ? {...state.on, kind} : ({...state.on}..remove(kind)),
        times: state.times,
      ),
    );
    await _reschedule();
  }

  Future<void> setTime(ExtraKind kind, int minutes) async {
    emit(
      ExtraReminders(
        on: state.on,
        times: {...state.times, kind: minutes},
        denied: state.denied,
      ),
    );
    await _reschedule();
  }

  Future<void> sync(PrayerDay? day, String language) async {
    _day = day ?? _day;
    _language = language;
    await _reschedule();
  }

  Future<void> _reschedule() async {
    final reminders = await remindersFor(_now());
    try {
      await _notifier.scheduleExtras(reminders);
    } catch (_) {
      // No plugin (tests, unsupported platform): nothing to schedule on.
    }
  }

  /// Every pending reminder for the coming week.
  Future<List<ExtraReminder>> remindersFor(DateTime now) async {
    final l = lookupL10n(Locale(_language));
    final local = now.toLocal();
    final out = <ExtraReminder>[];
    DateTime at(int d, int minutes) => DateTime(
      local.year,
      local.month,
      local.day + d,
      minutes ~/ 60,
      minutes % 60,
    );

    for (var d = 0; d <= 7; d++) {
      final date = at(d, 0);
      if (state.on.contains(ExtraKind.ayah)) {
        final when = at(d, state.ayahTime);
        if (when.isAfter(local)) {
          final (surah, ayah) = ayahOfDay(date);
          var body = '';
          try {
            final a = await _text?.ayah(surah, ayah, Mushaf.simple);
            if (a != null) body = '${a.text} ';
          } catch (_) {}
          final s = surahs[surah - 1];
          body += _language == 'ar'
              ? '﴿${s.arabic} ${arabicDigits('$ayah')}﴾'
              : '(${s.name} $surah:$ayah)';
          out.add(
            ExtraReminder(
              id: extraIdBase + d,
              at: when.toUtc(),
              title: l.dailyAyahTitle,
              body: body,
              payload: 'ayah:$surah:$ayah',
            ),
          );
        }
      }
      if (state.on.contains(ExtraKind.wird)) {
        final when = at(d, state.timeOf(ExtraKind.wird));
        if (when.isAfter(local)) {
          out.add(
            ExtraReminder(
              id: extraIdBase + 80 + d,
              at: when.toUtc(),
              title: l.wirdReminderTitle,
              body: l.wirdReminderBody,
              payload: 'khatmah',
            ),
          );
        }
      }
      if (state.on.contains(ExtraKind.sadaqah) &&
          date.weekday == DateTime.friday) {
        final when = at(d, state.timeOf(ExtraKind.sadaqah));
        if (when.isAfter(local)) {
          out.add(
            ExtraReminder(
              id: extraIdBase + 100 + d,
              at: when.toUtc(),
              title: l.sadaqahReminderTitle,
              body: l.sadaqahReminderBody,
              payload: 'sadaqah',
            ),
          );
        }
      }
      if (state.on.contains(ExtraKind.kahf) &&
          date.weekday == DateTime.friday) {
        final when = at(d, kahfTime);
        if (when.isAfter(local)) {
          out.add(
            ExtraReminder(
              id: extraIdBase + 20 + d,
              at: when.toUtc(),
              title: l.kahfReminderTitle,
              body: l.kahfReminderBody,
              payload: 'kahf',
            ),
          );
        }
      }
      if (state.on.contains(ExtraKind.salawat) &&
          date.weekday == DateTime.friday) {
        final when = at(d, state.timeOf(ExtraKind.salawat));
        if (when.isAfter(local)) {
          out.add(
            ExtraReminder(
              id: extraIdBase + 120 + d,
              at: when.toUtc(),
              title: l.salawatReminderTitle,
              body: l.salawatReminderBody,
              payload: 'friday',
            ),
          );
        }
      }
    }

    final day = _day;
    if (day == null) return out;
    final cityNow = day.cityNow(now);
    final today = HijriDate(
      day.hijriYear,
      day.hijriMonth,
      day.hijriDay,
    ).toGregorian();
    for (final (d, times) in [day.prayers, ...day.following].indexed) {
      Prayer? find(String name) =>
          times.where((p) => p.name == name).firstOrNull;
      final cityDate = DateTime(cityNow.year, cityNow.month, cityNow.day + d);

      if (state.on.contains(ExtraKind.fridayHour) &&
          cityDate.weekday == DateTime.friday) {
        if (find('Maghrib') case final m?) {
          final when = cityInstant(
            day,
            cityNow,
            d,
            m.hour,
            m.minute,
          ).subtract(const Duration(hours: 1));
          if (when.isAfter(now.toUtc())) {
            out.add(
              ExtraReminder(
                id: extraIdBase + 40 + d,
                at: when,
                title: l.fridayHourTitle,
                body: l.fridayHourBody,
                payload: 'friday',
              ),
            );
          }
        }
      }

      final hijri = HijriDate.of(
        DateTime(today.year, today.month, today.day + d),
      );
      if (state.on.contains(ExtraKind.suhoor) &&
          day.hijriMonth > 0 &&
          hijri.month == 9) {
        if (find('Fajr') case final f?) {
          final when = cityInstant(
            day,
            cityNow,
            d,
            f.hour,
            f.minute,
          ).subtract(suhoorLead);
          if (when.isAfter(now.toUtc())) {
            out.add(
              ExtraReminder(
                id: extraIdBase + 60 + d,
                at: when,
                title: l.suhoorTitle,
                body: l.suhoorBody(
                  _language == 'ar'
                      ? arabicDigits('${suhoorLead.inMinutes}')
                      : '${suhoorLead.inMinutes}',
                ),
              ),
            );
          }
        }
      }
    }
    return out;
  }

  @override
  ExtraReminders? fromJson(Map<String, dynamic> json) => ExtraReminders(
    on: {
      for (final n in json['on'] as List? ?? const [])
        ...ExtraKind.values.where((k) => k.name == n),
    },
    times: {
      for (final k in ExtraKind.values)
        if (json['${k.name}Time'] case final num t) k: t.toInt(),
    },
  );

  @override
  Map<String, dynamic> toJson(ExtraReminders state) => {
    'on': [for (final k in state.on) k.name],
    for (final MapEntry(:key, :value) in state.times.entries)
      '${key.name}Time': value,
  };
}
