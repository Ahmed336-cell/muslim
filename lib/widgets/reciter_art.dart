import 'package:flutter/material.dart';

import '../theme.dart';
import 'star_pattern.dart';

/// Cover colours; a reciter always gets the same pair.
const _covers = [
  (Color(0xFF1E4D3A), Color(0xFF0E2A1F)),
  (Color(0xFF7A4B1E), Color(0xFF3B230C)),
  (Color(0xFF1F4E5F), Color(0xFF0D2731)),
  (Color(0xFF6B2E3A), Color(0xFF34141B)),
  (Color(0xFF3E3A6B), Color(0xFF1C1A38)),
  (Color(0xFF52602A), Color(0xFF282F12)),
  (Color(0xFF8A5A2B), Color(0xFF452B12)),
  (Color(0xFF2F5D50), Color(0xFF142D26)),
];

(Color, Color) coverColors(String seed) {
  var h = 0;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return _covers[h % _covers.length];
}

/// The word that best tells reciters apart: the family name, skipping
/// particles like "bin" that end a name.
String coverWord(String name) {
  const particles = {'bin', 'ibn', 'bn', 'بن', 'ابن'};
  final words = [
    for (final w in name.split(RegExp(r'\s+')))
      if (w.isNotEmpty && !particles.contains(w.toLowerCase())) w,
  ];
  if (words.isEmpty) return name;
  final last = words.last;
  return last.length < 3 && words.length > 1
      ? '${words[words.length - 2]} $last'
      : last;
}

/// The reciter's photo when bundled, otherwise generated cover art: a
/// geometric pattern with the family name.
class ReciterArt extends StatelessWidget {
  const ReciterArt({
    super.key,
    required this.name,
    this.size = 56,
    this.circle = false,
    this.label,
    this.photo,
  });

  final String name;
  final double size;
  final bool circle;

  /// Large text instead of the initial, e.g. a surah name.
  final String? label;

  /// Bundled photo asset path.
  final String? photo;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    if (photo == null) return _generated();
    final radius = BorderRadius.circular(circle ? size / 2 : size * .08);
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              photo,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -.6),
              cacheWidth: px,
              errorBuilder: (_, _, _) => _generated(),
            ),
            // Room for a surah name on the big now-playing cover.
            if (label case final text? when size >= 120)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(12, size * .18, 12, size * .06),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: .75),
                      ],
                    ),
                  ),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Fonts.arabic(
                      size * .1,
                      color: const Color(0xFFF1DFB8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _generated() {
    final (light, dark) = coverColors(name);
    final text = label ?? coverWord(name);
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(circle ? size / 2 : size * .08),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [light, dark],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              StarPattern(
                color: Palette.brass.withValues(alpha: .22),
                cell: size / 3.2,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(size * (circle ? .18 : .12)),
                  child: FittedBox(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: Fonts.arabic(
                        size * .17,
                        color: const Color(0xFFF1DFB8),
                      ).copyWith(height: 1.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
