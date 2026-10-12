import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../bloc/hadith_saved_cubit.dart';
import '../l10n/l10n.dart';
import '../services/hadith.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';

/// Hadith collections: Nawawi's Forty, Forty Qudsi and Riyad as-Salihin.
class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const HadithScreen());

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String _query = '';
  Future<List<Hadith>>? _results;
  Timer? _debounce;

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = q.trim();
        _results = _query.length < 2
            ? null
            : context.read<HadithRepository>().search(_query);
      });
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
    final saved = context.watch<HadithSavedCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l.featHadith)),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SearchField(hint: l.hadithSearch, onChanged: _search),
          ),
          if (_results != null)
            FutureBuilder<List<Hadith>>(
              future: _results,
              builder: (context, snap) {
                final found = snap.data;
                if (found == null) return const ListSkeleton(rows: 3);
                if (found.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      l.hadithNoMatch(_query),
                      textAlign: TextAlign.center,
                      style: Fonts.body(14, color: Palette.inkSoft),
                    ),
                  );
                }
                return Column(
                  children: [for (final h in found) HadithCard(hadith: h)],
                );
              },
            )
          else ...[
            for (final book in HadithBook.values) _BookCard(book),
            if (saved.isNotEmpty) ...[
              const SizedBox(height: 8),
              SectionHeader('${l.hadithSaved} · ${context.n(saved.length)}'),
              _Saved(saved),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                l.hadithSource,
                textAlign: TextAlign.center,
                style: Fonts.body(12, color: Palette.inkSoft),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard(this.book);

  final HadithBook book;

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    return FutureBuilder<HadithCollection>(
      future: context.read<HadithRepository>().load(book),
      builder: (context, snap) {
        final c = snap.data;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: c == null
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => c.chapters.length > 1
                          ? _ChaptersScreen(c)
                          : _HadithListScreen(
                              title: c.title(lang),
                              hadiths: c.hadiths,
                            ),
                    ),
                  ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Palette.greenSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Palette.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: c == null
                      ? const Shimmer(child: SkeletonLines(lines: 2))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.title(lang),
                              style: Fonts.body(16, weight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${c.author(lang)} · '
                              '${context.l.hadithCount(context.n(c.hadiths.length))}',
                              style: Fonts.body(12.5, color: Palette.inkSoft),
                            ),
                          ],
                        ),
                ),
                Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Saved extends StatelessWidget {
  const _Saved(this.keys);

  final List<String> keys;

  Future<List<Hadith>> _load(HadithRepository repo) async {
    final found = <Hadith>[];
    for (final key in keys) {
      final [book, number] = key.split(':');
      final b = HadithBook.values.asNameMap()[book];
      if (b == null) continue;
      final c = await repo.load(b);
      for (final h in c.hadiths) {
        if ('${h.number}' == number) found.add(h);
      }
    }
    return found;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Hadith>>(
    future: _load(context.read<HadithRepository>()),
    builder: (context, snap) => snap.data == null
        ? const ListSkeleton(rows: 2)
        : Column(children: [for (final h in snap.data!) HadithCard(hadith: h)]),
  );
}

class _ChaptersScreen extends StatelessWidget {
  const _ChaptersScreen(this.collection);

  final HadithCollection collection;

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final ar = context.isAr;
    return Scaffold(
      appBar: AppBar(title: Text(collection.title(lang))),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        itemCount: collection.chapters.length,
        separatorBuilder: (_, _) => const RowDivider(indent: 72),
        itemBuilder: (context, i) {
          final ch = collection.chapters[i];
          final hadiths = collection.inChapter(ch.id);
          return ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    _HadithListScreen(title: ch.title(lang), hadiths: hadiths),
              ),
            ),
            leading: NumberBadge(i + 1),
            title: Text(
              ch.title(lang),
              style: ar
                  ? Fonts.arabic(17, color: Palette.ink)
                  : Fonts.body(15.5, weight: FontWeight.w500),
            ),
            subtitle: Text(
              context.l.hadithCount(context.n(hadiths.length)),
              style: Fonts.body(12.5, color: Palette.inkSoft),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
          );
        },
      ),
    );
  }
}

class _HadithListScreen extends StatelessWidget {
  const _HadithListScreen({required this.title, required this.hadiths});

  final String title;
  final List<Hadith> hadiths;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        title,
        maxLines: 2,
        style: Fonts.body(17, weight: FontWeight.w600),
      ),
    ),
    body: ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 32),
      itemCount: hadiths.length,
      itemBuilder: (_, i) => HadithCard(hadith: hadiths[i]),
    ),
  );
}

class HadithCard extends StatelessWidget {
  const HadithCard({super.key, required this.hadith});

  final Hadith hadith;

  String _text(BuildContext context) => [
    hadith.arabic,
    if (!context.isAr) '${hadith.narrator}\n${hadith.english}'.trim(),
  ].join('\n\n');

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final saved = context.select(
      (HadithSavedCubit c) => c.state.contains(hadith.key),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Caption(l.hadithNumber(context.n(hadith.number))),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: saved ? l.hadithUnsave : l.hadithSave,
                  onPressed: () =>
                      context.read<HadithSavedCubit>().toggle(hadith.key),
                  icon: Icon(
                    saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: Palette.green,
                    size: 21,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l.copy,
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _text(context)),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(l.copied)));
                  },
                  icon: Icon(
                    Icons.copy_rounded,
                    color: Palette.inkSoft,
                    size: 19,
                  ),
                ),
                Builder(
                  builder: (context) => IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: l.share,
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox?;
                      SharePlus.instance.share(
                        ShareParams(
                          text: _text(context),
                          sharePositionOrigin: box == null
                              ? null
                              : box.localToGlobal(Offset.zero) & box.size,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.ios_share_rounded,
                      color: Palette.inkSoft,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hadith.arabic,
              textDirection: TextDirection.rtl,
              style: Fonts.arabic(20, color: Palette.ink).copyWith(height: 1.9),
            ),
            if (!ar && hadith.english.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (hadith.narrator.isNotEmpty)
                Text(
                  hadith.narrator,
                  style: Fonts.body(
                    13.5,
                    weight: FontWeight.w600,
                    color: Palette.green,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                hadith.english,
                style: Fonts.body(14.5).copyWith(height: 1.55),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
