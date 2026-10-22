import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/downloads_cubit.dart';
import '../bloc/quran/recent_reciters_cubit.dart';
import '../bloc/quran/reciters_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/recitation.dart';
import '../services/reciter_photos.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';
import '../widgets/listen_style.dart';
import '../widgets/mini_player.dart';
import '../widgets/reciter_art.dart';

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

void _openReciter(BuildContext context, Reciter r) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => ReciterScreen(reciter: r)));

/// Reciters home in the style of a music app: recent, popular, all.
class RecitersScreen extends StatefulWidget {
  const RecitersScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const RecitersScreen());

  @override
  State<RecitersScreen> createState() => _RecitersScreenState();
}

class _RecitersScreenState extends State<RecitersScreen> {
  bool _searching = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return BlocProvider(
      create: (c) =>
          RecitersCubit(api: c.read<RecitersApi>(), language: context.lang),
      child: Theme(
        data: _darkTheme(context),
        child: Scaffold(
          appBar: AppBar(
            title: _searching
                ? TextField(
                    autofocus: true,
                    cursorColor: Listen.accent,
                    style: Fonts.body(16, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: l.recitersSearch,
                      hintStyle: Fonts.body(16, color: Colors.black),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  )
                : Text(
                    l.featReciters,
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
          body: BlocBuilder<RecitersCubit, RecitersState>(
            builder: (context, s) {
              if (s.error != null) {
                return Center(
                  child: ErrorState(
                    error: s.error,
                    onRetry: context.read<RecitersCubit>().load,
                  ),
                );
              }
              final all = s.reciters;
              if (all == null) {
                return const SingleChildScrollView(
                  child: ListSkeleton(
                    rows: 10,
                    leading: 56,
                    tone: ShimmerTone.listen,
                  ),
                );
              }
              return _searching
                  ? _Results(reciters: all, query: _query)
                  : _Home(reciters: all);
            },
          ),
        ),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.reciters});

  final List<Reciter> reciters;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final byId = {for (final r in reciters) r.id: r};
    final recentIds = context.watch<RecentRecitersCubit>().state;
    final recent = [for (final id in recentIds) ?byId[id]];
    final popular = [for (final id in popularReciters) ?byId[id]];

    return CustomScrollView(
      slivers: [
        if (recent.isNotEmpty) ...[
          _Heading(l.recentlyPlayed),
          SliverToBoxAdapter(
            child: _Shelf(
              height: 204,
              children: [
                for (final r in recent)
                  _Card(reciter: r, size: 140, circle: false),
              ],
            ),
          ),
        ],
        if (popular.isNotEmpty) ...[
          _Heading(l.popularReciters),
          SliverToBoxAdapter(
            child: _Shelf(
              height: 192,
              children: [
                for (final r in popular)
                  _Card(reciter: r, size: 124, circle: true),
              ],
            ),
          ),
        ],
        _Heading(l.allReciters),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 130,
              mainAxisExtent: 168,
              crossAxisSpacing: 4,
            ),
            itemCount: reciters.length,
            itemBuilder: (context, i) =>
                _Card(reciter: reciters[i], size: 96, circle: true),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
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
    required this.reciter,
    required this.size,
    required this.circle,
  });

  final Reciter reciter;
  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final playing = context.select(
      (RecitationCubit c) =>
          c.state.playing &&
          reciter.recordings.any((r) => r.id == c.state.recording),
    );
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openReciter(context, reciter),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: size,
          child: Column(
            crossAxisAlignment: circle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              ReciterArt(
                name: reciter.name,
                size: size,
                circle: circle,
                photo: reciterPhoto(reciter.id),
              ),
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
                      reciter.name,
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

class _Results extends StatelessWidget {
  const _Results({required this.reciters, required this.query});

  final List<Reciter> reciters;
  final String query;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final shown = [
      for (final r in reciters)
        if (q.isEmpty || r.name.toLowerCase().contains(q)) r,
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
        final r = shown[i];
        return ListTile(
          onTap: () => _openReciter(context, r),
          leading: ReciterArt(
            name: r.name,
            size: 48,
            circle: true,
            photo: reciterPhoto(r.id),
          ),
          title: Text(
            r.name,
            style: Fonts.body(15, color: Listen.text, weight: FontWeight.w600),
          ),
          subtitle: Text(
            r.recordings.first.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Fonts.body(12.5, color: Listen.textSoft),
          ),
        );
      },
    );
  }
}

/// One reciter, like an artist page: big cover, riwaya picker, surahs.
class ReciterScreen extends StatefulWidget {
  const ReciterScreen({super.key, required this.reciter});

  final Reciter reciter;

  @override
  State<ReciterScreen> createState() => _ReciterScreenState();
}

class _ReciterScreenState extends State<ReciterScreen> {
  late Recording _recording = () {
    final playing = context.read<RecitationCubit>().state.recording;
    return widget.reciter.recordings.firstWhere(
      (r) => r.id == playing,
      orElse: () => widget.reciter.recordings.first,
    );
  }();

  Future<void> _play(int surah) async {
    final recitation = context.read<RecitationCubit>();
    final lang = context.lang;
    context.read<RecentRecitersCubit>().played(widget.reciter.id);
    final local = await context.read<DownloadsCubit>().local(_recording.id);
    await recitation.playSurahs(
      widget.reciter,
      _recording,
      surah,
      lang,
      local: local,
    );
  }

  Future<void> _download(int surah) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l.downloadFailed;
    final ok = await context.read<DownloadsCubit>().download(_recording, surah);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final reciter = widget.reciter;
    final rec = _recording;
    final (light, _) = coverColors(reciter.name);
    final s = context.watch<RecitationCubit>().state;
    final thisPlaying = s.recording == rec.id;

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
                  reciter.name,
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
                      padding: const EdgeInsets.only(bottom: 30),
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
                        child: ReciterArt(
                          name: reciter.name,
                          size: 170,
                          circle: true,
                          photo: reciterPhoto(reciter.id),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (reciterPhotoCredits[reciter.id] case (
                      final author,
                      final licence,
                    )) ...[
                      Text(
                        context.l.photoCredit(author, licence),
                        textAlign: TextAlign.center,
                        style: Fonts.body(11, color: Listen.textSoft),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (reciter.recordings.length > 1) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final r in reciter.recordings)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: ChoiceChip(
                                  selected: r.id == rec.id,
                                  showCheckmark: false,
                                  backgroundColor: Listen.surfaceHi,
                                  selectedColor: Listen.accent,
                                  side: BorderSide.none,
                                  shape: const StadiumBorder(),
                                  label: Text(
                                    r.name,
                                    style: Fonts.body(
                                      13,
                                      color: r.id == rec.id
                                          ? Listen.bg
                                          : Listen.text,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _recording = r),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reciter.recordings.length == 1)
                                Text(
                                  rec.name,
                                  style: Fonts.body(
                                    13,
                                    color: Listen.text,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              Text(
                                l.surahCount(context.n('${rec.surahs.length}')),
                                style: Fonts.body(12.5, color: Listen.textSoft),
                              ),
                            ],
                          ),
                        ),
                        SizedBox.square(
                          dimension: 58,
                          child: Material(
                            color: Listen.accent,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: IconButton(
                              tooltip: thisPlaying && s.playing
                                  ? l.pauseTip
                                  : l.playAll,
                              iconSize: 34,
                              color: Listen.bg,
                              icon: Icon(
                                thisPlaying && s.playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              onPressed: thisPlaying
                                  ? context.read<RecitationCubit>().toggle
                                  : () => _play(rec.surahs.first),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: rec.surahs.length,
              itemBuilder: (context, i) => _SurahTrack(
                index: i + 1,
                recording: rec,
                surah: rec.surahs[i],
                onPlay: _play,
                onDownload: _download,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _SurahTrack extends StatelessWidget {
  const _SurahTrack({
    required this.index,
    required this.recording,
    required this.surah,
    required this.onPlay,
    required this.onDownload,
  });

  final int index;
  final Recording recording;
  final int surah;
  final ValueChanged<int> onPlay;
  final ValueChanged<int> onDownload;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = surahs[surah - 1];
    final key = (recording.id, surah);
    final (current, playing) = context.select((RecitationCubit c) {
      final st = c.state;
      final here = st.recording == recording.id && st.current?.surah == surah;
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
            context.read<DownloadsCubit>().delete(recording.id, surah),
      );
    } else {
      download = IconButton(
        tooltip: l.download,
        icon: Icon(Icons.arrow_circle_down_rounded, color: Listen.textSoft),
        onPressed: () => onDownload(surah),
      );
    }

    return InkWell(
      onTap: current
          ? context.read<RecitationCubit>().toggle
          : () => onPlay(surah),
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
                    context.isAr ? 'سورة ${s.arabic}' : s.name,
                    style: Fonts.body(
                      15.5,
                      color: current ? Listen.accent : Listen.text,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (saved) ...[
                        Icon(
                          Icons.arrow_circle_down_rounded,
                          size: 14,
                          color: Listen.accent,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          [
                            context.n(l.ayahCount(s.ayahs)),
                            s.meccan ? l.meccan : l.medinan,
                          ].join('  ·  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Fonts.body(12.5, color: Listen.textSoft),
                        ),
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
