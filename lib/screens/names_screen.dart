import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_cubit.dart';
import '../bloc/names/names_bloc.dart';
import '../l10n/l10n.dart';
import '../services/names.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/share_card.dart';
import '../widgets/shimmer.dart';
import '../widgets/star_pattern.dart';

class NamesScreen extends StatelessWidget {
  const NamesScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: 'names'),
    builder: (_) => const NamesScreen(),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<NamesBloc>().state;
    final book = state.book;

    return Scaffold(
      appBar: AppBar(title: Text(l.namesTitle)),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (book != null && book.hadith.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Palette.paperDeep,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: Palette.brass,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(book.hadith, style: Fonts.quote(15)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  SearchField(
                    hint: l.namesSearch,
                    onChanged: (v) =>
                        context.read<NamesBloc>().add(NamesSearched(v)),
                  ),
                  if (state.status == NamesStatus.loading && book != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: Palette.clay,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (book == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: state.status == NamesStatus.failure
                  ? Center(
                      child: ErrorState(
                        error: state.error,
                        onRetry: () => context.read<NamesBloc>().add(
                          const NamesRequested(),
                        ),
                      ),
                    )
                  : const Align(
                      alignment: Alignment.topCenter,
                      child: ListSkeleton(leading: 40),
                    ),
            )
          else ...[
            if (state.status == NamesStatus.failure)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    context.error(state.error),
                    style: Fonts.body(12, color: Palette.clay),
                  ),
                ),
              ),
            SliverList.separated(
              itemCount: state.visible.length,
              separatorBuilder: (_, _) => const RowDivider(indent: 76),
              itemBuilder: (context, i) => _NameRow(name: state.visible[i]),
            ),
            if (state.visible.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    l.noMatch(state.query.trim()),
                    textAlign: TextAlign.center,
                    style: Fonts.body(14, color: Palette.inkSoft),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.name});

  final DivineName name;

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    return ListTile(
      onTap: () => showNameSheet(context, name),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: NumberBadge(name.number),
      title: ar
          ? Text(name.arabic, style: Fonts.arabic(22, color: Palette.green))
          : Text(
              name.transliteration,
              style: Fonts.body(16, weight: FontWeight.w500),
            ),
      subtitle: Text(
        name.translation,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Fonts.body(13, color: Palette.inkSoft),
      ),
      trailing: ar
          ? null
          : Text(
              name.arabic,
              textDirection: TextDirection.rtl,
              style: Fonts.arabic(24, color: Palette.green),
            ),
    );
  }
}

Future<void> showNameSheet(BuildContext context, DivineName name) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: context.read<AudioCubit>(),
      child: _NameSheet(name: name),
    ),
  );
}

class _NameSheet extends StatelessWidget {
  const _NameSheet({required this.name});

  final DivineName name;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final key = 'name:${name.number}';
    final playing = context.watch<AudioCubit>().isPlaying(key);
    final ar = context.isAr;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: StarPattern(color: Color(0x11000000), cell: 40),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${context.n(name.number)} / ${context.n(99)}',
                    textAlign: TextAlign.center,
                    style: Fonts.mono(12, color: Palette.inkSoft),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: Fonts.arabic(56, color: Palette.green),
                  ),
                  if (!ar)
                    Text(
                      name.transliteration,
                      textAlign: TextAlign.center,
                      style: Fonts.display(24),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    name.translation,
                    textAlign: TextAlign.center,
                    style: Fonts.quote(17),
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    name.meaning,
                    style: Fonts.body(15).copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => showShareCard(
                      context,
                      sheetTitle: l.shareName,
                      eyebrow: l.featNames,
                      arabic: name.arabic,
                      subtitle: ar ? null : name.transliteration,
                      meaning: name.translation,
                      description: name.meaning.isEmpty ? null : name.meaning,
                      citation: '${context.n(name.number)} / ${context.n(99)}',
                      allowHideMeaning: name.translation.isNotEmpty,
                    ),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l.shareImage),
                  ),
                  if (name.audioUrl != null) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => context.read<AudioCubit>().toggle(
                        key,
                        name.audioUrl!,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Palette.green,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(
                        playing ? Icons.stop_rounded : Icons.volume_up_rounded,
                      ),
                      label: Text(
                        playing ? l.stop : l.hearIt,
                        style: Fonts.body(
                          15,
                          color: Palette.cream,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
