import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Tawashih munshid ids, most recently played first.
class RecentTawashihCubit extends HydratedCubit<List<String>> {
  RecentTawashihCubit() : super(const []);

  static const limit = 8;

  void played(String id) =>
      emit([id, ...state.where((r) => r != id)].take(limit).toList());

  @override
  List<String>? fromJson(Map<String, dynamic> json) => [
    for (final id in json['ids'] as List? ?? const []) '$id',
  ];

  @override
  Map<String, dynamic> toJson(List<String> state) => {'ids': state};
}
