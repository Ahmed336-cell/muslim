import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../services/quran.dart';
import '../../services/recitation.dart';

final class QuranPrefs extends Equatable {
  const QuranPrefs({
    this.mushaf = Mushaf.uthmani,
    this.tafsir,
    this.fontSize = defaultFontSize,
    this.reciter = AyahReciter.alafasy,
  });

  static const defaultFontSize = 26.0;
  static const comfortFontSize = 36.0;
  static const minFontSize = 20.0;
  static const maxFontSize = 56.0;

  final Mushaf mushaf;

  /// Null until the user picks one; then [tafsirFor] stops following the
  /// app language.
  final TafsirSource? tafsir;
  final double fontSize;

  /// Voice for ayah-by-ayah listening in the mushaf.
  final AyahReciter reciter;

  TafsirSource tafsirFor(String language) =>
      tafsir ?? TafsirSource.defaultFor(language);

  QuranPrefs _copy({
    Mushaf? mushaf,
    TafsirSource? tafsir,
    double? fontSize,
    AyahReciter? reciter,
  }) => QuranPrefs(
    mushaf: mushaf ?? this.mushaf,
    tafsir: tafsir ?? this.tafsir,
    fontSize: fontSize ?? this.fontSize,
    reciter: reciter ?? this.reciter,
  );

  @override
  List<Object?> get props => [mushaf, tafsir, fontSize, reciter];
}

class QuranPrefsCubit extends HydratedCubit<QuranPrefs> {
  QuranPrefsCubit() : super(const QuranPrefs());

  void setMushaf(Mushaf mushaf) => emit(state._copy(mushaf: mushaf));

  void setTafsir(TafsirSource tafsir) => emit(state._copy(tafsir: tafsir));

  void setFontSize(double size) => emit(
    state._copy(
      fontSize: size.clamp(QuranPrefs.minFontSize, QuranPrefs.maxFontSize),
    ),
  );

  void setReciter(AyahReciter reciter) => emit(state._copy(reciter: reciter));

  @override
  QuranPrefs? fromJson(Map<String, dynamic> json) => QuranPrefs(
    mushaf: Mushaf.values.asNameMap()[json['mushaf']] ?? Mushaf.uthmani,
    tafsir: TafsirSource.values.asNameMap()[json['tafsir']],
    fontSize:
        (json['fontSize'] as num?)?.toDouble() ?? QuranPrefs.defaultFontSize,
    reciter: AyahReciter.byId(json['reciter'] as String?),
  );

  @override
  Map<String, dynamic> toJson(QuranPrefs state) => {
    'mushaf': state.mushaf.name,
    'tafsir': state.tafsir?.name,
    'fontSize': state.fontSize,
    'reciter': state.reciter.id,
  };
}
