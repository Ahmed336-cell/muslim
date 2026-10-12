import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/quran.dart';
import '../theme.dart';
import 'star_pattern.dart';

/// Colours used by the alquran.cloud tajweed edition.
const tajweedColors = <String, Color>{
  'h': Color(0xFFA19C94),
  's': Color(0xFFA19C94),
  'l': Color(0xFFA19C94),
  'n': Color(0xFF537FFF),
  'p': Color(0xFF4050FF),
  'm': Color(0xFF000EBC),
  'o': Color(0xFF2144C1),
  'q': Color(0xFFDD0008),
  'c': Color(0xFFD500B7),
  'f': Color(0xFF9400A8),
  'w': Color(0xFF58B800),
  'i': Color(0xFF26BFFD),
  'a': Color(0xFF169777),
  'u': Color(0xFF169200),
  'd': Color(0xFFA19C94),
  'b': Color(0xFFA19C94),
  'g': Color(0xFFFF7E1E),
};

/// Spans for one ayah's text, coloured when [mushaf] is tajweed.
List<InlineSpan> ayahSpans(
  String text,
  Mushaf mushaf, {
  GestureRecognizer? recognizer,
  Color? background,
}) {
  final bg = background == null ? null : TextStyle(backgroundColor: background);
  if (mushaf != Mushaf.tajweed) {
    return [TextSpan(text: text, style: bg, recognizer: recognizer)];
  }
  return [
    for (final (run, rule) in tajweedRuns(text))
      TextSpan(
        text: run,
        style: rule == null
            ? bg
            : TextStyle(
                color: tajweedColors[rule],
                backgroundColor: background,
              ),
        recognizer: recognizer,
      ),
  ];
}

/// End-of-ayah rosette with the ayah number.
class AyahMarker extends StatelessWidget {
  const AyahMarker(this.number, {super.key, required this.size, this.color});

  final int number;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Palette.brass;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          StarMark(size: size, color: color, filled: false),
          Text(
            arabicDigits('$number'),
            textScaler: TextScaler.noScaling,
            style: Fonts.arabic(
              size * (number > 99 ? .3 : .38),
              color: Palette.ink,
            ).copyWith(height: 1),
          ),
        ],
      ),
    );
  }
}

/// Small legend for the tajweed colours.
class TajweedKey extends StatelessWidget {
  const TajweedKey({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final entries = [
      ('h', l.tjSilent),
      ('n', l.tjMadd),
      ('g', l.tjGhunnah),
      ('f', l.tjIkhfa),
      ('a', l.tjIdgham),
      ('i', l.tjIqlab),
      ('q', l.tjQalqalah),
    ];
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        for (final (rule, label) in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: tajweedColors[rule],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(label, style: Fonts.body(12.5, color: Palette.inkSoft)),
            ],
          ),
      ],
    );
  }
}
