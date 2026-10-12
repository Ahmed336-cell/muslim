import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/hisn_cubit.dart';
import '../bloc/quran/quran_prefs_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/hisn.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sleep_timer.dart';
import 'hisn_screen.dart';
import 'now_playing_screen.dart';

/// A bedtime recitation: [surah] [from]–[to]; [to] null runs on to the end
/// of the Quran (used for the last three surahs).
typedef _Bedtime = ({
  int surah,
  int from,
  int? to,
  String Function(L10n) title,
  String Function(L10n) why,
});

final List<_Bedtime> _bedtime = [
  (
    surah: 67,
    from: 1,
    to: 30,
    title: (l) => l.sleepMulk,
    why: (l) => l.sleepMulkWhy,
  ),
  (
    surah: 32,
    from: 1,
    to: 30,
    title: (l) => l.sleepSajdah,
    why: (l) => l.sleepSajdahWhy,
  ),
  (
    surah: 2,
    from: 255,
    to: 255,
    title: (l) => l.sleepKursi,
    why: (l) => l.sleepKursiWhy,
  ),
  (
    surah: 2,
    from: 285,
    to: 286,
    title: (l) => l.sleepBaqarah,
    why: (l) => l.sleepBaqarahWhy,
  ),
  (
    surah: 112,
    from: 1,
    to: null,
    title: (l) => l.sleepQuls,
    why: (l) => l.sleepQulsWhy,
  ),
];

/// Bedtime: the sleep adhkar, the surahs to recite and a sleep timer.
class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const SleepScreen());

  Future<void> _play(BuildContext context, _Bedtime b) async {
    final cubit = context.read<RecitationCubit>();
    final reciter = context.read<QuranPrefsCubit>().state.reciter;
    final lang = context.lang;
    if (b.to case final to?) {
      await cubit.playHifz(b.surah, b.from, to, reciter, lang);
    } else {
      await cubit.playAyahs(b.surah, b.from, reciter, lang);
    }
    if (context.mounted) await showNowPlaying(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final chapter = context
        .select((HisnCubit c) => c.state.book?.chapters)
        ?.where((c) => c.id == sleepChapter)
        .firstOrNull;
    final player = context.watch<RecitationCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l.featSleep)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          AppCard(
            child: Row(
              children: [
                Icon(Icons.bedtime_rounded, color: Palette.green, size: 34),
                const SizedBox(width: 14),
                Expanded(child: Text(l.sleepIntro, style: Fonts.body(14))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (chapter != null)
            AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HisnChapterScreen(chapter: chapter),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.nights_stay_outlined, color: Palette.green),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.sleepAdhkar,
                          style: Fonts.body(15.5, weight: FontWeight.w600),
                        ),
                        Text(
                          l.sleepAdhkarSub(context.n(chapter.items.length)),
                          style: Fonts.body(12.5, color: Palette.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
                ],
              ),
            ),
          const SizedBox(height: 20),
          SectionHeader(l.sleepRecite),
          for (final b in _bedtime)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                onTap: () => _play(context, b),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title(l),
                            style: Fonts.body(15.5, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.isAr
                                ? 'سورة ${surahs[b.surah - 1].arabic}'
                                : surahs[b.surah - 1].name,
                            style: Fonts.body(12.5, color: Palette.green),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b.why(l),
                            style: Fonts.body(12.5, color: Palette.inkSoft),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l.sleepListen,
                      onPressed: () => _play(context, b),
                      icon: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Palette.green,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          SectionHeader(l.sleepTimer),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.sleepOff),
                  selected: !player.sleepOn,
                  onSelected: (_) =>
                      context.read<RecitationCubit>().setSleepTimer(null),
                ),
                for (final m in sleepMinutes)
                  ChoiceChip(
                    label: Text(l.sleepMinutes(context.n(m))),
                    selected: false,
                    onSelected: (_) => context
                        .read<RecitationCubit>()
                        .setSleepTimer(Duration(minutes: m)),
                  ),
                ChoiceChip(
                  label: Text(l.sleepEndOfSurah),
                  selected: player.sleepAfterSurah,
                  onSelected: (_) =>
                      context.read<RecitationCubit>().sleepAfterThisSurah(),
                ),
              ],
            ),
          ),
          if (player.sleepAt != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: SleepCountdown(
                style: Fonts.body(13, color: Palette.green),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              l.sleepTimerHint,
              style: Fonts.body(12.5, color: Palette.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
