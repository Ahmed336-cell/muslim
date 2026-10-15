import 'package:flutter_bloc/flutter_bloc.dart';

/// Qibla is hidden until the compass direction is verified on devices.
const qiblaEnabled = false;

enum AppTab {
  home,
  prayer,
  qibla,
  tasbih,
  more;

  /// Tabs shown in the bottom bar, in order.
  static List<AppTab> get visible => [
    for (final t in values)
      if (qiblaEnabled || t != qibla) t,
  ];
}

/// Selected bottom-navigation tab, so any screen can jump to another tab.
class TabCubit extends Cubit<AppTab> {
  TabCubit([super.initial = AppTab.home]);

  void select(AppTab tab) {
    if (AppTab.visible.contains(tab)) emit(tab);
  }
}
