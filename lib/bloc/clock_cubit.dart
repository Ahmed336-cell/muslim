import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/clock.dart';

class ClockCubit extends Cubit<DateTime> {
  ClockCubit({Duration every = const Duration(seconds: 30)}) : super(appNow()) {
    _timer = Timer.periodic(every, (_) => emit(appNow()));
  }

  late final Timer _timer;

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
