import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../data.dart';

String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

/// Look of the bead ring.
enum SebhaStyle { wood, amber, stone, pearl, digital }

/// Accent / bead tint.
enum SebhaColor { green, brown, black, turquoise, rose, gold }

extension SebhaColorX on SebhaColor {
  Color get base => switch (this) {
    SebhaColor.green => const Color(0xFF1E4D3A),
    SebhaColor.brown => const Color(0xFF6B3F1F),
    SebhaColor.black => const Color(0xFF1A1A1A),
    SebhaColor.turquoise => const Color(0xFF1A6B6B),
    SebhaColor.rose => const Color(0xFF8B3A4A),
    SebhaColor.gold => const Color(0xFF8A6A1E),
  };

  Color get highlight => switch (this) {
    SebhaColor.green => const Color(0xFF3D7A5A),
    SebhaColor.brown => const Color(0xFFA66B3A),
    SebhaColor.black => const Color(0xFF4A4A4A),
    SebhaColor.turquoise => const Color(0xFF3A9A9A),
    SebhaColor.rose => const Color(0xFFC45A6A),
    SebhaColor.gold => const Color(0xFFC9A227),
  };

  Color get soft => highlight.withValues(alpha: .22);
}

final class TasbihState extends Equatable {
  const TasbihState({
    this.index = 0,
    this.count = 0,
    this.total = 0,
    this.style = SebhaStyle.wood,
    this.color = SebhaColor.green,
  });

  final int index;
  final int count;

  /// Taps today.
  final int total;
  final SebhaStyle style;
  final SebhaColor color;

  Dhikr get current => adhkar[index];

  TasbihState copyWith({
    int? index,
    int? count,
    int? total,
    SebhaStyle? style,
    SebhaColor? color,
  }) => TasbihState(
    index: index ?? this.index,
    count: count ?? this.count,
    total: total ?? this.total,
    style: style ?? this.style,
    color: color ?? this.color,
  );

  @override
  List<Object> get props => [index, count, total, style, color];
}

enum TasbihTap { counted, dhikrDone, setDone }

class TasbihCubit extends HydratedCubit<TasbihState> {
  TasbihCubit({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _day = _dayKey((clock ?? DateTime.now)()),
      super(const TasbihState());

  final DateTime Function() _clock;
  String _day;

  TasbihTap tap() {
    final key = _dayKey(_clock());
    final s = key == _day
        ? state
        : TasbihState(style: state.style, color: state.color);
    _day = key;
    final count = s.count + 1;
    final done = count >= s.current.target;
    final index = done ? (s.index + 1) % adhkar.length : s.index;
    emit(
      s.copyWith(index: index, count: done ? 0 : count, total: s.total + 1),
    );
    if (!done) return TasbihTap.counted;
    return index == 0 ? TasbihTap.setDone : TasbihTap.dhikrDone;
  }

  void reset() => emit(
    TasbihState(
      total: state.total,
      style: state.style,
      color: state.color,
    ),
  );

  void setStyle(SebhaStyle style) => emit(state.copyWith(style: style));

  void setColor(SebhaColor color) => emit(state.copyWith(color: color));

  @override
  TasbihState? fromJson(Map<String, dynamic> json) {
    final style =
        SebhaStyle.values.asNameMap()[json['style'] as String?] ??
        SebhaStyle.wood;
    final color =
        SebhaColor.values.asNameMap()[json['color'] as String?] ??
        SebhaColor.green;
    if (json['day'] != _dayKey(_clock())) {
      return TasbihState(style: style, color: color);
    }
    final index = json['index'] as int? ?? 0;
    return TasbihState(
      index: index < adhkar.length ? index : 0,
      count: json['count'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      style: style,
      color: color,
    );
  }

  @override
  Map<String, dynamic> toJson(TasbihState state) => {
    'day': _day,
    'index': state.index,
    'count': state.count,
    'total': state.total,
    'style': state.style.name,
    'color': state.color.name,
  };
}
