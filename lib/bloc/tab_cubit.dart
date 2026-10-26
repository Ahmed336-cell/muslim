import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/analytics.dart';

/// Qibla tab in the bottom bar and the Explore grid.
const qiblaEnabled = true;

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
    if (!AppTab.visible.contains(tab)) return;
    final changed = tab != state;
    emit(tab);
    if (!changed) return;
    switch (tab) {
      case AppTab.prayer:
      case AppTab.qibla:
      case AppTab.tasbih:
        Analytics.feature(tab.name);
      case AppTab.home:
      case AppTab.more:
        break;
    }
  }
}
