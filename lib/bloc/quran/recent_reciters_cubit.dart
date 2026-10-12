import 'package:hydrated_bloc/hydrated_bloc.dart';

/// mp3quran reciter ids, most recently played first.
class RecentRecitersCubit extends HydratedCubit<List<int>> {
  RecentRecitersCubit() : super(const []);

  static const limit = 8;

  void played(int id) =>
      emit([id, ...state.where((r) => r != id)].take(limit).toList());

  @override
  List<int>? fromJson(Map<String, dynamic> json) => [
    for (final id in json['ids'] as List? ?? const []) id as int,
  ];

  @override
  Map<String, dynamic> toJson(List<int> state) => {'ids': state};
}
