import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran_bookmark_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/star_pattern.dart';

String _westernDigits(String s) => s.replaceAllMapped(
  RegExp('[٠-٩]'),
  (m) => '${m[0]!.codeUnitAt(0) - 0x0660}',
);

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const QuranScreen());

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final q = _westernDigits(_query.trim().toLowerCase());
    final list = surahs
        .where(
          (s) =>
              q.isEmpty ||
              '${s.number}' == q ||
              s.arabic.contains(q) ||
              s.name.toLowerCase().contains(q) ||
              s.meaning.toLowerCase().contains(q),
        )
        .toList();
    final bookmark = context.watch<QuranBookmarkCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l.quranTitle)),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.quranSummary,
                    style: Fonts.body(13, color: Palette.inkSoft),
                  ),
                  const SizedBox(height: 12),
                  SearchField(
                    hint: l.quranSearch,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ],
              ),
            ),
          ),
          if (bookmark != null && q.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: _LastRead(surah: surahs[bookmark - 1]),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverList.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const RowDivider(indent: 76),
            itemBuilder: (_, i) => _SurahRow(surah: list[i]),
          ),
          if (list.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  l.noMatch(_query.trim()),
                  textAlign: TextAlign.center,
                  style: Fonts.body(14, color: Palette.inkSoft),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _LastRead extends StatelessWidget {
  const _LastRead({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AppCard(
      color: Palette.ink,
      padding: EdgeInsets.zero,
      onTap: () => _showSurah(context, surah),
      child: Stack(
        children: [
          const PositionedDirectional(
            end: -30,
            top: -30,
            bottom: -30,
            width: 150,
            child: StarPattern(color: Color(0x22B0812F), cell: 40),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Row(
              children: [
                const Icon(Icons.bookmark_rounded, color: Palette.brass),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Caption(l.lastRead, color: Palette.brass),
                      const SizedBox(height: 4),
                      Text(
                        context.isAr ? surah.arabic : surah.name,
                        style: Fonts.display(24, color: Palette.paper),
                      ),
                      Text(
                        context.n(l.ayahCount(surah.ayahs)),
                        style: Fonts.body(
                          13,
                          color: Palette.paper.withValues(alpha: .6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!context.isAr)
                  Text(
                    surah.arabic,
                    style: Fonts.arabic(26, color: Palette.brass),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahRow extends StatelessWidget {
  const _SurahRow({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final details = [
      if (!ar) surah.meaning,
      context.n(l.ayahCount(surah.ayahs)),
      surah.meccan ? l.meccan : l.medinan,
    ].join('  ·  ');

    return ListTile(
      onTap: () => _showSurah(context, surah),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: NumberBadge(surah.number),
      title: Text(
        ar ? 'سورة ${surah.arabic}' : surah.name,
        style: Fonts.body(16, weight: FontWeight.w500),
      ),
      subtitle: Text(details, style: Fonts.body(12.5, color: Palette.inkSoft)),
      trailing: ar
          ? null
          : Text(surah.arabic, style: Fonts.arabic(22, color: Palette.green)),
    );
  }
}

void _showSurah(BuildContext context, Surah surah) {
  final bookmarks = context.read<QuranBookmarkCubit>();
  final messenger = ScaffoldMessenger.of(context);
  showModalBottomSheet<void>(
    context: context,
    builder: (sheet) {
      final l = sheet.l;
      Widget fact(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value, style: Fonts.display(22)),
            const SizedBox(height: 2),
            Text(label, style: Fonts.body(12, color: Palette.inkSoft)),
          ],
        ),
      );

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                surah.arabic,
                textAlign: TextAlign.center,
                style: Fonts.arabic(48, color: Palette.green),
              ),
              if (!sheet.isAr) ...[
                Text(
                  surah.name,
                  textAlign: TextAlign.center,
                  style: Fonts.display(24),
                ),
                Text(
                  surah.meaning,
                  textAlign: TextAlign.center,
                  style: Fonts.quote(16),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  fact(l.surahNumber, sheet.n(surah.number)),
                  fact(l.ayahs, sheet.n(surah.ayahs)),
                  fact(l.revelation, surah.meccan ? l.meccan : l.medinan),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  bookmarks.mark(surah.number);
                  Navigator.pop(sheet);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l.markedLastRead)),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Palette.green,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: Text(
                  l.markLastRead,
                  style: Fonts.body(
                    15,
                    color: Palette.paper,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
