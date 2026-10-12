import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/quran/mushaf_cubit.dart';
import '../bloc/quran/quran_prefs_cubit.dart';
import '../bloc/quran/khatmah_cubit.dart';
import '../bloc/quran/recent_surahs_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../bloc/quran/tafsir_cubit.dart';
import '../bloc/quran_bookmark_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/mushaf_pages.dart';
import '../services/quran.dart';
import '../services/recitation.dart';
import '../theme.dart';
import '../widgets/ayah_share.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';
import '../widgets/mini_player.dart';
import '../widgets/quran_text.dart';
import '../widgets/mushaf_frame.dart';

typedef AyahRef = (int surah, int ayah);

/// The whole Quran as 604 swipeable pages; surahs run into each other as
/// in a printed mushaf.
class MushafScreen extends StatelessWidget {
  const MushafScreen({super.key, required this.page, this.highlight});

  final int page;

  /// Ayah to highlight briefly on open.
  final AyahRef? highlight;

  static Route<void> route(int surah, {int ayah = 1, bool highlight = false}) =>
      MaterialPageRoute(
        builder: (_) => MushafScreen(
          page: pageOf(surah, ayah),
          highlight: highlight ? (surah, ayah) : null,
        ),
      );

  static Route<void> routeToPage(int page) =>
      MaterialPageRoute(builder: (_) => MushafScreen(page: page));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => MushafCubit(
        api: c.read<QuranApi>(),
        mushaf: c.read<QuranPrefsCubit>().state.mushaf,
      )..visit(page),
      child: _Reader(initialPage: page, highlight: highlight),
    );
  }
}

class _Reader extends StatefulWidget {
  const _Reader({required this.initialPage, this.highlight});

  final int initialPage;
  final AyahRef? highlight;

  @override
  State<_Reader> createState() => _ReaderState();
}

class _ReaderState extends State<_Reader> {
  late final _pages = PageController(initialPage: widget.initialPage - 1);
  late int _page = widget.initialPage;
  late AyahRef? _selected = widget.highlight;
  final _taps = <AyahRef, TapGestureRecognizer>{};
  Timer? _unhighlight;
  Timer? _dwell;
  bool _chrome = true;

  @override
  void initState() {
    super.initState();
    _recordVisit(_page);
    _startDwell();
    if (_selected != null) {
      _unhighlight = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _selected = null);
      });
    }
    // Page fitting measures text, so redo it once the mushaf font arrives.
    GoogleFonts.pendingFonts().then((_) {
      _fits.clear();
      if (mounted) setState(() {});
    }, onError: (_) {});
  }

  @override
  void dispose() {
    for (final t in _taps.values) {
      t.dispose();
    }
    _unhighlight?.cancel();
    _dwell?.cancel();
    _pages.dispose();
    super.dispose();
  }

  void _recordVisit(int page) =>
      context.read<RecentSurahsCubit>().visit(pageStarts[page - 1].$1, page);

  /// A page counts towards the khatmah once it's been open a while.
  void _startDwell() {
    _dwell?.cancel();
    final page = _page;
    _dwell = Timer(const Duration(seconds: 20), () {
      if (mounted) context.read<KhatmahCubit>().markRead(page);
    });
  }

  TapGestureRecognizer _tap(AyahRef ref) =>
      _taps[ref] ??= TapGestureRecognizer()..onTap = () => _open(ref);

  Future<void> _open(AyahRef ref) async {
    _unhighlight?.cancel();
    setState(() => _selected = ref);
    await showTafsirSheet(
      context,
      surah: ref.$1,
      ayah: ref.$2,
      onAyah: (next) {
        setState(() => _selected = next);
        final page = pageOf(next.$1, next.$2);
        if (page != _page) _pages.jumpToPage(page - 1);
      },
      onListen: _listen,
    );
    if (mounted) setState(() => _selected = null);
  }

  void _listen(AyahRef from) => context.read<RecitationCubit>().playAyahs(
    from.$1,
    from.$2,
    context.read<QuranPrefsCubit>().state.reciter,
    context.lang,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final surah = surahs[pageStarts[_page - 1].$1 - 1];
    // Page 2 lies to the left of page 1, as in a printed mushaf.
    final ltr = Directionality.of(context) == TextDirection.ltr;

    final recitation = context.watch<RecitationCubit>().state;
    final recitingHere =
        recitation.kind == RecitationKind.ayahs && recitation.playing;

    return MultiBlocListener(
      listeners: [
        BlocListener<QuranPrefsCubit, QuranPrefs>(
          listenWhen: (a, b) => a.mushaf != b.mushaf,
          listener: (context, p) =>
              context.read<MushafCubit>().setMushaf(p.mushaf, page: _page),
        ),
        // Turn pages along with the recitation.
        BlocListener<RecitationCubit, RecitationState>(
          listenWhen: (a, b) => a.ayah != b.ayah && b.ayah != null,
          listener: (context, s) {
            final (surah, ayah) = s.ayah!;
            final page = pageOf(surah, ayah);
            if (page != _page && _pages.hasClients) {
              _pages.animateToPage(
                page - 1,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Palette.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          bottomNavigationBar: const MiniPlayer(canOpenReader: false),
          body: Stack(
            children: [
              SafeArea(
                bottom: !recitation.active,
                child: PageView.builder(
                  controller: _pages,
                  reverse: ltr,
                  itemCount: pageCount,
                  onPageChanged: (i) {
                    // Turning to the next page means this one was read.
                    if (i == _page) {
                      context.read<KhatmahCubit>().markRead(_page);
                    }
                    setState(() {
                      _page = i + 1;
                      _chrome = false;
                    });
                    context.read<MushafCubit>().visit(i + 1);
                    _recordVisit(i + 1);
                    _startDwell();
                  },
                  itemBuilder: (context, i) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _chrome = !_chrome),
                    child: _PageBody(
                      number: i + 1,
                      selected: _selected,
                      reciting: recitation.ayah,
                      onTap: _tap,
                      onMarkerTap: _open,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: !_chrome,
                  child: AnimatedOpacity(
                    opacity: _chrome ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Material(
                      color: Palette.paper,
                      elevation: 2,
                      shadowColor: Palette.ink.withValues(alpha: .2),
                      child: SafeArea(
                        bottom: false,
                        child: SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              const BackButton(),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.surahName(surah),
                                      style: Fonts.display(19),
                                    ),
                                    Text(
                                      l.pageN(context.n(_page)),
                                      style: Fonts.body(
                                        12,
                                        color: Palette.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: recitingHere
                                    ? l.pauseTip
                                    : l.listenPage,
                                icon: Icon(
                                  recitingHere
                                      ? Icons.pause_circle_outline_rounded
                                      : Icons.headphones_rounded,
                                ),
                                onPressed: () => recitingHere
                                    ? context.read<RecitationCubit>().pause()
                                    : _listen(pageStarts[_page - 1]),
                              ),
                              IconButton(
                                tooltip: l.readingSettings,
                                icon: const Icon(Icons.tune_rounded),
                                onPressed: () => showReadingSettings(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Font size and line height that fill a page's frame.
typedef _Fit = ({double fontSize, double lineHeight, bool overflows});

final _fits = <(int, Mushaf, double, double, double), _Fit>{};

const _baseLine = 2.05;
const _minFont = 14.0;

class _PageBody extends StatelessWidget {
  const _PageBody({
    required this.number,
    required this.selected,
    this.reciting,
    required this.onTap,
    required this.onMarkerTap,
  });

  final int number;
  final AyahRef? selected;

  /// Ayah being recited aloud.
  final AyahRef? reciting;
  final TapGestureRecognizer Function(AyahRef)? onTap;
  final ValueChanged<AyahRef>? onMarkerTap;

  @override
  Widget build(BuildContext context) {
    final load = context.select((MushafCubit c) => c.state.pages[number]);
    final page = load?.page;
    if (page == null) {
      if (load?.error == null) {
        return const SingleChildScrollView(child: PageSkeleton());
      }
      return Center(
        child: ErrorState(
          error: load!.error,
          onRetry: () => context.read<MushafCubit>().visit(number),
        ),
      );
    }

    final maxFont = context.select((QuranPrefsCubit c) => c.state.fontSize);
    final bookmark = context.watch<QuranBookmarkCubit>().state;
    final first = page.ayahs.first;
    final juz = context.isAr
        ? 'الجزء ${juzOrdinalsAr[first.juz - 1]}'
        : context.l.juzN('${first.juz}');

    // One block per surah on the page; a new surah gets its title.
    final blocks = <List<Ayah>>[];
    for (final a in page.ayahs) {
      if (blocks.isEmpty || a.number == 1) blocks.add([]);
      blocks.last.add(a);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(juz, style: _headerStyle),
                  const Spacer(),
                  Text(
                    'سورة ${surahs[first.surah - 1].arabic}',
                    style: _headerStyle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: MushafFrame(
              child: LayoutBuilder(
                builder: (context, c) {
                  final fit = _fit(
                    page,
                    blocks,
                    maxFont,
                    c.maxWidth,
                    c.maxHeight,
                  );
                  return SingleChildScrollView(
                    physics: fit.overflows
                        ? null
                        : const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final block in blocks)
                            ..._block(block, page.mushaf, fit, bookmark),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          PageMedallion(arabicDigits('$number')),
        ],
      ),
    );
  }

  static const _recitingColor = Color(0x33B0812F);

  static final _headerStyle = Fonts.arabic(
    14,
    color: MushafColors.green,
  ).copyWith(height: 1.5);

  List<Widget> _block(
    List<Ayah> block,
    Mushaf mushaf,
    _Fit fit,
    QuranBookmark? bookmark,
  ) {
    final fs = fit.fontSize;
    final opening = block.first;
    return [
      if (opening.number == 1)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SurahCartouche(
            title: 'سورة ${surahs[opening.surah - 1].arabic}',
            height: fs * 1.9,
          ),
        ),
      if (opening.opensWithBismillah)
        Text.rich(
          TextSpan(children: ayahSpans(mushaf.bismillah, mushaf)),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          textScaler: TextScaler.noScaling,
          style: Fonts.mushaf(fs, height: fit.lineHeight),
        ),
      Text.rich(
        TextSpan(children: _spans(block, mushaf, fs, bookmark)),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        textScaler: TextScaler.noScaling,
        style: Fonts.mushaf(fs, height: fit.lineHeight),
      ),
    ];
  }

  List<InlineSpan> _spans(
    List<Ayah> block,
    Mushaf mushaf,
    double fs,
    QuranBookmark? bookmark,
  ) => [
    for (final a in block) ...[
      ...ayahSpans(
        a.text,
        mushaf,
        recognizer: onTap?.call((a.surah, a.number)),
        background: (a.surah, a.number) == selected
            ? Palette.greenSoft
            : (a.surah, a.number) == reciting
            ? _recitingColor
            : null,
      ),
      const TextSpan(text: '\u00A0'),
      if (a.sajda)
        TextSpan(
          text: '۩\u00A0',
          style: TextStyle(color: Palette.clay),
        ),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: () => onMarkerTap?.call((a.surah, a.number)),
            child: AyahMarker(
              a.number,
              size: fs * 1.25,
              color: bookmark?.surah == a.surah && bookmark?.ayah == a.number
                  ? Palette.clay
                  : Palette.brass,
            ),
          ),
        ),
      ),
      const TextSpan(text: ' '),
    ],
  ];

  /// Largest font up to [maxFont] that fits, then lines spread out to fill
  /// the frame like a printed page.
  _Fit _fit(
    MushafPage page,
    List<List<Ayah>> blocks,
    double maxFont,
    double width,
    double height,
  ) {
    if (_fits.length > 40) _fits.clear();
    return _fits[(page.number, page.mushaf, maxFont, width, height)] ??= () {
      double measure(double fs, double lh) {
        var total = 0.0;
        double paragraph(List<InlineSpan> spans, int markers) {
          final painter = TextPainter(
            text: TextSpan(
              children: spans,
              style: Fonts.mushaf(fs, height: lh),
            ),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          );
          painter
            ..setPlaceholderDimensions([
              for (var i = 0; i < markers; i++)
                PlaceholderDimensions(
                  size: Size.square(fs * 1.25),
                  alignment: PlaceholderAlignment.middle,
                ),
            ])
            ..layout(maxWidth: width);
          final h = painter.height;
          painter.dispose();
          return h;
        }

        for (final block in blocks) {
          final opening = block.first;
          if (opening.number == 1) total += fs * 1.9 + 8;
          if (opening.opensWithBismillah) {
            total += paragraph(
              ayahSpans(page.mushaf.bismillah, page.mushaf),
              0,
            );
          }
          total += paragraph(
            _spans(block, page.mushaf, fs, null),
            block.length,
          );
        }
        return total;
      }

      var fs = maxFont;
      while (fs > _minFont && measure(fs, _baseLine) > height) {
        fs -= 1;
      }
      final used = measure(fs, _baseLine);
      if (used > height) {
        return (fontSize: fs, lineHeight: _baseLine, overflows: true);
      }
      var lh = math.min(_baseLine * height / used, 2.8);
      // Titles don't grow with line height; back off until it fits.
      while (lh > _baseLine && measure(fs, lh) > height) {
        lh -= .05;
      }
      return (
        fontSize: fs,
        lineHeight: math.max(lh, _baseLine),
        overflows: false,
      );
    }();
  }
}

Future<void> showReadingSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ReadingSettingsPanel(),
    ),
  );
}

/// Mushaf type, text size and default tafsir; used in the reader and
/// during onboarding.
class ReadingSettingsPanel extends StatelessWidget {
  const ReadingSettingsPanel({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final prefs = context.watch<QuranPrefsCubit>();
    final p = prefs.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l.readingSettings, style: Fonts.display(22)),
          ),
          const SizedBox(height: 14),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Caption(l.mushafType),
        ),
        const SizedBox(height: 8),
        for (final m in Mushaf.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MushafOption(
              mushaf: m,
              selected: m == p.mushaf,
              onTap: () => prefs.setMushaf(m),
            ),
          ),
        if (p.mushaf == Mushaf.tajweed) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Caption(l.tajweedKey),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: TajweedKey(),
          ),
        ],
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Caption(l.textSize),
        ),
        Row(
          children: [
            Text('ا', style: Fonts.mushaf(16, color: Palette.inkSoft)),
            Expanded(
              child: Slider(
                value: p.fontSize,
                min: QuranPrefs.minFontSize,
                max: QuranPrefs.maxFontSize,
                divisions: 10,
                activeColor: Palette.green,
                inactiveColor: Palette.rule,
                onChanged: prefs.setFontSize,
              ),
            ),
            Text('ا', style: Fonts.mushaf(28, color: Palette.inkSoft)),
          ],
        ),
        Text(
          'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: Fonts.mushaf(p.fontSize),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Caption(l.defaultTafsir),
        ),
        const SizedBox(height: 8),
        _SourcePicker(
          selected: p.tafsirFor(context.lang),
          onSelected: prefs.setTafsir,
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Caption(l.ayahReciter),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
          child: Text(
            l.ayahReciterSub,
            style: Fonts.body(12.5, color: Palette.inkSoft),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in AyahReciter.values)
              ChoiceChip(
                selected: r == p.reciter,
                showCheckmark: false,
                backgroundColor: Palette.card,
                selectedColor: Palette.greenSoft,
                side: BorderSide(
                  color: r == p.reciter ? Palette.green : Palette.rule,
                ),
                label: Text(
                  r.label(context.lang),
                  style: Fonts.body(
                    13,
                    color: r == p.reciter ? Palette.green : Palette.ink,
                    weight: r == p.reciter ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onSelected: (_) => prefs.setReciter(r),
              ),
          ],
        ),
      ],
    );
  }
}

class _MushafOption extends StatelessWidget {
  const _MushafOption({
    required this.mushaf,
    required this.selected,
    required this.onTap,
  });

  final Mushaf mushaf;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Palette.greenSoft : Palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? Palette.green : Palette.rule,
          width: selected ? 1.2 : .7,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.mushafName(mushaf),
                      style: Fonts.body(15, weight: FontWeight.w600),
                    ),
                    Text(
                      context.mushafDetail(mushaf),
                      style: Fonts.body(12.5, color: Palette.inkSoft),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text.rich(
                        TextSpan(children: ayahSpans(mushaf.bismillah, mushaf)),
                        textDirection: TextDirection.rtl,
                        style: Fonts.mushaf(20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? Palette.green : Palette.rule,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showTafsirSheet(
  BuildContext context, {
  required int surah,
  required int ayah,
  ValueChanged<AyahRef>? onAyah,
  ValueChanged<AyahRef>? onListen,
}) {
  final prefs = context.read<QuranPrefsCubit>().state;
  final source = prefs.tafsirFor(context.lang);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (c) => TafsirCubit(
        api: c.read<QuranApi>(),
        mushaf: prefs.mushaf,
        surah: surah,
        ayah: ayah,
        source: source,
      ),
      child: _TafsirSheet(onAyah: onAyah, onListen: onListen),
    ),
  );
}

class _TafsirSheet extends StatefulWidget {
  const _TafsirSheet({this.onAyah, this.onListen});

  final ValueChanged<AyahRef>? onAyah;
  final ValueChanged<AyahRef>? onListen;

  @override
  State<_TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<_TafsirSheet> {
  bool _copied = false;

  String _ref(TafsirState s) {
    final surah = surahs[s.surah - 1];
    return context.l.ayahRef(
      context.isAr ? surah.arabic : surah.name,
      context.n(s.ayah),
    );
  }

  Future<void> _copy(TafsirState s) async {
    await Clipboard.setData(
      ClipboardData(
        text: [
          if (s.verse case final v?)
            '${stripTajweed(v.text)} ﴿${arabicDigits('${s.ayah}')}﴾',
          if (s.text?.isNotEmpty ?? false) s.text,
          '— ${_ref(s)} · ${context.tafsirName(s.source)}',
        ].join('\n\n'),
      ),
    );
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<TafsirCubit>();
    final s = context.watch<TafsirCubit>().state;
    final bookmarks = context.watch<QuranBookmarkCubit>();
    final isMarked = bookmarks.state == QuranBookmark(s.surah, s.ayah);

    return BlocListener<TafsirCubit, TafsirState>(
      listenWhen: (a, b) => a.surah != b.surah || a.ayah != b.ayah,
      listener: (_, s) {
        setState(() => _copied = false);
        widget.onAyah?.call((s.surah, s.ayah));
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .62,
        minChildSize: .35,
        maxChildSize: .95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: s.isFirst ? null : cubit.previous,
                  icon: const Icon(Icons.navigate_before_rounded),
                ),
                Expanded(
                  child: Text(
                    _ref(s),
                    textAlign: TextAlign.center,
                    style: Fonts.body(14, weight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: s.isLast ? null : cubit.next,
                  icon: const Icon(Icons.navigate_next_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (s.verse case final v?)
              Text.rich(
                TextSpan(
                  children: [
                    ...ayahSpans(v.text, cubit.mushaf),
                    const TextSpan(text: '\u00A0'),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AyahMarker(s.ayah, size: 30),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: Fonts.mushaf(24),
              )
            else
              const Shimmer(
                child: SkeletonLines(
                  lines: 2,
                  height: 18,
                  align: CrossAxisAlignment.center,
                ),
              ),
            const SizedBox(height: 14),
            if (widget.onListen case final listen?) ...[
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  listen((s.surah, s.ayah));
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.headphones_rounded, size: 20),
                label: Text(l.listenFromHere),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => bookmarks.mark(s.surah, s.ayah),
                    style: _actionStyle,
                    icon: Icon(
                      isMarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_add_outlined,
                      size: 20,
                    ),
                    label: Text(
                      isMarked ? l.lastRead : l.markLastRead,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: s.loading ? null : () => _copy(s),
                  style: _actionStyle,
                  icon: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 20,
                  ),
                  label: Text(_copied ? l.copied : l.copy),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () =>
                      showAyahShare(context, surah: s.surah, ayah: s.ayah),
                  style: _actionStyle.copyWith(
                    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                    minimumSize: const WidgetStatePropertyAll(Size(46, 46)),
                  ),
                  child: Tooltip(
                    message: l.shareImage,
                    child: const Icon(Icons.ios_share_rounded, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Caption(l.tafsir),
            const SizedBox(height: 8),
            _SourcePicker(
              selected: s.source,
              onSelected: (source) {
                context.read<QuranPrefsCubit>().setTafsir(source);
                cubit.setSource(source);
              },
            ),
            const SizedBox(height: 16),
            if (s.loading)
              const Shimmer(child: SkeletonLines(lines: 5, height: 13))
            else if (s.error != null)
              ErrorState(error: s.error, onRetry: cubit.retry)
            else if (s.text!.isEmpty)
              Text(l.tafsirEmpty, style: Fonts.body(14, color: Palette.inkSoft))
            else
              Directionality(
                textDirection: s.source.language == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: SelectableText(
                  s.text!,
                  style: Fonts.reading(s.source.language, 15.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static final _actionStyle = OutlinedButton.styleFrom(
    foregroundColor: Palette.green,
    side: BorderSide(color: Palette.rule),
    minimumSize: const Size(0, 46),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _SourcePicker extends StatelessWidget {
  const _SourcePicker({required this.selected, required this.onSelected});

  final TafsirSource selected;
  final ValueChanged<TafsirSource> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lang = context.lang;
    // Sources in the reader's language first.
    final sources = [
      ...TafsirSource.values.where((s) => s.language == lang),
      ...TafsirSource.values.where((s) => s.language != lang),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final s in sources)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                selected: s == selected,
                showCheckmark: false,
                backgroundColor: Palette.card,
                selectedColor: Palette.greenSoft,
                side: BorderSide(
                  color: s == selected ? Palette.green : Palette.rule,
                ),
                label: Text(
                  s.language == lang
                      ? context.tafsirName(s)
                      : '${context.tafsirName(s)} · '
                            '${s.language == 'ar' ? l.tafsirArabicNote : l.tafsirEnglishNote}',
                  style: Fonts.body(
                    13,
                    color: s == selected ? Palette.green : Palette.ink,
                    weight: s == selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onSelected: (_) => onSelected(s),
              ),
            ),
        ],
      ),
    );
  }
}
