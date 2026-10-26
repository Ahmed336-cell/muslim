import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/tafsir.dart';
import '../theme.dart';
import '../widgets/listen_style.dart';
import '../widgets/mini_player.dart';
import '../widgets/shimmer.dart';

/// Spoken tafsir, grouped by surah. Playback goes through the shared player.
class TafsirScreen extends StatefulWidget {
  const TafsirScreen({super.key, this.api});

  final TafsirApi? api;

  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: 'tafsir'),
    builder: (_) => const TafsirScreen(),
  );

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  late final TafsirApi _api = widget.api ?? TafsirApi();
  late Future<TafsirBook> _load;
  var _started = false;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load = _api.fetch(Localizations.localeOf(context).languageCode);
  }

  void _retry() => setState(() {
    _load = _api.fetch(Localizations.localeOf(context).languageCode);
  });

  Future<void> _play(TafsirBook book, TafsirTrack track) async {
    final cubit = context.read<RecitationCubit>();
    final current = cubit.state;
    final on =
        current.kind == RecitationKind.tafsir &&
        current.current?.id == 'tafsir:${track.id}';
    if (on) {
      await cubit.toggle();
      return;
    }
    unawaited(context.read<AudioCubit>().stop());
    final index = book.tracks.indexWhere((t) => t.id == track.id);
    await cubit.playTafsir(
      book: book.name,
      tracks: book.tracks,
      index: index < 0 ? 0 : index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Theme(
      data: _dark(context),
      child: Scaffold(
        backgroundColor: Listen.bg,
        appBar: AppBar(
          title: Text(
            l.featTafsir,
            style: Fonts.display(22, color: Listen.text),
          ),
        ),
        bottomNavigationBar: const MiniPlayer(),
        body: FutureBuilder<TafsirBook>(
          future: _load,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const _TafsirSkeleton();
            }
            if (snap.hasError || snap.data == null) {
              return _Error(
                message: context.error('${snap.error}'),
                onRetry: _retry,
              );
            }
            final book = snap.data!;
            final groups = _filter(context, book.tracks);
            return Column(
              children: [
                if (book.name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        book.name,
                        style: Fonts.body(14, color: Listen.gold),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v.trim()),
                    style: Fonts.body(15, color: Listen.text),
                    decoration: InputDecoration(
                      hintText: l.searchTip,
                      hintStyle: Fonts.body(15, color: Listen.textSoft),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Listen.textSoft,
                      ),
                      filled: true,
                      fillColor: Listen.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: groups.isEmpty
                      ? Center(
                          child: Text(
                            l.noMatch(_query),
                            style: Fonts.body(15, color: Listen.textSoft),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: groups.length,
                          itemBuilder: (context, i) => _SurahBlock(
                            group: groups[i],
                            onPlay: (track) => _play(book, track),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<TafsirSurah> _filter(BuildContext context, List<TafsirTrack> tracks) {
    final q = _query.toLowerCase();
    if (q.isEmpty) return groupTafsir(tracks);
    return groupTafsir([
      for (final track in tracks)
        if (track.name.toLowerCase().contains(q) ||
            _surahLabel(context, track.surah).toLowerCase().contains(q))
          track,
    ]);
  }
}

class _SurahBlock extends StatelessWidget {
  const _SurahBlock({required this.group, required this.onPlay});

  final TafsirSurah group;
  final ValueChanged<TafsirTrack> onPlay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            _surahLabel(context, group.number),
            style: Fonts.display(18, color: Listen.gold),
          ),
        ),
        for (final track in group.tracks)
          _TrackTile(track: track, onTap: () => onPlay(track)),
      ],
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.track, required this.onTap});

  final TafsirTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecitationCubit, RecitationState>(
      builder: (context, state) {
        final on =
            state.kind == RecitationKind.tafsir &&
            state.current?.id == 'tafsir:${track.id}';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Material(
            color: on ? Listen.surfaceHi : Listen.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        track.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Fonts.body(
                          15,
                          color: Listen.text,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      on && state.playing
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                      color: Listen.gold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Fonts.body(15, color: Listen.textSoft),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(context.l.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _TafsirSkeleton extends StatelessWidget {
  const _TafsirSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      tone: ShimmerTone.listen,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: const [
          _SkeletonGroup(titleWidth: 90, rows: 2),
          _SkeletonGroup(titleWidth: 120, rows: 3),
          _SkeletonGroup(titleWidth: 80, rows: 2),
          _SkeletonGroup(titleWidth: 140, rows: 2),
        ],
      ),
    );
  }
}

class _SkeletonGroup extends StatelessWidget {
  const _SkeletonGroup({required this.titleWidth, required this.rows});

  final double titleWidth;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Bone(width: titleWidth, height: 18, radius: 8),
        ),
        for (var i = 0; i < rows; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: SizedBox(
              width: double.infinity,
              child: Bone(height: 44, radius: 16),
            ),
          ),
      ],
    );
  }
}

ThemeData _dark(BuildContext context) => Theme.of(context).copyWith(
  scaffoldBackgroundColor: Listen.bg,
  colorScheme: Theme.of(context).colorScheme.copyWith(
    brightness: Brightness.dark,
    surface: Listen.bg,
    onSurface: Listen.text,
    primary: Listen.accent,
  ),
  appBarTheme: Theme.of(context).appBarTheme.copyWith(
    backgroundColor: Listen.bg,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Listen.text,
  ),
  iconTheme: IconThemeData(color: Listen.text),
);

String _surahLabel(BuildContext context, int number) {
  if (number >= 1 && number <= surahs.length) {
    final s = surahs[number - 1];
    return context.isAr ? s.arabic : s.name;
  }
  return '$number';
}
