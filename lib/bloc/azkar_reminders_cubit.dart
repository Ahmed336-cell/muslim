import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../l10n/app_localizations.dart';
import '../services/hisn.dart';
import '../services/notifications.dart';

final class AzkarReminders extends Equatable {
  const AzkarReminders({
    this.on = const {},
    this.times = defaultTimes,
    this.denied = false,
  });

  /// Minutes after midnight, device time.
  static const defaultTimes = {
    AzkarSession.morning: 7 * 60,
    AzkarSession.evening: 17 * 60,
  };

  final Set<AzkarSession> on;
  final Map<AzkarSession, int> times;

  /// The last permission request was refused.
  final bool denied;

  int timeOf(AzkarSession s) => times[s] ?? defaultTimes[s]!;

  @override
  List<Object?> get props => [on, times, denied];
}

/// Daily morning / evening adhkar notifications.
class AzkarRemindersCubit extends HydratedCubit<AzkarReminders> {
  AzkarRemindersCubit({required this._notifier, DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(const AzkarReminders());

  final PrayerNotifier _notifier;
  final DateTime Function() _now;
  String _language = 'en';

  /// Turning a session on asks for notification permission first.
  Future<void> setEnabled(AzkarSession s, bool enabled) async {
    if (enabled) {
      bool granted;
      try {
        granted = await _notifier.requestPermission();
      } catch (_) {
        granted = false;
      }
      if (!granted) {
        emit(AzkarReminders(on: state.on, times: state.times, denied: true));
        return;
      }
    }
    emit(
      AzkarReminders(
        on: enabled ? {...state.on, s} : ({...state.on}..remove(s)),
        times: state.times,
      ),
    );
    await _reschedule();
  }

  Future<void> setTime(AzkarSession s, int minutes) async {
    emit(
      AzkarReminders(
        on: state.on,
        times: {...state.times, s: minutes},
        denied: state.denied,
      ),
    );
    await _reschedule();
  }

  /// Called at start-up and when the app language changes; keeps the
  /// rolling week of reminders topped up.
  Future<void> sync(String language) async {
    _language = language;
    await _reschedule();
  }

  Future<void> _reschedule() async {
    final l = lookupL10n(Locale(_language));
    final reminders = azkarRemindersFor({
      for (final s in state.on) s: state.timeOf(s),
    }, _now());
    try {
      await _notifier.scheduleAzkar(
        reminders,
        title: (s) => switch (s) {
          AzkarSession.morning => l.morningAzkar,
          AzkarSession.evening => l.eveningAzkar,
        },
        body: l.azkarReminderBody,
      );
    } catch (_) {
      // No plugin (tests, unsupported platform): nothing to schedule on.
    }
  }

  @override
  AzkarReminders? fromJson(Map<String, dynamic> json) => AzkarReminders(
    on: {
      for (final n in json['on'] as List? ?? const [])
        ...AzkarSession.values.where((s) => s.name == n),
    },
    times: {
      ...AzkarReminders.defaultTimes,
      for (final s in AzkarSession.values)
        if ((json['times'] as Map?)?[s.name] case final num m) s: m.toInt(),
    },
  );

  @override
  Map<String, dynamic> toJson(AzkarReminders state) => {
    'on': [for (final s in state.on) s.name],
    'times': {for (final e in state.times.entries) e.key.name: e.value},
  };
}
