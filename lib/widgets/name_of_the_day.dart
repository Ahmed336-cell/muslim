import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/names/names_bloc.dart';
import '../l10n/l10n.dart';
import '../screens/names_screen.dart';
import '../theme.dart';
import 'common.dart';
import 'share_card.dart';
import 'shimmer.dart';
import 'star_pattern.dart';

class NameOfTheDay extends StatelessWidget {
  const NameOfTheDay({super.key});

  @override
  Widget build(BuildContext context) {
    final book = context.select((NamesBloc b) => b.state.book);
    final loading = context.select(
      (NamesBloc b) =>
          b.state.status == NamesStatus.loading ||
          b.state.status == NamesStatus.initial,
    );
    if (book == null || book.names.isEmpty) {
      return loading
          ? const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SkeletonCard(),
            )
          : const SizedBox.shrink();
    }

    final l = context.l;
    final now = context.select((ClockCubit c) => c.state);
    final name = book.forDay(now);
    final ar = context.isAr;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => showNameSheet(context, name),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 4),
              child: Row(
                children: [
                  StarMark(size: 9, color: Palette.clay),
                  const SizedBox(width: 8),
                  Expanded(child: Caption(l.nameOfDay)),
                  Text(
                    context.n(name.number),
                    style: Fonts.mono(12, color: Palette.inkSoft),
                  ),
                  IconButton(
                    tooltip: l.shareImage,
                    onPressed: () => showShareCard(
                      context,
                      sheetTitle: l.shareName,
                      eyebrow: l.featNames,
                      arabic: name.arabic,
                      subtitle: ar ? null : name.transliteration,
                      meaning: name.translation,
                      description: name.meaning.isEmpty ? null : name.meaning,
                      citation:
                          '${context.n(name.number)} / ${context.n(99)}',
                      allowHideMeaning: name.translation.isNotEmpty,
                    ),
                    icon: Icon(
                      Icons.ios_share_rounded,
                      size: 20,
                      color: Palette.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!ar)
                          Text(name.transliteration, style: Fonts.display(24)),
                        Text(
                          name.translation,
                          style: ar
                              ? Fonts.body(15, color: Palette.ink)
                              : Fonts.body(13, color: Palette.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    name.arabic,
                    textDirection: TextDirection.rtl,
                    style: Fonts.arabic(38, color: Palette.green),
                  ),
                ],
              ),
            ),
            const Divider(),
            CardLink(
              label: l.allNames,
              onTap: () => Navigator.push(context, NamesScreen.route()),
            ),
          ],
        ),
      ),
    );
  }
}
