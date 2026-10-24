import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/hifz_cubit.dart';
import '../l10n/l10n.dart';
import '../services/quran.dart';
import '../services/recite_check.dart';
import '../theme.dart';
import 'common.dart';
import 'quran_text.dart';

const reciteMistakeColor = Color(0xFFD64545);
const reciteSkippedColor = Color(0xFFE0A030);

/// Score, mistakes and the option to mark clean ayahs as memorised.
class ReciteFeedback extends StatelessWidget {
  const ReciteFeedback(
    this.result, {
    super.key,
    this.surah,
    this.allowRetry = true,
  });

  final ReciteResult result;

  /// Surah the check belongs to. Defaults to the surah open in hifz.
  final int? surah;

  final bool allowRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final h = context.watch<HifzCubit>().state;
    final score = result.score;
    final (grade, color) = switch (score) {
      >= .95 => (l.gradeExcellent, Palette.green),
      >= .8 => (l.gradeVeryGood, Palette.green),
      >= .6 => (l.gradeGood, reciteSkippedColor),
      _ => (l.gradeReview, reciteMistakeColor),
    };
    final unreached = result.count(WordMark.unreached);
    final perfect = result.perfectAyahs;
    final surah = this.surah ?? h.surah;
    final allLearnt = perfect.every((a) => h.isMemorized(surah, a));
    final mistakes = result.mistakes;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          children: [
            Text(
              l.feedbackTitle,
              textAlign: TextAlign.center,
              style: Fonts.display(20),
            ),
            const SizedBox(height: 18),
            Center(
              child: SizedBox.square(
                dimension: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: score,
                      strokeWidth: 9,
                      color: color,
                      backgroundColor: Palette.rule,
                    ),
                    Center(
                      child: Text(
                        '${context.n((score * 100).round())}%',
                        style: Fonts.body(24, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              grade,
              textAlign: TextAlign.center,
              style: Fonts.body(16, weight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat(
                  result.count(WordMark.correct),
                  l.feedbackMatched,
                  Palette.green,
                ),
                _Stat(
                  result.count(WordMark.wrong),
                  l.feedbackMistakes,
                  reciteMistakeColor,
                ),
                _Stat(
                  result.count(WordMark.missing),
                  l.feedbackSkipped,
                  reciteSkippedColor,
                ),
              ],
            ),
            if (unreached > 0) ...[
              const SizedBox(height: 12),
              Text(
                l.feedbackUnreached(context.n(unreached)),
                textAlign: TextAlign.center,
                style: Fonts.body(12.5, color: Palette.inkSoft),
              ),
            ],
            if (perfect.isNotEmpty) ...[
              const SizedBox(height: 14),
              AppCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                color: Palette.greenSoft,
                child: Row(
                  children: [
                    Icon(Icons.verified_rounded, color: Palette.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.feedbackPerfect(context.n(perfect.length)),
                        style: Fonts.body(13.5, weight: FontWeight.w500),
                      ),
                    ),
                    if (allLearnt)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.check_rounded, color: Palette.green),
                      )
                    else
                      TextButton(
                        onPressed: () => context
                            .read<HifzCubit>()
                            .markMemorized(surah, perfect),
                        child: Text(l.feedbackMarkLearnt),
                      ),
                  ],
                ),
              ),
            ],
            if (mistakes.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                l.feedbackReview,
                style: Fonts.body(14, weight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              for (final w in mistakes)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: AyahMarker(w.ayah, size: 30),
                  title: Text(
                    stripTajweed(w.word),
                    textDirection: TextDirection.rtl,
                    style: Fonts.mushaf(
                      22,
                      height: 1.6,
                      color: result.markOf(w) == WordMark.wrong
                          ? reciteMistakeColor
                          : reciteSkippedColor,
                    ),
                  ),
                  subtitle: Text(switch (result.heardAs[(w.ayah, w.index)]) {
                    final heard? => l.feedbackHeardAs(heard),
                    null => l.feedbackSkippedWord,
                  }, style: Fonts.body(12.5, color: Palette.inkSoft)),
                ),
            ],
            const SizedBox(height: 18),
            if (allowRetry)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.mic_none_rounded),
                      label: Text(l.retry),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.feedbackDone),
                    ),
                  ),
                ],
              )
            else
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.feedbackDone),
              ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color);

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          context.n(value),
          style: Fonts.body(20, weight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Fonts.body(12, color: Palette.inkSoft),
        ),
      ],
    ),
  );
}
