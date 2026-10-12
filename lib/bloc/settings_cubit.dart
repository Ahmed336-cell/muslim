import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/islamic_api.dart';
import '../services/places.dart';

enum AppTheme { system, light, dark }

final class Settings extends Equatable {
  const Settings({
    this.language = 'en',
    this.cityId = 'cairo',
    this.hanafiAsr = false,
    this.location,
    this.methodId,
    this.offsets = Place.noOffsets,
    this.hijriShift = 0,
    this.theme = AppTheme.system,
  });

  /// 'en' or 'ar'. Drives the UI and the language of API content.
  final String language;
  final String cityId;
  final bool hanafiAsr;

  /// The device's position when the user chose "my location"; overrides
  /// [cityId] while set.
  final (double lat, double lon)? location;

  /// Calculation method chosen by the user; null = the city's own.
  final int? methodId;

  /// Minutes added to Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha.
  final List<int> offsets;

  /// Days added to the Hijri date (-2…2).
  final int hijriShift;

  final AppTheme theme;

  bool get isArabic => language == 'ar';

  bool get usesLocation => location != null;

  /// The chosen city, or the one nearest to [location]; supplies the
  /// calculation method and currency.
  City get city => switch (location) {
    (final lat, final lon) => nearestCity(lat, lon),
    null => cityById(cityId),
  };

  int get method => methodId ?? city.method;

  Place get place {
    final c = city;
    final (lat, lon) = location ?? (c.lat, c.lon);
    return Place(
      lat,
      lon,
      method: method,
      school: hanafiAsr ? 2 : 1,
      tz: usesLocation ? null : c.tz,
      offsets: offsets,
      hijriShift: hijriShift,
    );
  }

  Settings copyWith({
    String? language,
    String? cityId,
    bool? hanafiAsr,
    (double, double)? Function()? location,
    int? Function()? methodId,
    List<int>? offsets,
    int? hijriShift,
    AppTheme? theme,
  }) => Settings(
    language: language ?? this.language,
    cityId: cityId ?? this.cityId,
    hanafiAsr: hanafiAsr ?? this.hanafiAsr,
    location: location != null ? location() : this.location,
    methodId: methodId != null ? methodId() : this.methodId,
    offsets: offsets ?? this.offsets,
    hijriShift: hijriShift ?? this.hijriShift,
    theme: theme ?? this.theme,
  );

  @override
  List<Object?> get props => [
    language,
    cityId,
    hanafiAsr,
    location,
    methodId,
    offsets,
    hijriShift,
    theme,
  ];
}

class SettingsCubit extends HydratedCubit<Settings> {
  SettingsCubit({String initialLanguage = 'en'})
    : super(Settings(language: initialLanguage == 'ar' ? 'ar' : 'en'));

  void setLanguage(String language) => emit(state.copyWith(language: language));

  void setCity(String id) {
    // Hanafi Asr is the default where it's the dominant school.
    final hanafi = cityById(id).school == 2;
    emit(
      state.copyWith(
        cityId: id,
        hanafiAsr: hanafi,
        location: () => null,
        methodId: () => null,
      ),
    );
  }

  /// Rounded to ~100 m so small GPS jitter doesn't refetch prayer times.
  void setLocation(double lat, double lon) {
    double round(double v) => (v * 1000).roundToDouble() / 1000;
    final fix = (round(lat), round(lon));
    final hanafi = state.usesLocation
        ? state.hanafiAsr
        : nearestCity(fix.$1, fix.$2).school == 2;
    emit(state.copyWith(hanafiAsr: hanafi, location: () => fix));
  }

  void setHanafiAsr(bool value) => emit(state.copyWith(hanafiAsr: value));

  /// null restores the city's default method.
  void setMethod(int? id) => emit(state.copyWith(methodId: () => id));

  void setOffset(int prayer, int minutes) => emit(
    state.copyWith(
      offsets: [
        for (final (i, m) in state.offsets.indexed)
          i == prayer ? minutes.clamp(-30, 30) : m,
      ],
    ),
  );

  void resetOffsets() => emit(state.copyWith(offsets: Place.noOffsets));

  void setTheme(AppTheme theme) => emit(state.copyWith(theme: theme));

  void setHijriShift(int days) =>
      emit(state.copyWith(hijriShift: days.clamp(-2, 2)));

  @override
  Settings? fromJson(Map<String, dynamic> json) {
    final lat = (json['lat'] as num?)?.toDouble();
    final lon = (json['lon'] as num?)?.toDouble();
    final offsets = (json['offsets'] as List?)?.cast<num>();
    return Settings(
      language: json['language'] as String? ?? 'en',
      cityId: json['city'] as String? ?? 'cairo',
      hanafiAsr: json['hanafi'] as bool? ?? false,
      location: lat != null && lon != null ? (lat, lon) : null,
      methodId: (json['method'] as num?)?.toInt(),
      offsets: offsets != null && offsets.length == 6
          ? [for (final o in offsets) o.toInt()]
          : Place.noOffsets,
      hijriShift: (json['hijriShift'] as num?)?.toInt() ?? 0,
      theme: AppTheme.values.asNameMap()[json['theme']] ?? AppTheme.system,
    );
  }

  @override
  Map<String, dynamic> toJson(Settings state) => {
    'language': state.language,
    'city': state.cityId,
    'hanafi': state.hanafiAsr,
    'lat': state.location?.$1,
    'lon': state.location?.$2,
    'method': state.methodId,
    'offsets': state.offsets,
    'hijriShift': state.hijriShift,
    'theme': state.theme.name,
  };
}
