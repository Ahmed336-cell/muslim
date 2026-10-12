import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/hisn_cubit.dart';
import '../l10n/l10n.dart';
import '../services/hisn.dart';
import '../theme.dart';
import '../widgets/azkar_card.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';
import '../widgets/dhikr_card.dart';

/// Hisn al-Muslim: morning / evening shortcuts, then every chapter.
class HisnScreen extends StatefulWidget {
  const HisnScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const HisnScreen());

  @override
  State<HisnScreen> createState() => _HisnScreenState();
}

class _HisnScreenState extends State<HisnScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<HisnCubit>()..load();
    if (cubit.state.query.isNotEmpty) cubit.search('');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<HisnCubit>().state;
    final book = state.book;
    final searching = state.query.trim().isNotEmpty;
    final results = state.results;

    return Scaffold(
      appBar: AppBar(title: Text(l.featHisn)),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!searching) ...[
                    const Row(
                      children: [
                        Expanded(
                          child: AzkarSessionCard(
                            session: AzkarSession.morning,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: AzkarSessionCard(
                            session: AzkarSession.evening,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  SearchField(
                    enabled: book != null,
                    hint: l.hisnSearch,
                    onChanged: context.read<HisnCubit>().search,
                  ),
                ],
              ),
            ),
          ),
          if (book == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: state.failed
                  ? Center(
                      child: Text(
                        l.hisnLoadFailed,
                        style: Fonts.body(14, color: Palette.inkSoft),
                      ),
                    )
                  : const Align(
                      alignment: Alignment.topCenter,
                      child: ListSkeleton(),
                    ),
            )
          else ...[
            if (!searching)
              SliverToBoxAdapter(
                child: SectionHeader(
                  '${l.hisnChapters} · ${context.n(book.chapters.length)}',
                ),
              ),
            SliverList.separated(
              itemCount: results.length,
              separatorBuilder: (_, _) => const RowDivider(indent: 72),
              itemBuilder: (_, i) => _ChapterRow(chapter: results[i]),
            ),
            if (results.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    l.noHisnMatch(state.query.trim()),
                    textAlign: TextAlign.center,
                    style: Fonts.body(14, color: Palette.inkSoft),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Text(
                  l.hisnSource,
                  textAlign: TextAlign.center,
                  style: Fonts.body(12, color: Palette.inkSoft),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({required this.chapter});

  final HisnChapter chapter;

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HisnChapterScreen(chapter: chapter)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: NumberBadge(chapter.id),
      title: Text(
        chapter.title(context.lang),
        style: ar
            ? Fonts.arabic(17, color: Palette.ink)
            : Fonts.body(15.5, weight: FontWeight.w500),
      ),
      subtitle: ar
          ? null
          : Text(
              chapter.arabic,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: Fonts.arabic(14, color: Palette.green),
            ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
    );
  }
}

class HisnChapterScreen extends StatelessWidget {
  const HisnChapterScreen({super.key, required this.chapter});

  final HisnChapter chapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chapter.title(context.lang),
          maxLines: 2,
          style: Fonts.body(17, weight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 32),
        itemCount: chapter.items.length,
        itemBuilder: (_, i) => DhikrCard(dhikr: chapter.items[i]),
      ),
    );
  }
}
