import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/downloads_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../bloc/tawashih/recent_tawashih_cubit.dart';
import '../bloc/tawashih/tawashih_tracks_cubit.dart';
import '../l10n/l10n.dart';
import '../services/tawashih.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/gramophone_disc.dart';
import '../widgets/listen_style.dart';
import '../widgets/mini_player.dart';
import '../widgets/reciter_art.dart';
import '../widgets/shimmer.dart';

ThemeData _darkTheme(BuildContext context) => Theme.of(context).copyWith(
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
    titleTextStyle: Fonts.body(18, color: Listen.text, weight: FontWeight.w700),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  iconTheme: IconThemeData(color: Listen.text),
);

void _openMunshid(BuildContext context, TawashihMunshid m) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TawashihMunshidScreen(munshid: m),
      ),
    );

/// Tawashih home — same layout and behaviour as [RecitersScreen].
class TawashihScreen extends StatefulWidget {
  const TawashihScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: 'tawashih'),
    builder: (_) => const TawashihScreen(),
  );

  @override
  State<TawashihScreen> createState() => _TawashihScreenState();
}

class _TawashihScreenState extends State<TawashihScreen> {
  bool _searching = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lang = context.lang;
    final all = tawashihMunshids;

    return Theme(
      data: _darkTheme(context),
      child: Scaffold(
        appBar: AppBar(
          title: _searching
              ? TextField(
                  autofocus: true,
                  cursorColor: Listen.accent,
                  style: Fonts.body(16, color: Palette.ink),
                  decoration: InputDecoration(
                    hintText: l.recitersSearch,
                    hintStyle: Fonts.body(16, color: Palette.inkSoft),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                )
              : Text(
                  l.featTawashih,
                  style: Fonts.display(24, color: Listen.text),
                ),
          actions: [
            IconButton(
              tooltip: l.searchTip,
              icon: Icon(
                _searching ? Icons.close_rounded : Icons.search_rounded,
              ),
              onPressed: () => setState(() {
                _searching = !_searching;
                _query = '';
              }),
            ),
          ],
        ),
        bottomNavigationBar: const MiniPlayer(),
        body: _searching
            ? _Results(munshids: all, query: _query, lang: lang)
            : _Home(munshids: all, lang: lang),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.munshids, required this.lang});

  final List<TawashihMunshid> munshids;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final byId = {for (final m in munshids) m.id: m};
    final recentIds = context.watch<RecentTawashihCubit>().state;
    final recent = [for (final id in recentIds) ?byId[id]];
    final popular = [for (final id in popularTawashih) ?byId[id]];

    return CustomScrollView(
      slivers: [
        if (recent.isNotEmpty) ...[
          _Heading(l.recentlyPlayed),
          SliverToBoxAdapter(
            child: _Shelf(
              height: 204,
              children: [
                for (final m in recent)
                  _Card(munshid: m, size: 140, circle: false, lang: lang),
              ],
            ),
          ),
        ],
        if (popular.isNotEmpty) ...[
          _Heading(l.popularMunshids),
          SliverToBoxAdapter(
            child: _Shelf(
              height: 192,
              children: [
                for (final m in popular)
                  _Card(munshid: m, size: 124, circle: true, lang: lang),
              ],
            ),
          ),
        ],
        _Heading(l.allMunshids),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 130,
              mainAxisExtent: 168,
              crossAxisSpacing: 4,
            ),
            itemCount: munshids.length,
            itemBuilder: (context, i) =>
                _Card(munshid: munshids[i], size: 96, circle: true, lang: lang),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.munshids,
    required this.query,
    required this.lang,
  });

  final List<TawashihMunshid> munshids;
  final String query;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final shown = [
      for (final m in munshids)
        if (q.isEmpty ||
            m.nameAr.contains(query.trim()) ||
            m.nameEn.toLowerCase().contains(q))
          m,
    ];
    if (shown.isEmpty) {
      return Center(
        child: Text(
          context.l.noMatch(query.trim()),
          style: Fonts.body(14, color: Listen.textSoft),
        ),
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: shown.length,
      itemBuilder: (context, i) {
        final m = shown[i];
        return ListTile(
          onTap: () => _openMunshid(context, m),
          leading: ReciterArt(name: m.name(lang), size: 48, circle: true),
          title: Text(
            m.name(lang),
            style: Fonts.body(15, color: Listen.text, weight: FontWeight.w600),
          ),
        );
      },
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Text(
        text,
        style: Fonts.body(21, color: Listen.text, weight: FontWeight.w800),
      ),
    ),
  );
}

class _Shelf extends StatelessWidget {
  const _Shelf({required this.height, required this.children});

  final double height;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: 4),
      itemBuilder: (_, i) => children[i],
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.munshid,
    required this.size,
    required this.circle,
    required this.lang,
  });

  final TawashihMunshid munshid;
  final double size;
  final bool circle;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final name = munshid.name(lang);
    final recId = tawashihRecordingId(munshid.id);
    final playing = context.select(
      (RecitationCubit c) =>
          c.state.playing &&
          c.state.kind == RecitationKind.tawashih &&
          c.state.recording == recId,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openMunshid(context, munshid),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: size,
          child: Column(
            children: [
              ReciterArt(name: name, size: size, circle: circle),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: circle
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (playing) ...[
                    Icon(
                      Icons.graphic_eq_rounded,
                      size: 15,
                      color: Listen.accent,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: circle ? TextAlign.center : TextAlign.start,
                      style: Fonts.body(
                        13,
                        color: playing ? Listen.accent : Listen.text,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One munshid — same pattern as [ReciterScreen].
class TawashihMunshidScreen extends StatelessWidget {
  const TawashihMunshidScreen({super.key, required this.munshid});

  final TawashihMunshid munshid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TawashihTracksCubit(api: TawashihApi(), munshid: munshid),
      child: _MunshidBody(munshid: munshid),
    );
  }
}

class _MunshidBody extends StatelessWidget {
  const _MunshidBody({required this.munshid});

  final TawashihMunshid munshid;

  int get _recId => tawashihRecordingId(munshid.id);

  Future<void> _play(BuildContext context, int index) async {
    final tracks = context.read<TawashihTracksCubit>().state.tracks;
    if (tracks == null || tracks.isEmpty) return;
    final lang = context.lang;
    final recent = context.read<RecentTawashihCubit>();
    final downloads = context.read<DownloadsCubit>();
    final recitation = context.read<RecitationCubit>();
    recent.played(munshid.id);
    final local = await downloads.local(_recId);
    await recitation.playTawashih(
      recording: _recId,
      artist: munshid.name(lang),
      tracks: [
        for (final t in tracks)
          (id: t.id, uri: munshid.urlFor(t), title: t.title(lang)),
      ],
      index: index,
      local: local,
    );
  }

  Future<void> _download(BuildContext context, int trackNo) async {
    final tracks = context.read<TawashihTracksCubit>().state.tracks;
    if (tracks == null || trackNo < 1 || trackNo > tracks.length) return;
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l.downloadFailed;
    final t = tracks[trackNo - 1];
    final ok = await context.read<DownloadsCubit>().downloadUrl(
      _recId,
      trackNo,
      munshid.urlFor(t),
    );
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lang = context.lang;
    final name = munshid.name(lang);
    final (light, _) = coverColors(name);
    final s = context.watch<TawashihTracksCubit>().state;
    final rec = context.watch<RecitationCubit>().state;
    final thisPlaying =
        rec.kind == RecitationKind.tawashih && rec.recording == _recId;

    return Theme(
      data: _darkTheme(context),
      child: Scaffold(
        bottomNavigationBar: const MiniPlayer(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 300,
              backgroundColor: Color.alphaBlend(
                Colors.black.withValues(alpha: .35),
                light,
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.fromSTEB(
                  56,
                  0,
                  16,
                  14,
                ),
                title: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Fonts.body(
                    20,
                    color: Listen.text,
                    weight: FontWeight.w800,
                  ),
                ),
                background: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [light, Listen.bg],
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .4),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: thisPlaying
                            ? GramophoneDisc(
                                name: name,
                                spinning: rec.playing,
                                size: 170,
                              )
                            : ReciterArt(name: name, size: 170, circle: true),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (s.error != null)
              SliverFillRemaining(
                child: Center(
                  child: ErrorState(
                    error: s.error,
                    onRetry: context.read<TawashihTracksCubit>().load,
                  ),
                ),
              )
            else if (s.tracks == null)
              const SliverToBoxAdapter(
                child: ListSkeleton(
                  rows: 10,
                  leading: 34,
                  tone: ShimmerTone.listen,
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.trackCount(context.n('${s.tracks!.length}')),
                          style: Fonts.body(12.5, color: Listen.textSoft),
                        ),
                      ),
                      SizedBox.square(
                        dimension: 58,
                        child: Material(
                          color: Listen.accent,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: IconButton(
                            tooltip: thisPlaying && rec.playing
                                ? l.pauseTip
                                : l.playAll,
                            iconSize: 34,
                            color: Listen.bg,
                            icon: Icon(
                              thisPlaying && rec.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                            onPressed: thisPlaying
                                ? context.read<RecitationCubit>().toggle
                                : () => _play(context, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: s.tracks!.length,
                itemBuilder: (context, i) => _TrackRow(
                  index: i + 1,
                  recording: _recId,
                  track: s.tracks![i],
                  lang: lang,
                  onPlay: (n) => _play(context, n - 1),
                  onDownload: (n) => _download(context, n),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.index,
    required this.recording,
    required this.track,
    required this.lang,
    required this.onPlay,
    required this.onDownload,
  });

  final int index;
  final int recording;
  final TawashihTrack track;
  final String lang;
  final ValueChanged<int> onPlay;
  final ValueChanged<int> onDownload;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final key = (recording, index);
    final (current, playing) = context.select((RecitationCubit c) {
      final st = c.state;
      final here =
          st.kind == RecitationKind.tawashih &&
          st.recording == recording &&
          st.current?.surah == index;
      return (here, here && st.playing);
    });
    final saved = context.select(
      (DownloadsCubit c) => c.state.saved.contains(key),
    );
    final progress = context.select(
      (DownloadsCubit c) => c.state.progress[key],
    );

    final Widget download;
    if (progress != null) {
      download = Padding(
        padding: const EdgeInsets.all(13),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            value: progress == 0 ? null : progress,
            strokeWidth: 2.2,
            color: Listen.accent,
            backgroundColor: Listen.textFaint,
          ),
        ),
      );
    } else if (saved) {
      download = IconButton(
        tooltip: l.removeDownload,
        icon: Icon(Icons.download_done_rounded, color: Listen.accent),
        onPressed: () =>
            context.read<DownloadsCubit>().delete(recording, index),
      );
    } else {
      download = IconButton(
        tooltip: l.download,
        icon: Icon(Icons.arrow_circle_down_rounded, color: Listen.textSoft),
        onPressed: () => onDownload(index),
      );
    }

    return InkWell(
      onTap: current
          ? context.read<RecitationCubit>().toggle
          : () => onPlay(index),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 8),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: current
                  ? Icon(
                      playing ? Icons.graphic_eq_rounded : Icons.pause_rounded,
                      size: 20,
                      color: Listen.accent,
                    )
                  : Text(
                      context.n('$index'),
                      textAlign: TextAlign.center,
                      style: Fonts.body(14, color: Listen.textSoft),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Fonts.body(
                      15.5,
                      color: current ? Listen.accent : Listen.text,
                      weight: FontWeight.w600,
                    ),
                  ),
                  if (saved)
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_circle_down_rounded,
                          size: 14,
                          color: Listen.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l.download,
                          style: Fonts.body(12.5, color: Listen.textSoft),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            download,
          ],
        ),
      ),
    );
  }
}
