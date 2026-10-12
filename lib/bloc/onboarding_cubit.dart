import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

final class Onboarding extends Equatable {
  const Onboarding({this.done = false, this.step = 0});

  final bool done;

  /// Kept outside the widget tree: switching language on the first step
  /// rebuilds the whole app.
  final int step;

  @override
  List<Object> get props => [done, step];
}

class OnboardingCubit extends HydratedCubit<Onboarding> {
  OnboardingCubit() : super(const Onboarding());

  static const steps = 5;

  void goTo(int step) => emit(Onboarding(step: step.clamp(0, steps - 1)));

  void complete() => emit(const Onboarding(done: true));

  /// Shows the tour again from the start.
  void restart() => emit(const Onboarding());

  @override
  Onboarding? fromJson(Map<String, dynamic> json) => Onboarding(
    done: json['done'] as bool? ?? false,
    step: json['step'] as int? ?? 0,
  );

  @override
  Map<String, dynamic> toJson(Onboarding state) => {
    'done': state.done,
    'step': state.step,
  };
}
