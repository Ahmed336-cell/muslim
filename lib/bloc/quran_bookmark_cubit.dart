import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

final class QuranBookmark extends Equatable {
  const QuranBookmark(this.surah, [this.ayah = 1]);

  final int surah;
  final int ayah;

  @override
  List<Object> get props => [surah, ayah];
}

/// Where the user marked they stopped reading, or null.
class QuranBookmarkCubit extends HydratedCubit<QuranBookmark?> {
  QuranBookmarkCubit() : super(null);

  void mark(int surah, [int ayah = 1]) => emit(QuranBookmark(surah, ayah));

  @override
  QuranBookmark? fromJson(Map<String, dynamic> json) {
    final surah = json['surah'] as int?;
    if (surah == null) return null;
    return QuranBookmark(surah, json['ayah'] as int? ?? 1);
  }

  @override
  Map<String, dynamic> toJson(QuranBookmark? state) => {
    'surah': state?.surah,
    'ayah': state?.ayah,
  };
}
