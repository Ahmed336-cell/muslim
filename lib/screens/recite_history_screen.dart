import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/hifz_cubit.dart';
import '../bloc/quran/recite_history_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/recite_feedback.dart';

/// Saved recitation checks. Tap one to open its score and mistakes.
class ReciteHistoryScreen extends StatelessWidget {
  const ReciteHistoryScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const ReciteHistoryScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final attempts = context.watch<ReciteHistoryCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l.hifzHistory)),
      body: attempts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l.hifzHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: Fonts.body(15, color: Palette.inkSoft),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
              itemCount: attempts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final attempt = attempts[i];
                final surah = surahs[attempt.surah - 1];
                final score = (attempt.result.score * 100).round();
                return AppCard(
                  onTap: () => _open(context, attempt),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.isAr
                                  ? 'سورة ${surah.arabic}'
                                  : surah.name,
                              style: Fonts.body(16, weight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l.hifzRange(
                                context.n(attempt.from),
                                context.n(attempt.to),
                              ),
                              style: Fonts.body(13, color: Palette.inkSoft),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.date(
                                attempt.at.toLocal(),
                                'd MMM, h:mm a',
                              ),
                              style: Fonts.body(12.5, color: Palette.inkSoft),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${context.n(score)}%',
                        style: Fonts.body(
                          18,
                          weight: FontWeight.w700,
                          color: switch (attempt.result.score) {
                            >= .8 => Palette.green,
                            >= .6 => reciteSkippedColor,
                            _ => reciteMistakeColor,
                          },
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _open(BuildContext context, ReciteAttempt attempt) {
    final hifz = context.read<HifzCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: hifz,
        child: ReciteFeedback(
          attempt.result,
          surah: attempt.surah,
          allowRetry: false,
        ),
      ),
    );
  }
}
