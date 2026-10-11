import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../services/islamic_api.dart';
import '../services/places.dart';

final class Settings extends Equatable {
  const Settings({
    this.language = 'en',
    this.cityId = 'cairo',
    this.hanafiAsr = false,
  });

  /// 'en' or 'ar'. Drives the UI and the language of API content.
  final String language;
  final String cityId;
  final bool hanafiAsr;

  bool get isArabic => language == 'ar';

  City get city => cityById(cityId);

  Place get place {
    final c = city;
    return Place(c.lat, c.lon, method: c.method, school: hanafiAsr ? 2 : 1);
  }

  Settings copyWith({String? language, String? cityId, bool? hanafiAsr}) =>
      Settings(
        language: language ?? this.language,
        cityId: cityId ?? this.cityId,
        hanafiAsr: hanafiAsr ?? this.hanafiAsr,
      );

  @override
  List<Object> get props => [language, cityId, hanafiAsr];
}

class SettingsCubit extends HydratedCubit<Settings> {
  SettingsCubit({String initialLanguage = 'en'})
    : super(Settings(language: initialLanguage == 'ar' ? 'ar' : 'en'));

  void setLanguage(String language) => emit(state.copyWith(language: language));

  void setCity(String id) {
    // Hanafi Asr is the default where it's the dominant school.
    final hanafi = cityById(id).school == 2;
    emit(state.copyWith(cityId: id, hanafiAsr: hanafi));
  }

  void setHanafiAsr(bool value) => emit(state.copyWith(hanafiAsr: value));

  @override
  Settings? fromJson(Map<String, dynamic> json) => Settings(
    language: json['language'] as String? ?? 'en',
    cityId: json['city'] as String? ?? 'cairo',
    hanafiAsr: json['hanafi'] as bool? ?? false,
  );

  @override
  Map<String, dynamic> toJson(Settings state) => {
    'language': state.language,
    'city': state.cityId,
    'hanafi': state.hanafiAsr,
  };
}
