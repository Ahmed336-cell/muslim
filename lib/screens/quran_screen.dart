import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/recent_surahs_cubit.dart';
import '../bloc/quran_bookmark_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/mushaf_pages.dart';
import '../services/quran_text.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mini_player.dart';
import '../widgets/shimmer.dart';
import '../widgets/star_pattern.dart';
import 'khatmah_screen.dart';
import 'mushaf_screen.dart';
import 'reciters_screen.dart';

String _westernDigits(String s) => s.replaceAllMapped(
  RegExp('[٠-٩]'),
  (m) => '${m[0]!.codeUnitAt(0) - 0x0660}',
);

final _arabic = RegExp('[\u0621-\u064A]');

/// "2:255" or "2 255" as (surah, ayah), when both exist.
(int, int)? _reference(String q) {
  final m = RegExp(r'^(\d{1,3})\s*[:.\s]\s*(\d{1,3})$').firstMatch(q);
  if (m == null) return null;
  final s = int.parse(m[1]!), a = int.parse(m[2]!);
  if (s < 1 || s > 114 || a < 1 || a > surahs[s - 1].ayahs) return null;
  return (s, a);
}

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const QuranScreen());

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _query = '';
  bool _byJuz = false;

  bool _matches(Surah s, String q) =>
      q.isEmpty ||
      '${s.number}' == q ||
      s.arabic.contains(q) ||
      s.name.toLowerCase().contains(q) ||
      s.meaning.toLowerCase().contains(q);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final q = _westernDigits(_query.trim().toLowerCase());
    final bookmark = context.watch<QuranBookmarkCubit>().state;
    final recent = context.watch<RecentSurahsCubit>().state;

    final rows = <Widget>[];
    if (_byJuz) {
      for (var j = 1; j <= 30; j++) {
        final inJuz = [
          for (final (s, from) in surahsInJuz(j))
            if (_matches(surahs[s - 1], q)) (surahs[s - 1], from),
        ];
        if (inJuz.isEmpty) continue;
        rows.add(_JuzHeader(juz: j));
        for (final (s, from) in inJuz) {
          rows.add(_SurahRow(surah: s, fromAyah: from));
        }
      }
    } else {
      rows.addAll([
        for (final s in surahs)
          if (_matches(s, q)) _SurahRow(surah: s),
      ]);
    }
    if (_reference(q) case (final s, final a)) {
      rows.insert(0, _ReferenceRow(surah: surahs[s - 1], ayah: a));
    }
    final searchAyahs = _arabic.hasMatch(q) && q.length >= 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.quranTitle),
        actions: [
          IconButton(
            tooltip: l.featReciters,
            icon: const Icon(Icons.headphones_rounded),
            onPressed: () => Navigator.of(context).push(RecitersScreen.route()),
          ),
          IconButton(
            tooltip: l.readingSettings,
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => showReadingSettings(context),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
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
                child: _LastRead(
                  surah: surahs[bookmark.surah - 1],
                  ayah: bookmark.ayah,
                ),
              ),
            ),
          if (q.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: KhatmahCard(),
              ),
            ),
          if (recent.isNotEmpty && q.isEmpty)
            SliverToBoxAdapter(child: _Recent(recent: recent)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.format_list_numbered_rounded),
                    label: Text(l.viewSurahs),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: Text(l.viewJuz),
                  ),
                ],
                selected: {_byJuz},
                onSelectionChanged: (v) => setState(() => _byJuz = v.first),
              ),
            ),
          ),
          SliverList.list(children: rows),
          if (searchAyahs) _AyahResults(query: q),
          if (rows.isEmpty && !searchAyahs)
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

class _Recent extends StatelessWidget {
  const _Recent({required this.recent});

  final List<(int, int)> recent;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: SectionHeader(l.recentlyRead),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final (i, (s, page)) in recent.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: AppCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MushafScreen(page: page),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahs[s - 1].arabic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Fonts.arabic(
                            20,
                            color: Palette.green,
                          ).copyWith(height: 1.6),
                        ),
                        if (!context.isAr)
                          Text(
                            surahs[s - 1].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Fonts.body(13, weight: FontWeight.w500),
                          ),
                        Text(
                          l.pageN(context.n(page)),
                          style: Fonts.body(12, color: Palette.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              for (var i = recent.length; i < RecentSurahsCubit.limit; i++) ...[
                const SizedBox(width: 10),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _JuzHeader extends StatelessWidget {
  const _JuzHeader({required this.juz});

  final int juz;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final (s, a) = juzStarts[juz - 1];
    return Material(
      color: Palette.paperDeep,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MushafScreen.route(s, ayah: a)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.isAr
                      ? 'الجزء ${juzOrdinalsAr[juz - 1]}'
                      : l.juzN('$juz'),
                  style: Fonts.display(17, color: Palette.green),
                ),
              ),
              Text(
                l.pageN(context.n(pageOf(s, a))),
                style: Fonts.body(12.5, color: Palette.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastRead extends StatelessWidget {
  const _LastRead({required this.surah, required this.ayah});

  final Surah surah;
  final int ayah;

  /// Stays dark in both themes. [Palette.ink] flips to near-white in dark
  /// mode and washes out the cream text.
  static const _fill = Color(0xFF1F2A24);
  static const _brass = Color(0xFFB0812F);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AppCard(
      color: _fill,
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(
        context,
      ).push(MushafScreen.route(surah.number, ayah: ayah, highlight: true)),
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
                const Icon(Icons.bookmark_rounded, color: _brass),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Caption(l.lastRead, color: _brass),
                      const SizedBox(height: 4),
                      Text(
                        context.isAr ? surah.arabic : surah.name,
                        style: Fonts.display(24, color: Palette.cream),
                      ),
                      Text(
                        l.ayahOf(context.n(ayah), context.n(surah.ayahs)),
                        style: Fonts.body(
                          13,
                          color: Palette.cream.withValues(alpha: .6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!context.isAr)
                  Text(
                    surah.arabic,
                    style: Fonts.arabic(26, color: _brass),
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
  const _SurahRow({required this.surah, this.fromAyah = 1});

  final Surah surah;

  /// Where the surah enters a juz, when listed by juz.
  final int fromAyah;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final details = [
      if (fromAyah > 1) l.fromAyah(context.n(fromAyah)),
      if (!ar && fromAyah == 1) surah.meaning,
      context.n(l.ayahCount(surah.ayahs)),
      surah.meccan ? l.meccan : l.medinan,
    ].join('  ·  ');

    return ListTile(
      onTap: () => Navigator.of(
        context,
      ).push(MushafScreen.route(surah.number, ayah: fromAyah)),
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

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({required this.surah, required this.ayah});

  final Surah surah;
  final int ayah;

  @override
  Widget build(BuildContext context) {
    final name = context.isAr ? 'سورة ${surah.arabic}' : surah.name;
    return ListTile(
      onTap: () => Navigator.of(
        context,
      ).push(MushafScreen.route(surah.number, ayah: ayah, highlight: true)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.subdirectory_arrow_right_rounded,
        color: Palette.green,
      ),
      title: Text(
        context.l.goToAyah(name, context.n(ayah)),
        style: Fonts.body(16, weight: FontWeight.w600, color: Palette.green),
      ),
    );
  }
}

/// Ayahs containing the query, searched in the bundled text.
class _AyahResults extends StatefulWidget {
  const _AyahResults({required this.query});

  final String query;

  @override
  State<_AyahResults> createState() => _AyahResultsState();
}

class _AyahResultsState extends State<_AyahResults> {
  Timer? _debounce;
  QuranSearch? _result;
  String? _for;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(_AyahResults old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query) _schedule();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final query = widget.query;
      final result = await context.read<QuranText>().search(query);
      if (mounted && query == widget.query) {
        setState(() {
          _result = result;
          _for = query;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final result = _result;
    if (result == null || _for != widget.query) {
      return const SliverToBoxAdapter(child: ListSkeleton(rows: 3));
    }
    return SliverList.list(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            context.n(l.ayahMatches(result.total)),
            style: Fonts.body(
              13,
              color: Palette.inkSoft,
              weight: FontWeight.w600,
            ),
          ),
        ),
        if (result.total == 0)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              l.noMatch(widget.query),
              textAlign: TextAlign.center,
              style: Fonts.body(14, color: Palette.inkSoft),
            ),
          ),
        for (final m in result.matches) _AyahMatchRow(match: m),
        if (result.total > result.matches.length)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              l.ayahMatchesMore(context.n(result.matches.length)),
              textAlign: TextAlign.center,
              style: Fonts.body(12.5, color: Palette.inkSoft),
            ),
          ),
      ],
    );
  }
}

class _AyahMatchRow extends StatelessWidget {
  const _AyahMatchRow({required this.match});

  final QuranMatch match;

  @override
  Widget build(BuildContext context) {
    final a = match.ayah;
    final surah = surahs[a.surah - 1];
    final text = a.text;
    final end = (match.start + match.length).clamp(0, text.length);
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MushafScreen.route(a.surah, ayah: a.number, highlight: true)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${context.isAr ? 'سورة ${surah.arabic}' : surah.name} · '
              '${context.n('${a.surah}:${a.number}')}',
              style: Fonts.body(
                12.5,
                color: Palette.green,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                style: Fonts.arabic(19, color: Palette.ink),
                children: [
                  TextSpan(text: text.substring(0, match.start)),
                  TextSpan(
                    text: text.substring(match.start, end),
                    style: TextStyle(
                      color: Palette.clay,
                      backgroundColor: Palette.clay.withValues(alpha: .12),
                    ),
                  ),
                  TextSpan(text: text.substring(end)),
                ],
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
