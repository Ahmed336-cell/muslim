import 'package:hydrated_bloc/hydrated_bloc.dart';

/// The last surahs read, newest first, each with the page reached.
class RecentSurahsCubit extends HydratedCubit<List<(int surah, int page)>> {
  RecentSurahsCubit() : super(const []);

  static const limit = 3;

  void visit(int surah, int page) {
    if (state.isNotEmpty && state.first == (surah, page)) return;
    emit([(surah, page), ...state.where((e) => e.$1 != surah).take(limit - 1)]);
  }

  @override
  List<(int, int)>? fromJson(Map<String, dynamic> json) => [
    for (final e in json['recent'] as List? ?? const [])
      ((e as List)[0] as int, e[1] as int),
  ];

  @override
  Map<String, dynamic> toJson(List<(int, int)> state) => {
    'recent': [
      for (final (s, p) in state) [s, p],
    ],
  };
}
