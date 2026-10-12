import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

final class LessonProgress extends Equatable {
  const LessonProgress({this.stars = const {}, this.surahs = const {}});

  /// Lesson id → best stars, 1–3. Present once the lesson is finished.
  final Map<String, int> stars;

  /// Short surahs a child has learnt.
  final Set<int> surahs;

  bool done(String id) => stars.containsKey(id);

  int get totalStars =>
      stars.values.fold(0, (sum, s) => sum + s) + surahs.length * 3;

  @override
  List<Object?> get props => [stars, surahs];
}

/// Finished lessons, quiz stars and surahs learnt in kids mode.
class LessonsCubit extends HydratedCubit<LessonProgress> {
  LessonsCubit() : super(const LessonProgress());

  /// Stars for [correct] of [total] answers; 3 when there was no quiz.
  static int starsFor(int correct, int total) {
    if (total == 0) return 3;
    final ratio = correct / total;
    return ratio >= .9 ? 3 : (ratio >= .6 ? 2 : 1);
  }

  void finish(String id, int stars) {
    if ((state.stars[id] ?? 0) >= stars) return;
    emit(
      LessonProgress(stars: {...state.stars, id: stars}, surahs: state.surahs),
    );
  }

  void toggleSurah(int surah) {
    final surahs = {...state.surahs};
    if (!surahs.remove(surah)) surahs.add(surah);
    emit(LessonProgress(stars: state.stars, surahs: surahs));
  }

  @override
  LessonProgress? fromJson(Map<String, dynamic> json) => LessonProgress(
    stars: {
      for (final MapEntry(:key, :value)
          in (json['stars'] as Map? ?? const {}).entries)
        '$key': (value as num).toInt(),
    },
    surahs: {
      for (final s in json['surahs'] as List? ?? const []) (s as num).toInt(),
    },
  );

  @override
  Map<String, dynamic> toJson(LessonProgress state) => {
    'stars': state.stars,
    'surahs': state.surahs.toList(),
  };
}
