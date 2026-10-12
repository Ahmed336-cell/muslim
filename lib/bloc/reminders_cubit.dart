import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../l10n/app_localizations.dart';
import '../services/adhan.dart';
import '../services/islamic_api.dart';
import '../services/notifications.dart';

final class Reminders extends Equatable {
  const Reminders({
    this.enabled = false,
    this.prayers = const {...reminderPrayers},
    this.denied = false,
    this.voice = AdhanVoice.makkah,
  });

  final bool enabled;
  final Set<String> prayers;

  /// The last permission request was refused.
  final bool denied;

  /// Adhan played with each reminder; null for the plain notification sound.
  final AdhanVoice? voice;

  Reminders _copy({bool? enabled, Set<String>? prayers, bool denied = false}) =>
      Reminders(
        enabled: enabled ?? this.enabled,
        prayers: prayers ?? this.prayers,
        denied: denied,
        voice: voice,
      );

  @override
  List<Object?> get props => [enabled, prayers, denied, voice];
}

/// Prayer-time notifications: preferences, permission and scheduling.
class RemindersCubit extends HydratedCubit<Reminders> {
  RemindersCubit({required this._notifier}) : super(const Reminders());

  final PrayerNotifier _notifier;
  PrayerDay? _day;
  String _language = 'en';
  bool _scheduled = false;

  /// Asks for permission; reminders turn on only if it's granted.
  Future<void> enable() async {
    bool granted;
    try {
      granted = await _notifier.requestPermission();
    } catch (_) {
      granted = false;
    }
    emit(state._copy(enabled: granted, denied: !granted));
    await _reschedule();
  }

  Future<void> disable() async {
    emit(state._copy(enabled: false));
    await _reschedule();
  }

  Future<void> toggle(String prayer) async {
    final prayers = {...state.prayers};
    if (!prayers.remove(prayer)) prayers.add(prayer);
    emit(state._copy(prayers: prayers));
    await _reschedule();
  }

  Future<void> setVoice(AdhanVoice? voice) async {
    emit(
      Reminders(
        enabled: state.enabled,
        prayers: state.prayers,
        denied: state.denied,
        voice: voice,
      ),
    );
    await _reschedule();
  }

  /// Called whenever today's times or the app language change.
  Future<void> sync(PrayerDay? day, String language) async {
    _day = day ?? _day;
    _language = language;
    await _reschedule();
  }

  Future<void> _reschedule() async {
    final day = _day;
    if (!state.enabled || day == null) {
      if (_scheduled) await _schedule(const []);
      return;
    }
    await _schedule(remindersFor(day, state.prayers, DateTime.now()));
  }

  Future<void> _schedule(List<PrayerReminder> reminders) async {
    final l = lookupL10n(Locale(_language));
    try {
      await _notifier.schedule(
        reminders,
        title: (p) => l.reminderTitle(_prayerName(l, p)),
        body: l.reminderBody,
        voice: state.voice,
      );
      _scheduled = reminders.isNotEmpty;
    } catch (_) {
      // No plugin (tests, unsupported platform): nothing to schedule on.
    }
  }

  static String _prayerName(L10n l, String key) => switch (key) {
    'Fajr' => l.fajr,
    'Dhuhr' => l.dhuhr,
    'Asr' => l.asr,
    'Maghrib' => l.maghrib,
    'Isha' => l.isha,
    _ => key,
  };

  @override
  Reminders? fromJson(Map<String, dynamic> json) => Reminders(
    enabled: json['enabled'] as bool? ?? false,
    prayers: {
      for (final p in json['prayers'] as List? ?? reminderPrayers) '$p',
    },
    voice: json.containsKey('voice')
        ? AdhanVoice.byName(json['voice'] as String?)
        : AdhanVoice.makkah,
  );

  @override
  Map<String, dynamic> toJson(Reminders state) => {
    'enabled': state.enabled,
    'prayers': state.prayers.toList(),
    'voice': state.voice?.name,
  };
}
