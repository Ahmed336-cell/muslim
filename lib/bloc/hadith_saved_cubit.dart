import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Saved hadith, as `book:number` keys, newest first.
class HadithSavedCubit extends HydratedCubit<List<String>> {
  HadithSavedCubit() : super(const []);

  bool isSaved(String key) => state.contains(key);

  void toggle(String key) => emit(
    state.contains(key)
        ? [
            for (final k in state)
              if (k != key) k,
          ]
        : [key, ...state],
  );

  @override
  List<String>? fromJson(Map<String, dynamic> json) => [
    for (final k in json['keys'] as List? ?? const []) '$k',
  ];

  @override
  Map<String, dynamic> toJson(List<String> state) => {'keys': state};
}
