import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { home, prayer, qibla, tasbih, more }

/// Selected bottom-navigation tab, so any screen can jump to another tab.
class TabCubit extends Cubit<AppTab> {
  TabCubit([super.initial = AppTab.home]);

  void select(AppTab tab) => emit(tab);
}
