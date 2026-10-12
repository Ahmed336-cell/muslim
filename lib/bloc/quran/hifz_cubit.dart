import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../data.dart';

/// How much of each ayah shows while testing yourself.
enum HifzHide { none, firstWords, all }

final class HifzState extends Equatable {
  const HifzState({
    this.surah = 1,
    this.from = 1,
    this.to = 7,
    this.ayahRepeat = 3,
    this.rangeRepeat = 1,
    this.hide = HifzHide.none,
    this.memorized = const {},
    this.revealLive = true,
  });

  final int surah;
  final int from;
  final int to;
  final int ayahRepeat;
  final int rangeRepeat;
  final HifzHide hide;

  /// 'surah:ayah' keys of ayahs marked as memorised.
  final Set<String> memorized;

  /// Recite & check uncovers each word as it's heard.
  final bool revealLive;

  bool isMemorized(int surah, int ayah) => memorized.contains('$surah:$ayah');

  int memorizedIn(int surah) =>
      memorized.where((k) => k.startsWith('$surah:')).length;

  HifzState copyWith({
    int? surah,
    int? from,
    int? to,
    int? ayahRepeat,
    int? rangeRepeat,
    HifzHide? hide,
    Set<String>? memorized,
    bool? revealLive,
  }) => HifzState(
    surah: surah ?? this.surah,
    from: from ?? this.from,
    to: to ?? this.to,
    ayahRepeat: ayahRepeat ?? this.ayahRepeat,
    rangeRepeat: rangeRepeat ?? this.rangeRepeat,
    hide: hide ?? this.hide,
    memorized: memorized ?? this.memorized,
    revealLive: revealLive ?? this.revealLive,
  );

  @override
  List<Object?> get props => [
    surah,
    from,
    to,
    ayahRepeat,
    rangeRepeat,
    hide,
    memorized,
    revealLive,
  ];
}

class HifzCubit extends HydratedCubit<HifzState> {
  HifzCubit() : super(const HifzState());

  static const repeats = [1, 3, 5, 7, 10, 20];

  /// Picks [surah]; the range defaults to its first few ayahs.
  void setSurah(int surah) {
    final count = surahs[surah - 1].ayahs;
    emit(state.copyWith(surah: surah, from: 1, to: count < 5 ? count : 5));
  }

  void setRange(int from, int to) {
    final count = surahs[state.surah - 1].ayahs;
    final a = from.clamp(1, count), b = to.clamp(1, count);
    emit(state.copyWith(from: a < b ? a : b, to: a < b ? b : a));
  }

  void setAyahRepeat(int n) => emit(state.copyWith(ayahRepeat: n));

  void setRangeRepeat(int n) => emit(state.copyWith(rangeRepeat: n));

  void setHide(HifzHide hide) => emit(state.copyWith(hide: hide));

  void setRevealLive(bool on) => emit(state.copyWith(revealLive: on));

  void markMemorized(int surah, Iterable<int> ayahs) => emit(
    state.copyWith(
      memorized: {...state.memorized, for (final a in ayahs) '$surah:$a'},
    ),
  );

  void toggleMemorized(int surah, int ayah) {
    final key = '$surah:$ayah';
    final set = {...state.memorized};
    if (!set.remove(key)) set.add(key);
    emit(state.copyWith(memorized: set));
  }

  @override
  HifzState? fromJson(Map<String, dynamic> json) => HifzState(
    surah: json['surah'] as int? ?? 1,
    from: json['from'] as int? ?? 1,
    to: json['to'] as int? ?? 7,
    ayahRepeat: json['ayahRepeat'] as int? ?? 3,
    rangeRepeat: json['rangeRepeat'] as int? ?? 1,
    hide: HifzHide.values.asNameMap()[json['hide']] ?? HifzHide.none,
    memorized: {for (final k in json['memorized'] as List? ?? const []) '$k'},
    revealLive: json['revealLive'] as bool? ?? true,
  );

  @override
  Map<String, dynamic> toJson(HifzState state) => {
    'surah': state.surah,
    'from': state.from,
    'to': state.to,
    'ayahRepeat': state.ayahRepeat,
    'rangeRepeat': state.rangeRepeat,
    'hide': state.hide.name,
    'memorized': state.memorized.toList(),
    'revealLive': state.revealLive,
  };
}
