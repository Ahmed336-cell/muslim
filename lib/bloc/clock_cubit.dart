import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class ClockCubit extends Cubit<DateTime> {
  ClockCubit({Duration every = const Duration(seconds: 30)})
    : super(DateTime.now()) {
    _timer = Timer.periodic(every, (_) => emit(DateTime.now()));
  }

  late final Timer _timer;

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
