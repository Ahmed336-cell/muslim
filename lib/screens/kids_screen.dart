import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lessons_cubit.dart';
import '../bloc/quran/quran_prefs_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/kids_content.dart';
import '../services/lessons.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';
import 'mushaf_screen.dart';
import 'now_playing_screen.dart';

const _sun = Color(0xFFE0A030);

/// Letters, short surahs and duas for children, with stars to collect.
class KidsScreen extends StatelessWidget {
  const KidsScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: 'kids'),
    builder: (_) => const KidsScreen(),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final progress = context.watch<LessonsCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l.featKids)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          AppCard(
            color: _sun.withValues(alpha: .15),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: _sun, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.kidsStars(context.n(progress.totalStars)),
                        style: Fonts.display(24),
                      ),
                      Text(
                        l.kidsStarsHint,
                        style: Fonts.body(13, color: Palette.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(l.kidsLetters),
          AppCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _LettersScreen()),
            ),
            child: Row(
              children: [
                Text('أ ب ت', style: Fonts.arabic(28, color: Palette.green)),
                const SizedBox(width: 16),
                Expanded(child: Text(l.kidsLettersSub, style: Fonts.body(14))),
                Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LessonCard(lettersLesson()),
          const SizedBox(height: 10),
          SectionHeader(l.kidsSurahs),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final s in kidsSurahs)
                  _SurahRow(surah: s, learnt: progress.surahs.contains(s)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(l.kidsDuas),
          const LessonCard(kidsDuas),
          const LessonCard(wuduLesson),
          const LessonCard(salahLesson),
        ],
      ),
    );
  }
}

class _SurahRow extends StatelessWidget {
  const _SurahRow({required this.surah, required this.learnt});

  final int surah;
  final bool learnt;

  Future<void> _play(BuildContext context) async {
    final s = surahs[surah - 1];
    await context.read<RecitationCubit>().playHifz(
      surah,
      1,
      s.ayahs,
      context.read<QuranPrefsCubit>().state.reciter,
      context.lang,
      ayahRepeat: 2,
    );
    if (context.mounted) await showNowPlaying(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = surahs[surah - 1];
    return ListTile(
      onTap: () => Navigator.push(context, MushafScreen.route(surah)),
      leading: IconButton(
        tooltip: l.kidsListen,
        onPressed: () => _play(context),
        icon: Icon(
          Icons.play_circle_fill_rounded,
          color: Palette.green,
          size: 34,
        ),
      ),
      title: Text(
        context.isAr ? 'سورة ${s.arabic}' : s.name,
        style: Fonts.body(15.5, weight: FontWeight.w500),
      ),
      subtitle: Text(
        l.kidsAyahs(context.n(s.ayahs)),
        style: Fonts.body(12.5, color: Palette.inkSoft),
      ),
      trailing: IconButton(
        tooltip: l.kidsLearnt,
        onPressed: () => context.read<LessonsCubit>().toggleSurah(surah),
        icon: Icon(
          learnt ? Icons.star_rounded : Icons.star_outline_rounded,
          color: learnt ? _sun : Palette.inkSoft,
          size: 30,
        ),
      ),
    );
  }
}

class _LettersScreen extends StatelessWidget {
  const _LettersScreen();

  void _show(BuildContext context, (String, Tr, String) letter) {
    final (char, name, word) = letter;
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(char, style: Fonts.arabic(96, color: Palette.green)),
            Text(name.of(context.lang), style: Fonts.display(24)),
            const SizedBox(height: 12),
            Text(word, style: Fonts.arabic(36)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l.kidsLetters)),
    body: Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.count(
        crossAxisCount: 4,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          for (final (i, letter) in arabicLetters.indexed)
            Material(
              color: Color.lerp(
                Palette.greenSoft,
                _sun.withValues(alpha: .25),
                (i % 4) / 3,
              ),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _show(context, letter),
                child: Center(
                  child: Text(
                    letter.$1,
                    style: Fonts.arabic(40, color: Palette.ink),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
