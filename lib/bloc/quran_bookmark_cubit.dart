import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Number of the surah the user marked as last read, or null.
class QuranBookmarkCubit extends HydratedCubit<int?> {
  QuranBookmarkCubit() : super(null);

  void mark(int surah) => emit(surah);

  @override
  int? fromJson(Map<String, dynamic> json) => json['surah'] as int?;

  @override
  Map<String, dynamic> toJson(int? state) => {'surah': state};
}
