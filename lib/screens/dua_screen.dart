import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_cubit.dart';
import '../l10n/l10n.dart';
import '../services/duas.dart';
import '../theme.dart';
import '../widgets/star_pattern.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key, required this.dua});

  final Dua dua;

  static Route<void> route(Dua dua) =>
      MaterialPageRoute(builder: (_) => DuaScreen(dua: dua));

  /// Arabic UI shows the Arabic text only; the "translation" duplicates it.
  bool _showTranslation(BuildContext context) =>
      dua.translation.isNotEmpty && dua.translation.trim() != dua.arabic.trim();

  void _copy(BuildContext context) {
    final ar = context.isAr;
    Clipboard.setData(
      ClipboardData(
        text: [
          dua.arabic,
          if (!ar) dua.transliteration,
          if (_showTranslation(context)) dua.translation,
          if (dua.reference.isNotEmpty) '— ${dua.reference}',
        ].where((s) => s.isNotEmpty).join('\n\n'),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l.copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final key = 'dua:${dua.id}';
    final playing = context.watch<AudioCubit>().state == key;

    return PopScope(
      onPopInvokedWithResult: (_, _) {
        if (playing) context.read<AudioCubit>().stop();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              tooltip: l.copy,
              onPressed: () => _copy(context),
              icon: const Icon(Icons.copy_rounded, size: 22),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    dua.title,
                    style: Fonts.display(26).copyWith(height: 1.25),
                  ),
                  if (dua.introduction.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      dua.introduction,
                      style: Fonts.body(14, color: Palette.inkSoft),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Palette.paperDeep,
                borderRadius: BorderRadius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: StarPattern(color: Color(0x0D000000), cell: 44),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          dua.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: Fonts.arabic(26).copyWith(height: 2),
                        ),
                        if (dua.audioUrl != null) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: FilledButton.tonalIcon(
                              onPressed: () => context
                                  .read<AudioCubit>()
                                  .toggle(key, dua.audioUrl!),
                              style: FilledButton.styleFrom(
                                backgroundColor: Palette.card,
                                foregroundColor: Palette.green,
                                minimumSize: const Size(140, 44),
                              ),
                              icon: Icon(
                                playing
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(
                                playing ? l.stop : l.listen,
                                style: Fonts.body(
                                  14,
                                  color: Palette.green,
                                  weight: FontWeight.w600,
                                ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!ar && dua.transliteration.isNotEmpty) ...[
                    Text(dua.transliteration, style: Fonts.quote(16)),
                    const SizedBox(height: 14),
                  ],
                  if (_showTranslation(context))
                    Text(
                      dua.translation,
                      style: Fonts.body(16).copyWith(height: 1.65),
                    ),
                  if (dua.reference.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      dua.reference,
                      style: Fonts.body(12.5, color: Palette.inkSoft),
                    ),
                  ],
                  const SizedBox(height: 18),
                  for (final (note, ordered) in [
                    (dua.hadith, false),
                    (dua.benefits, false),
                    (dua.whenToRecite, false),
                    (dua.howToPerform, true),
                  ])
                    if (note != null) _NoteTile(note: note, ordered: ordered),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.ordered});

  final DuaNote note;
  final bool ordered;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Palette.rule, width: .7)),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 16),
          iconColor: Palette.ink,
          collapsedIconColor: Palette.inkSoft,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          title: Text(
            note.title,
            style: Fonts.body(15, weight: FontWeight.w500),
          ),
          children: [
            if (note.arabic.isNotEmpty) ...[
              Text(
                note.arabic,
                textDirection: TextDirection.rtl,
                style: Fonts.arabic(17, color: Palette.inkSoft),
              ),
              const SizedBox(height: 8),
            ],
            if (note.description.isNotEmpty)
              Text(
                note.description,
                style: Fonts.body(14).copyWith(height: 1.6),
              ),
            for (final (i, item) in note.items.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: ordered
                          ? Text(
                              '${context.n(i + 1)}.',
                              style: Fonts.mono(12, color: Palette.clay),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(top: 7),
                              child: StarMark(size: 6, color: Palette.clay),
                            ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: Fonts.body(14).copyWith(height: 1.55),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
