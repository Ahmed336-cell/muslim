import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/duas/dua_library_bloc.dart';
import '../l10n/l10n.dart';
import '../services/duas.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';
import '../widgets/star_pattern.dart';
import 'dua_screen.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const DuasScreen());

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DuaLibraryBloc>().add(const DuaLibraryRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<DuaLibraryBloc>().state;
    final library = state.library;

    return Scaffold(
      appBar: AppBar(title: Text(l.duasTitle)),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    library == null
                        ? l.duasSubtitle
                        : l.duasCount(
                            context.n(library.duas.length),
                            context.n(library.categories.length),
                          ),
                    style: Fonts.body(13, color: Palette.inkSoft),
                  ),
                  const SizedBox(height: 12),
                  SearchField(
                    enabled: library != null,
                    hint: l.duasSearch,
                    onChanged: (v) =>
                        context.read<DuaLibraryBloc>().add(DuaSearched(v)),
                  ),
                  if (state.status == DuaLibraryStatus.loading &&
                      library != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: Palette.clay,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  if (state.status == DuaLibraryStatus.failure &&
                      library != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        context.error(state.error),
                        style: Fonts.body(12, color: Palette.clay),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (library == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: state.status == DuaLibraryStatus.failure
                  ? Center(
                      child: ErrorState(
                        error: state.error,
                        onRetry: () => context.read<DuaLibraryBloc>().add(
                          const DuaLibraryRequested(force: true),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l.duasLoading,
                            style: Fonts.body(13, color: Palette.inkSoft),
                          ),
                        ),
                        const ListSkeleton(),
                      ],
                    ),
            )
          else if (state.searching) ...[
            SliverList.separated(
              itemCount: state.results.length,
              separatorBuilder: (_, _) => const RowDivider(),
              itemBuilder: (_, i) => DuaTile(dua: state.results[i]),
            ),
            if (state.results.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    l.noDuaMatch(state.query.trim()),
                    textAlign: TextAlign.center,
                    style: Fonts.body(14, color: Palette.inkSoft),
                  ),
                ),
              ),
          ] else
            SliverList.separated(
              itemCount: library.categories.length,
              separatorBuilder: (_, _) => const RowDivider(indent: 72),
              itemBuilder: (_, i) => _CategoryRow(
                category: library.categories[i],
                library: library,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.library});

  final DuaCategory category;
  final DuaLibrary library;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final sections = library.sectionsOf(category.slug).length;
    final duas = library.duaCountOf(category.slug);

    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DuaCategoryScreen(category: category),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Palette.greenSoft,
          shape: BoxShape.circle,
        ),
        child: const Center(child: StarMark(size: 14, color: Palette.green)),
      ),
      title: Text(
        category.name,
        style: Fonts.body(16, weight: FontWeight.w500),
      ),
      subtitle: Text(
        context.n(
          [
            l.duaCount(duas),
            if (sections > 1) l.sectionCount(sections),
          ].join('  ·  '),
        ),
        style: Fonts.body(12.5, color: Palette.inkSoft),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
    );
  }
}

class DuaCategoryScreen extends StatelessWidget {
  const DuaCategoryScreen({super.key, required this.category});

  final DuaCategory category;

  @override
  Widget build(BuildContext context) {
    final library = context.select((DuaLibraryBloc b) => b.state.library);
    if (library == null) return const Scaffold();
    final sections = library.sectionsOf(category.slug);

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: CustomScrollView(
        slivers: [
          for (final s in sections) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: StarMark(size: 8, color: Palette.clay),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.title,
                        style: Fonts.body(
                          14,
                          color: Palette.inkSoft,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final (i, d) in library.duasIn(s).indexed) ...[
                      if (i > 0) const RowDivider(indent: 16),
                      DuaTile(dua: d),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class DuaTile extends StatelessWidget {
  const DuaTile({super.key, required this.dua});

  final Dua dua;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, DuaScreen.route(dua)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    dua.title,
                    style: Fonts.body(15, weight: FontWeight.w500),
                  ),
                  if (dua.arabic.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      dua.arabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: Fonts.arabic(17, color: Palette.green),
                    ),
                  ],
                  if (dua.reference.isNotEmpty)
                    Text(
                      dua.reference,
                      style: Fonts.body(11.5, color: Palette.inkSoft),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
          ],
        ),
      ),
    );
  }
}
