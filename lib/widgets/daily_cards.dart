import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../screens/mushaf_screen.dart';
import '../services/daily_content.dart';
import '../services/quran.dart';
import '../theme.dart';
import 'ayah_share.dart';
import 'common.dart';
import 'quran_text.dart';
import 'share_card.dart';
import 'shimmer.dart';
import 'star_pattern.dart';

/// A different ayah each day, read from the bundled mushaf.
class DailyAyahCard extends StatefulWidget {
  const DailyAyahCard({super.key});

  @override
  State<DailyAyahCard> createState() => _DailyAyahCardState();
}

class _DailyAyahCardState extends State<DailyAyahCard> {
  (int, int)? _ref;
  Future<(String, String?)>? _content;

  Future<(String, String?)> _load((int, int) ref, String lang) async {
    final api = context.read<QuranApi>();
    final (surah, ayah) = ref;
    final a = await api.fetchAyah(surah, ayah, Mushaf.uthmani);
    String? meaning;
    if (lang != 'ar') {
      try {
        meaning = await api.fetchTafsir(TafsirSource.saheeh, surah, ayah);
      } catch (_) {}
    }
    return (a.text, meaning);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final now = context.select((ClockCubit c) {
      final t = c.state;
      return DateTime(t.year, t.month, t.day);
    });
    final ref = ayahOfDay(now);
    if (ref != _ref) {
      _ref = ref;
      _content = _load(ref, context.lang);
    }
    final (surah, ayah) = ref;
    final s = surahs[surah - 1];

    return AppCard(
      onTap: () => Navigator.of(
        context,
      ).push(MushafScreen.route(surah, ayah: ayah, highlight: true)),
      padding: const EdgeInsets.fromLTRB(18, 8, 8, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StarMark(size: 9, color: Palette.clay),
              const SizedBox(width: 8),
              Expanded(child: Caption(l.verseTitle)),
              IconButton(
                tooltip: l.shareImage,
                onPressed: () =>
                    showAyahShare(context, surah: surah, ayah: ayah),
                icon: Icon(
                  Icons.ios_share_rounded,
                  size: 20,
                  color: Palette.inkSoft,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: FutureBuilder(
              future: _content,
              builder: (context, snap) {
                final data = snap.data;
                if (data == null) {
                  return const Shimmer(
                    child: SkeletonLines(
                      lines: 2,
                      height: 18,
                      align: CrossAxisAlignment.center,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: data.$1),
                          const TextSpan(text: '\u00A0'),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: AyahMarker(ayah, size: 26),
                          ),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: Fonts.mushaf(22, color: Palette.green),
                    ),
                    if (data.$2 case final m? when m.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        m,
                        textAlign: TextAlign.center,
                        style: Fonts.quote(16.5, color: Palette.ink),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.isAr
                ? 'سورة ${s.arabic} · ${context.n(ayah)}'
                : '${s.name} $surah:$ayah',
            textAlign: TextAlign.center,
            style: Fonts.body(12, color: Palette.inkSoft),
          ),
        ],
      ),
    );
  }
}

class HadithCard extends StatelessWidget {
  const HadithCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lang = context.lang;
    final day = context.select((ClockCubit c) {
      final t = c.state;
      return DateTime(t.year, t.month, t.day);
    });
    final h = hadithOfDay(day);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 8, 8, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StarMark(size: 9, color: Palette.clay),
              const SizedBox(width: 8),
              Expanded(child: Caption(l.hadithTitle)),
              IconButton(
                tooltip: l.shareImage,
                onPressed: () => showShareCard(
                  context,
                  sheetTitle: l.shareHadith,
                  eyebrow: l.hadithTitle,
                  arabic: h.ar,
                  meaning: lang == 'ar' ? null : h.en,
                  citation: h.source(lang),
                  allowHideMeaning: lang != 'ar',
                ),
                icon: Icon(
                  Icons.ios_share_rounded,
                  size: 20,
                  color: Palette.inkSoft,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  h.ar,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: Fonts.arabic(20, color: Palette.green),
                ),
                if (lang != 'ar') ...[
                  const SizedBox(height: 6),
                  Text(
                    h.en,
                    textAlign: TextAlign.center,
                    style: Fonts.quote(16.5, color: Palette.ink),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  h.source(lang),
                  textAlign: TextAlign.center,
                  style: Fonts.body(12, color: Palette.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
