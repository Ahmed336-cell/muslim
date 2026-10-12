import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Whether the next-prayer Live Activity is wanted.
class LiveActivityCubit extends HydratedCubit<bool> {
  LiveActivityCubit() : super(false);

  void set(bool on) => emit(on);

  @override
  bool? fromJson(Map<String, dynamic> json) => json['on'] as bool? ?? false;

  @override
  Map<String, dynamic> toJson(bool state) => {'on': state};
}
