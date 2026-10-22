import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Tracks when each Explore "new" badge first appeared.
/// Badge shows for that calendar day only, then never again.
class FeatureNewsCubit extends HydratedCubit<Map<String, String>> {
  FeatureNewsCubit() : super(const {});

  static String _dayKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    final m = '${d.month}'.padLeft(2, '0');
    final day = '${d.day}'.padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  /// True while [highlight] is still on its first calendar day.
  bool isFresh(String? highlight) {
    if (highlight == null) return false;
    final first = state[highlight];
    final today = _dayKey();
    if (first == null) return true;
    return first == today;
  }

  /// Record first sighting as today (no-op if already recorded).
  void noteShown(String highlight) {
    if (state.containsKey(highlight)) return;
    emit({...state, highlight: _dayKey()});
  }

  @override
  Map<String, String>? fromJson(Map<String, dynamic> json) {
    final shown = json['shown'];
    if (shown is Map) {
      return {
        for (final e in shown.entries) '${e.key}': '${e.value}',
      };
    }
    // Old format: dismissed forever → treat as past day so badge stays gone.
    final seen = json['seen'];
    if (seen is List) {
      return {for (final e in seen) '$e': '1970-01-01'};
    }
    return const {};
  }

  @override
  Map<String, dynamic>? toJson(Map<String, String> state) => {
    'shown': state,
  };
}
