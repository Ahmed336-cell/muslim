import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_cubit.dart';
import '../bloc/ruqyah/ruqyah_bloc.dart';
import '../l10n/l10n.dart';
import '../services/ruqyah.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';

extension on RuqyahProgram {
  String title(L10n l) => switch (this) {
    RuqyahProgram.brief => l.programBrief,
    RuqyahProgram.medium => l.programMedium,
    RuqyahProgram.long => l.programLong,
  };
}

extension on RuqyahSource {
  String title(L10n l) => switch (this) {
    RuqyahSource.quran => l.fromQuran,
    RuqyahSource.sunnah => l.fromSunnah,
  };
}

class RuqyahScreen extends StatefulWidget {
  const RuqyahScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const RuqyahScreen());

  @override
  State<RuqyahScreen> createState() => _RuqyahScreenState();
}

class _RuqyahScreenState extends State<RuqyahScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RuqyahBloc>()
      ..add(const RuqyahRecitationRequested())
      ..add(const RuqyahTopicsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.ruqyahTitle),
          bottom: TabBar(
            dividerColor: Palette.rule,
            indicatorColor: Palette.green,
            indicatorWeight: 2.5,
            labelColor: Palette.green,
            unselectedLabelColor: Palette.inkSoft,
            labelStyle: Fonts.body(15, weight: FontWeight.w600),
            unselectedLabelStyle: Fonts.body(15),
            tabs: [
              Tab(text: l.recite),
              Tab(text: l.learn),
            ],
          ),
        ),
        body: const TabBarView(children: [_ReciteTab(), _LearnTab()]),
      ),
    );
  }
}

class _ReciteTab extends StatelessWidget {
  const _ReciteTab();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<RuqyahBloc>().state;
    final current = state.current;
    final entries = current.data;
    final programKey = 'ruqyah:${state.program.name}';
    final playing = context.watch<AudioCubit>().state == programKey;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.ruqyahSubtitle,
                  style: Fonts.body(13, color: Palette.inkSoft),
                ),
                const SizedBox(height: 14),
                SegmentedButton<RuqyahProgram>(
                  showSelectedIcon: false,
                  segments: [
                    for (final p in RuqyahProgram.values)
                      ButtonSegment(value: p, label: Text(p.title(l))),
                  ],
                  selected: {state.program},
                  onSelectionChanged: (s) => context.read<RuqyahBloc>().add(
                    RuqyahRecitationRequested(program: s.first),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Palette.green,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.read<AudioCubit>().toggle(
                      programKey,
                      state.program.audioUrl,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            playing
                                ? Icons.stop_circle_rounded
                                : Icons.play_circle_fill_rounded,
                            color: Palette.cream,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              playing ? l.playing : l.listenFull,
                              style: Fonts.body(
                                15,
                                color: Palette.cream,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<RuqyahSource>(
                        showSelectedIcon: false,
                        segments: [
                          for (final s in RuqyahSource.values)
                            ButtonSegment(value: s, label: Text(s.title(l))),
                        ],
                        selected: {state.source},
                        onSelectionChanged: (s) => context
                            .read<RuqyahBloc>()
                            .add(RuqyahRecitationRequested(source: s.first)),
                      ),
                    ),
                    if (entries != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        context.n(entries.length),
                        style: Fonts.mono(13, color: Palette.inkSoft),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (entries != null)
          SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (_, i) => _EntryCard(entry: entries[i]),
          )
        else
          SliverFillRemaining(
            hasScrollBody: false,
            child: current.error != null
                ? Center(
                    child: ErrorState(
                      error: current.error,
                      onRetry: () => context.read<RuqyahBloc>().add(
                        const RuqyahRecitationRequested(),
                      ),
                    ),
                  )
                : const Align(
                    alignment: Alignment.topCenter,
                    child: ListSkeleton(rows: 4, leading: 0),
                  ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _EntryCard extends StatefulWidget {
  const _EntryCard({required this.entry});

  final RuqyahEntry entry;

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final e = widget.entry;
    final translation = e.translation.trim() == e.arabic.trim()
        ? ''
        : e.translation;
    final translit = ar ? '' : e.transliteration;
    final hasMeaning = translation.isNotEmpty || translit.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Palette.greenSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    context.n(e.id),
                    style: Fonts.mono(11, color: Palette.green),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.title,
                    style: Fonts.body(14, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (e.introduction.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                e.introduction,
                style: Fonts.body(13, color: Palette.inkSoft),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              e.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: Fonts.arabic(23).copyWith(height: 2.1),
            ),
            if (hasMeaning) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(() => _open = !_open),
                  icon: Icon(
                    _open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  label: Text(
                    _open ? l.hideMeaning : l.showMeaning,
                    style: Fonts.body(13, color: Palette.clay),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.topCenter,
                child: !_open
                    ? const SizedBox(width: double.infinity)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (translit.isNotEmpty) ...[
                            Text(translit, style: Fonts.quote(15)),
                            const SizedBox(height: 10),
                          ],
                          if (translation.isNotEmpty)
                            Text(
                              translation,
                              style: Fonts.body(14).copyWith(height: 1.6),
                            ),
                        ],
                      ),
              ),
            ],
            if (e.reference.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(e.reference, style: Fonts.body(12, color: Palette.inkSoft)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LearnTab extends StatelessWidget {
  const _LearnTab();

  @override
  Widget build(BuildContext context) {
    final topics = context.select((RuqyahBloc b) => b.state.topics);
    final data = topics.data;

    if (data == null) {
      if (topics.error == null) {
        return const SingleChildScrollView(child: ListSkeleton());
      }
      return Center(
        child: ErrorState(
          error: topics.error,
          onRetry: () =>
              context.read<RuqyahBloc>().add(const RuqyahTopicsRequested()),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      itemCount: data.length,
      separatorBuilder: (_, _) => const RowDivider(indent: 72),
      itemBuilder: (context, i) {
        final t = data[i];
        return ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RuqyahTopicScreen(topic: t)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 2,
          ),
          leading: NumberBadge(i + 1),
          title: Text(t.title, style: Fonts.body(16, weight: FontWeight.w500)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.n(t.count),
                style: Fonts.mono(12, color: Palette.inkSoft),
              ),
              Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
            ],
          ),
        );
      },
    );
  }
}

class RuqyahTopicScreen extends StatefulWidget {
  const RuqyahTopicScreen({super.key, required this.topic});

  final RuqyahTopic topic;

  @override
  State<RuqyahTopicScreen> createState() => _RuqyahTopicScreenState();
}

class _RuqyahTopicScreenState extends State<RuqyahTopicScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RuqyahBloc>().add(RuqyahArticlesRequested(widget.topic.slug));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RuqyahBloc>().state;
    final articles =
        state.articles[widget.topic.slug] ?? const Loadable.loading();
    final data = articles.data;

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.title)),
      body: data == null
          ? articles.error != null
                ? Center(
                    child: ErrorState(
                      error: articles.error,
                      onRetry: () => context.read<RuqyahBloc>().add(
                        RuqyahArticlesRequested(widget.topic.slug),
                      ),
                    ),
                  )
                : const SingleChildScrollView(child: ListSkeleton(leading: 0))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
              itemCount: data.length,
              separatorBuilder: (_, _) => const RowDivider(),
              itemBuilder: (context, i) {
                final a = data[i];
                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RuqyahArticleScreen(article: a),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  title: Text(
                    a.sectionTitle.isNotEmpty ? a.sectionTitle : a.title,
                    style: Fonts.body(15, weight: FontWeight.w500),
                  ),
                  subtitle:
                      a.sectionTitle.isNotEmpty && a.sectionTitle != a.title
                      ? Text(
                          a.title,
                          style: Fonts.body(12.5, color: Palette.inkSoft),
                        )
                      : null,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Palette.inkSoft,
                  ),
                );
              },
            ),
    );
  }
}

class RuqyahArticleScreen extends StatelessWidget {
  const RuqyahArticleScreen({super.key, required this.article});

  final RuqyahArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
        children: [
          if (article.sectionTitle.isNotEmpty)
            Caption(article.sectionTitle, color: Palette.clay),
          const SizedBox(height: 6),
          Text(article.title, style: Fonts.display(26).copyWith(height: 1.25)),
          const SizedBox(height: 18),
          for (final b in article.blocks) _Block(block: b),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});

  final ArticleBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block.type) {
      BlockType.header => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(block.content, style: Fonts.display(20)),
      ),
      BlockType.arabic => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Palette.paperDeep,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          block.content,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: Fonts.arabic(21, color: Palette.green).copyWith(height: 2),
        ),
      ),
      BlockType.translation => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(block.content, style: Fonts.quote(16)),
      ),
      BlockType.transliteration =>
        context.isAr
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  block.content,
                  style: Fonts.body(14, color: Palette.inkSoft),
                ),
              ),
      BlockType.text => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(block.content, style: Fonts.body(15).copyWith(height: 1.7)),
      ),
    };
  }
}
