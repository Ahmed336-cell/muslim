import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/islamic_api.dart';
import '../services/places.dart';

final class Settings extends Equatable {
  const Settings({
    this.language = 'en',
    this.cityId = 'cairo',
    this.hanafiAsr = false,
    this.location,
  });

  /// 'en' or 'ar'. Drives the UI and the language of API content.
  final String language;
  final String cityId;
  final bool hanafiAsr;

  /// The device's position when the user chose "my location"; overrides
  /// [cityId] while set.
  final (double lat, double lon)? location;

  bool get isArabic => language == 'ar';

  bool get usesLocation => location != null;

  /// The chosen city, or the one nearest to [location]; supplies the
  /// calculation method and currency.
  City get city => switch (location) {
    (final lat, final lon) => nearestCity(lat, lon),
    null => cityById(cityId),
  };

  Place get place {
    final c = city;
    final (lat, lon) = location ?? (c.lat, c.lon);
    return Place(lat, lon, method: c.method, school: hanafiAsr ? 2 : 1);
  }

  @override
  List<Object?> get props => [language, cityId, hanafiAsr, location];
}

class SettingsCubit extends HydratedCubit<Settings> {
  SettingsCubit({String initialLanguage = 'en'})
    : super(Settings(language: initialLanguage == 'ar' ? 'ar' : 'en'));

  void setLanguage(String language) => emit(
    Settings(
      language: language,
      cityId: state.cityId,
      hanafiAsr: state.hanafiAsr,
      location: state.location,
    ),
  );

  void setCity(String id) {
    // Hanafi Asr is the default where it's the dominant school.
    final hanafi = cityById(id).school == 2;
    emit(Settings(language: state.language, cityId: id, hanafiAsr: hanafi));
  }

  /// Rounded to ~100 m so small GPS jitter doesn't refetch prayer times.
  void setLocation(double lat, double lon) {
    double round(double v) => (v * 1000).roundToDouble() / 1000;
    final fix = (round(lat), round(lon));
    final hanafi = state.usesLocation
        ? state.hanafiAsr
        : nearestCity(fix.$1, fix.$2).school == 2;
    emit(
      Settings(
        language: state.language,
        cityId: state.cityId,
        hanafiAsr: hanafi,
        location: fix,
      ),
    );
  }

  void setHanafiAsr(bool value) => emit(
    Settings(
      language: state.language,
      cityId: state.cityId,
      hanafiAsr: value,
      location: state.location,
    ),
  );

  @override
  Settings? fromJson(Map<String, dynamic> json) {
    final lat = (json['lat'] as num?)?.toDouble();
    final lon = (json['lon'] as num?)?.toDouble();
    return Settings(
      language: json['language'] as String? ?? 'en',
      cityId: json['city'] as String? ?? 'cairo',
      hanafiAsr: json['hanafi'] as bool? ?? false,
      location: lat != null && lon != null ? (lat, lon) : null,
    );
  }

  @override
  Map<String, dynamic> toJson(Settings state) => {
    'language': state.language,
    'city': state.cityId,
    'hanafi': state.hanafiAsr,
    'lat': state.location?.$1,
    'lon': state.location?.$2,
  };
}
