import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/hifz_cubit.dart';
import '../bloc/quran/quran_prefs_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../bloc/quran/recite_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/quran.dart';
import '../services/quran_text.dart';
import '../services/recite_check.dart';
import '../services/recitation.dart';
import '../services/recite_engine.dart';
import '../services/reciter_photos.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mini_player.dart';
import '../widgets/mushaf_frame.dart';
import '../widgets/quran_text.dart';
import '../widgets/shimmer.dart';

/// Memorising: repeat an ayah range, hide the text, mark what's learnt.
class HifzScreen extends StatelessWidget {
  const HifzScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const HifzScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.featHifz)),
      bottomNavigationBar: const MiniPlayer(),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        children: const [
          _Setup(),
          SizedBox(height: 16),
          _HideBar(),
          SizedBox(height: 8),
          _AyahList(),
        ],
      ),
    );
  }
}

bool _isHifzQueue(RecitationState r) =>
    r.active && (r.current?.id.startsWith('hifz:') ?? false);

void _play(BuildContext context, HifzState h, {int? only}) {
  context.read<RecitationCubit>().playHifz(
    h.surah,
    only ?? h.from,
    only ?? h.to,
    context.read<QuranPrefsCubit>().state.reciter,
    context.lang,
    ayahRepeat: h.ayahRepeat,
    rangeRepeat: only == null ? h.rangeRepeat : 1,
  );
}

class _Setup extends StatelessWidget {
  const _Setup();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final cubit = context.read<HifzCubit>();
    final h = context.watch<HifzCubit>().state;
    final surah = surahs[h.surah - 1];
    final recitation = context.watch<RecitationCubit>().state;
    final playing = _isHifzQueue(recitation) && recitation.playing;
    final reciter = context.watch<QuranPrefsCubit>().state.reciter;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => _pickSurah(context),
            leading: NumberBadge(surah.number),
            title: Text(
              ar ? 'سورة ${surah.arabic}' : surah.name,
              style: Fonts.body(16, weight: FontWeight.w600),
            ),
            subtitle: Text(
              l.hifzMemorized(
                context.n(h.memorizedIn(h.surah)),
                context.n(surah.ayahs),
              ),
              style: Fonts.body(12.5, color: Palette.inkSoft),
            ),
            trailing: const Icon(Icons.expand_more_rounded),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => _pickReciter(context),
            leading: _ReciterAvatar(reciter),
            title: Text(
              reciter.label(context.lang),
              style: Fonts.body(15, weight: FontWeight.w600),
            ),
            subtitle: Text(
              l.ayahReciter,
              style: Fonts.body(12.5, color: Palette.inkSoft),
            ),
            trailing: const Icon(Icons.expand_more_rounded),
          ),
          if (surah.ayahs > 1)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => _pickRange(context, surah.ayahs),
              leading: Icon(
                Icons.format_list_numbered_rounded,
                color: Palette.green,
              ),
              title: Text(
                l.hifzRange(context.n(h.from), context.n(h.to)),
                style: Fonts.body(15, weight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.expand_more_rounded),
            ),
          _Repeats(
            label: l.hifzAyahRepeat,
            value: h.ayahRepeat,
            onChanged: cubit.setAyahRepeat,
          ),
          const SizedBox(height: 8),
          _Repeats(
            label: l.hifzRangeRepeat,
            value: h.rangeRepeat,
            onChanged: cubit.setRangeRepeat,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: playing
                ? context.read<RecitationCubit>().stop
                : () => _play(context, h),
            icon: Icon(playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
            label: Text(playing ? l.hifzStop : l.hifzPlay),
          ),
        ],
      ),
    );
  }

  Future<void> _pickSurah(BuildContext context) async {
    final ar = context.isAr;
    final cubit = context.read<HifzCubit>();
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        maxChildSize: .92,
        builder: (_, controller) => ListView.builder(
          controller: controller,
          itemCount: surahs.length,
          itemBuilder: (_, i) {
            final s = surahs[i];
            final done = cubit.state.memorizedIn(s.number);
            return ListTile(
              onTap: () => Navigator.pop(sheet, s.number),
              leading: NumberBadge(s.number),
              title: Text(ar ? 'سورة ${s.arabic}' : s.name),
              trailing: done == 0
                  ? null
                  : Text(
                      '${sheet.n(done)}/${sheet.n(s.ayahs)}',
                      style: Fonts.body(12.5, color: Palette.green),
                    ),
            );
          },
        ),
      ),
    );
    if (picked != null) cubit.setSurah(picked);
  }

  Future<void> _pickRange(BuildContext context, int count) async {
    final cubit = context.read<HifzCubit>();
    final h = cubit.state;
    final picked = await showModalBottomSheet<(int, int)>(
      context: context,
      builder: (_) => _RangePicker(count: count, from: h.from, to: h.to),
    );
    if (picked != null) cubit.setRange(picked.$1, picked.$2);
  }

  Future<void> _pickReciter(BuildContext context) async {
    final prefs = context.read<QuranPrefsCubit>();
    final picked = await showModalBottomSheet<AyahReciter>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        maxChildSize: .92,
        builder: (_, controller) => ListView(
          controller: controller,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Text(sheet.l.ayahReciter, style: Fonts.display(18)),
            ),
            for (final r in AyahReciter.values)
              ListTile(
                onTap: () => Navigator.pop(sheet, r),
                leading: _ReciterAvatar(r),
                title: Text(r.label(sheet.lang)),
                trailing: r == prefs.state.reciter
                    ? Icon(Icons.check_rounded, color: Palette.green)
                    : null,
              ),
          ],
        ),
      ),
    );
    if (picked == null || picked == prefs.state.reciter) return;
    prefs.setReciter(picked);
    if (!context.mounted) return;
    final recitation = context.read<RecitationCubit>().state;
    if (_isHifzQueue(recitation) && recitation.playing) {
      _play(context, context.read<HifzCubit>().state);
    }
  }
}

class _RangePicker extends StatefulWidget {
  const _RangePicker({
    required this.count,
    required this.from,
    required this.to,
  });

  final int count;
  final int from;
  final int to;

  @override
  State<_RangePicker> createState() => _RangePickerState();
}

class _RangePickerState extends State<_RangePicker> {
  late var _from = widget.from;
  late var _to = widget.to;
  late final _fromWheel = FixedExtentScrollController(
    initialItem: widget.from - 1,
  );
  late final _toWheel = FixedExtentScrollController(initialItem: widget.to - 1);

  @override
  void dispose() {
    _fromWheel.dispose();
    _toWheel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    Widget wheel({
      required String label,
      required FixedExtentScrollController controller,
      required ValueChanged<int> onChanged,
    }) {
      return Expanded(
        child: Column(
          children: [
            Text(label, style: Fonts.body(13, color: Palette.inkSoft)),
            Expanded(
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 36,
                onSelectedItemChanged: onChanged,
                children: [
                  for (var i = 1; i <= widget.count; i++)
                    Center(child: Text(context.n(i), style: Fonts.body(18))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SizedBox(
        height: 280,
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.pop(context, (_from, _to)),
                child: Text(l.feedbackDone),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  wheel(
                    label: l.hifzFrom,
                    controller: _fromWheel,
                    onChanged: (i) => _from = i + 1,
                  ),
                  wheel(
                    label: l.hifzTo,
                    controller: _toWheel,
                    onChanged: (i) => _to = i + 1,
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

class _ReciterAvatar extends StatelessWidget {
  const _ReciterAvatar(this.reciter);

  final AyahReciter reciter;

  @override
  Widget build(BuildContext context) {
    final photo = reciterPhoto(reciter.mp3quranId);
    return CircleAvatar(
      radius: 20,
      backgroundColor: Palette.greenSoft,
      backgroundImage: photo == null ? null : AssetImage(photo),
      child: photo == null
          ? Icon(
              Icons.record_voice_over_rounded,
              color: Palette.green,
              size: 20,
            )
          : null,
    );
  }
}

class _Repeats extends StatelessWidget {
  const _Repeats({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Fonts.body(13.5, color: Palette.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final n in HifzCubit.repeats)
              ChoiceChip(
                visualDensity: VisualDensity.compact,
                label: Text(context.l.hifzTimes(context.n(n))),
                selected: n == value,
                onSelected: (_) => onChanged(n),
              ),
          ],
        ),
      ],
    );
  }
}

class _HideBar extends StatelessWidget {
  const _HideBar();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final hide = context.watch<HifzCubit>().state.hide;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<HifzHide>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: HifzHide.none,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l.hifzShow),
              ),
              ButtonSegment(
                value: HifzHide.firstWords,
                icon: const Icon(Icons.short_text_rounded),
                label: Text(l.hifzFirstWords),
              ),
              ButtonSegment(
                value: HifzHide.all,
                icon: const Icon(Icons.visibility_off_outlined),
                label: Text(l.hifzHideAll),
              ),
            ],
            selected: {hide},
            onSelectionChanged: (s) =>
                context.read<HifzCubit>().setHide(s.first),
          ),
          const SizedBox(height: 6),
          Text(l.hifzTestHint, style: Fonts.body(12, color: Palette.inkSoft)),
        ],
      ),
    );
  }
}

class _AyahList extends StatefulWidget {
  const _AyahList();

  @override
  State<_AyahList> createState() => _AyahListState();
}

/// The range laid out as a mushaf page; hidden text is covered in place so
/// lines don't move when an ayah is revealed.
class _AyahListState extends State<_AyahList> {
  Future<List<Ayah>>? _ayahs;
  (int, int, int, Mushaf)? _for;
  final _revealed = <int>{};
  final _taps = <int, TapGestureRecognizer>{};

  static const _recitingColor = Color(0x33B0812F);

  Mushaf get _script => context.read<QuranPrefsCubit>().state.mushaf;

  void _load(HifzState h) {
    final key = (h.surah, h.from, h.to, _script);
    if (_for == key) return;
    final reset = _for != null;
    _for = key;
    _revealed.clear();
    if (reset) {
      final recite = context.read<ReciteCubit>();
      WidgetsBinding.instance.addPostFrameCallback((_) => recite.clear());
    }
    final text = context.read<QuranText>();
    _ayahs = Future.wait([
      for (var a = h.from; a <= h.to; a++) text.ayah(h.surah, a, _script),
    ]);
  }

  TapGestureRecognizer _hear(int ayah) =>
      _taps[ayah] ??= TapGestureRecognizer()
        ..onTap = () {
          final h = context.read<HifzCubit>().state;
          if (h.hide != HifzHide.none && !_revealed.contains(ayah)) {
            setState(() => _revealed.add(ayah));
          }
          _play(context, h, only: ayah);
        };

  @override
  void dispose() {
    for (final t in _taps.values) {
      t.dispose();
    }
    super.dispose();
  }

  List<InlineSpan> _ayah(
    Ayah a,
    Mushaf mushaf,
    HifzHide hide,
    bool current,
    bool memorized,
    double fs,
    _Marks? marks,
  ) {
    final background = current ? _recitingColor : null;
    final covered = TextStyle(
      color: Colors.transparent,
      backgroundColor: MushafColors.band,
    );
    final words = stripTajweed(a.text).split(' ');
    final shownWords = switch (hide) {
      HifzHide.none => words.length,
      HifzHide.firstWords => words.length < 2 ? words.length : 2,
      HifzHide.all => 0,
    };
    return [
      if (marks != null)
        for (final (i, w) in words.indexed)
          TextSpan(
            text: i < words.length - 1 ? '$w ' : w,
            style: switch (marks.marks[(a.number, i)]) {
              WordMark.unreached || null when marks.live => covered,
              final mark => _markStyle(mark),
            },
            recognizer: _hear(a.number),
          )
      else if (shownWords == words.length)
        ...ayahSpans(
          a.text,
          mushaf,
          recognizer: _hear(a.number),
          background: background,
        )
      else ...[
        if (shownWords > 0)
          TextSpan(
            text: '${words.take(shownWords).join(' ')} ',
            style: TextStyle(backgroundColor: background),
            recognizer: _hear(a.number),
          ),
        TextSpan(
          text: words.skip(shownWords).join(' '),
          style: covered,
          recognizer: _hear(a.number),
        ),
      ],
      const TextSpan(text: '\u00A0'),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: () => _options(a, memorized),
            child: AyahMarker(
              a.number,
              size: fs * 1.25,
              color: memorized ? MushafColors.green : Palette.brass,
            ),
          ),
        ),
      ),
      const TextSpan(text: ' '),
    ];
  }

  static TextStyle? _markStyle(WordMark? mark) => switch (mark) {
    WordMark.correct => TextStyle(color: MushafColors.green),
    WordMark.wrong => TextStyle(
      color: _mistakeColor,
      backgroundColor: _mistakeColor.withValues(alpha: .14),
    ),
    WordMark.missing => TextStyle(
      color: Palette.inkSoft,
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.wavy,
      decorationColor: _skippedColor,
    ),
    WordMark.unreached || null => null,
  };

  Future<void> _options(Ayah a, bool memorized) => showModalBottomSheet<void>(
    context: context,
    builder: (sheet) {
      final l = sheet.l;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                l.ayahRef(
                  sheet.isAr
                      ? surahs[a.surah - 1].arabic
                      : surahs[a.surah - 1].name,
                  sheet.n(a.number),
                ),
                style: Fonts.body(15, weight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.play_circle_outline_rounded,
                color: Palette.green,
              ),
              title: Text(l.hifzPlayAyah),
              onTap: () {
                Navigator.pop(sheet);
                _play(context, context.read<HifzCubit>().state, only: a.number);
              },
            ),
            ListTile(
              leading: Icon(
                memorized
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
                color: Palette.green,
              ),
              title: Text(memorized ? l.hifzUnmark : l.hifzMark),
              onTap: () {
                Navigator.pop(sheet);
                context.read<HifzCubit>().toggleMemorized(a.surah, a.number);
              },
            ),
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final h = context.watch<HifzCubit>().state;
    final prefs = context.watch<QuranPrefsCubit>().state;
    _load(h);
    final recitation = context.watch<RecitationCubit>().state;
    final current = _isHifzQueue(recitation) ? recitation.ayah : null;
    final fs = prefs.fontSize;
    final mushaf = prefs.mushaf;
    final surah = surahs[h.surah - 1];
    final recite = context.watch<ReciteCubit>().state;
    final listening =
        recite.phase == RecitePhase.recording ||
        recite.phase == RecitePhase.checking;
    final _Marks? marks = switch (recite.result) {
      final r? when recite.phase == RecitePhase.done => (
        marks: r.marks,
        live: false,
      ),
      final r when listening && h.revealLive => (
        marks: r?.marks ?? const {},
        live: true,
      ),
      _ => null,
    };

    return FutureBuilder<List<Ayah>>(
      future: _ayahs,
      builder: (context, snap) {
        final ayahs = snap.data;
        if (ayahs == null) return const ListSkeleton(rows: 4);
        final opening = ayahs.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReciteBar(ayahs),
              const SizedBox(height: 10),
              MushafFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SurahCartouche(
                        title: 'سورة ${surah.arabic}',
                        height: fs * 1.9,
                      ),
                    ),
                    if (opening.opensWithBismillah)
                      Text.rich(
                        TextSpan(children: ayahSpans(mushaf.bismillah, mushaf)),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        textScaler: TextScaler.noScaling,
                        style: Fonts.mushaf(fs),
                      ),
                    // Semantics can't follow tap spans being added or removed
                    // in place, so a new span layout gets a new paragraph.
                    Text.rich(
                      key: ValueKey((
                        marks?.live,
                        h.hide,
                        current,
                        (_revealed.toList()..sort()).join(','),
                      )),
                      TextSpan(
                        children: [
                          for (final a in ayahs)
                            ..._ayah(
                              a,
                              mushaf,
                              _revealed.contains(a.number)
                                  ? HifzHide.none
                                  : h.hide,
                              current == (a.surah, a.number),
                              h.isMemorized(a.surah, a.number),
                              fs,
                              marks,
                            ),
                        ],
                      ),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      textScaler: TextScaler.noScaling,
                      style: Fonts.mushaf(fs),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: PageMedallion(
                  '${arabicDigits('${h.from}')} – ${arabicDigits('${h.to}')}',
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l.hifzPageHint,
                  textAlign: TextAlign.center,
                  style: Fonts.body(12, color: Palette.inkSoft),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Recite & check marks; [live] covers words not heard yet.
typedef _Marks = ({Map<(int, int), WordMark> marks, bool live});

const _mistakeColor = Color(0xFFD64545);
const _skippedColor = Color(0xFFE0A030);

/// Recite the range from memory; whisper checks it on the device.
class _ReciteBar extends StatelessWidget {
  const _ReciteBar(this.ayahs);

  final List<Ayah> ayahs;

  Future<void> _begin(BuildContext context) async {
    final l = context.l;
    final cubit = context.read<ReciteCubit>();
    final recitation = context.read<RecitationCubit>();
    if (!await cubit.hasModel()) {
      if (!context.mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(l.reciteModelTitle),
          content: Text(
            l.reciteModelBody(
              '${dialog.n((ReciteEngine.modelBytes / 1e6).round())} MB',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(l.reciteDownload),
            ),
          ],
        ),
      );
      if (ok != true || !await cubit.download()) return;
    }
    if (recitation.state.active) await recitation.stop();
    await cubit.start(ayahs);
  }

  Future<void> _feedback(BuildContext context, ReciteResult result) async {
    final hifz = context.read<HifzCubit>();
    final retry = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) =>
          BlocProvider.value(value: hifz, child: _Feedback(result)),
    );
    if (retry == true && context.mounted) await _begin(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<ReciteCubit>();
    final s = context.watch<ReciteCubit>().state;
    final h = context.watch<HifzCubit>().state;
    final note = Fonts.body(12, color: Palette.inkSoft);

    final Widget body = switch (s.phase) {
      RecitePhase.downloading => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.reciteDownloading('${context.n((s.progress * 100).round())}%'),
            style: Fonts.body(13.5, weight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: s.progress),
        ],
      ),
      RecitePhase.recording => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (h.revealLive && s.result != null) ...[
            Text(
              l.reciteProgress(
                context.n(s.result!.reached),
                context.n(s.result!.marks.length),
              ),
              style: Fonts.body(13, color: Palette.inkSoft),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: s.result!.reached / s.result!.marks.length,
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _mistakeColor),
            onPressed: () => cubit.finish(ayahs),
            icon: const Icon(Icons.stop_rounded),
            label: Text(l.reciteListening),
          ),
        ],
      ),
      RecitePhase.checking => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Flexible(child: Text(l.reciteChecking, style: Fonts.body(13.5))),
        ],
      ),
      RecitePhase.done => _Summary(
        s.result!,
        onFeedback: () => _feedback(context, s.result!),
        onRetry: () => _begin(context),
      ),
      RecitePhase.idle => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _begin(context),
            icon: const Icon(Icons.mic_none_rounded),
            label: Text(l.reciteCheck),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: h.revealLive,
            onChanged: context.read<HifzCubit>().setRevealLive,
            title: Text(l.reciteRevealLive, style: Fonts.body(14)),
            subtitle: Text(l.reciteRevealLiveHint, style: note),
          ),
          Text(
            switch (s.error) {
              ReciteError.permission => l.reciteNoPermission,
              ReciteError.download => l.reciteDownloadFailed,
              ReciteError.failed => l.reciteFailed,
              ReciteError.nothing => l.reciteNothing,
              null => l.reciteHint,
            },
            textAlign: TextAlign.center,
            style: s.error == null
                ? note
                : Fonts.body(12, color: _mistakeColor),
          ),
        ],
      ),
    };
    return BlocListener<ReciteCubit, ReciteState>(
      listenWhen: (a, b) =>
          a.phase != RecitePhase.done && b.phase == RecitePhase.done,
      listener: (context, s) => _feedback(context, s.result!),
      child: AppCard(margin: EdgeInsets.zero, child: body),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary(
    this.result, {
    required this.onFeedback,
    required this.onRetry,
  });

  final ReciteResult result;
  final VoidCallback onFeedback;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.reciteResult(
            context.n(result.count(WordMark.correct)),
            context.n(result.reached),
          ),
          style: Fonts.body(15, weight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(l.reciteLegend, style: Fonts.body(12, color: Palette.inkSoft)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.mic_none_rounded),
                label: Text(l.retry),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onFeedback, child: Text(l.feedbackOpen)),
            TextButton(
              onPressed: context.read<ReciteCubit>().clear,
              child: Text(l.reciteClear),
            ),
          ],
        ),
      ],
    );
  }
}

/// Final feedback once the reciter finishes.
class _Feedback extends StatelessWidget {
  const _Feedback(this.result);

  final ReciteResult result;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final h = context.watch<HifzCubit>().state;
    final score = result.score;
    final (grade, color) = switch (score) {
      >= .95 => (l.gradeExcellent, Palette.green),
      >= .8 => (l.gradeVeryGood, Palette.green),
      >= .6 => (l.gradeGood, _skippedColor),
      _ => (l.gradeReview, _mistakeColor),
    };
    final unreached = result.count(WordMark.unreached);
    final perfect = result.perfectAyahs;
    final surah = h.surah;
    final allLearnt = perfect.every((a) => h.isMemorized(surah, a));
    final mistakes = result.mistakes;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          children: [
            Text(
              l.feedbackTitle,
              textAlign: TextAlign.center,
              style: Fonts.display(20),
            ),
            const SizedBox(height: 18),
            Center(
              child: SizedBox.square(
                dimension: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: score,
                      strokeWidth: 9,
                      color: color,
                      backgroundColor: Palette.rule,
                    ),
                    Center(
                      child: Text(
                        '${context.n((score * 100).round())}%',
                        style: Fonts.body(24, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              grade,
              textAlign: TextAlign.center,
              style: Fonts.body(16, weight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat(
                  result.count(WordMark.correct),
                  l.feedbackMatched,
                  Palette.green,
                ),
                _Stat(
                  result.count(WordMark.wrong),
                  l.feedbackMistakes,
                  _mistakeColor,
                ),
                _Stat(
                  result.count(WordMark.missing),
                  l.feedbackSkipped,
                  _skippedColor,
                ),
              ],
            ),
            if (unreached > 0) ...[
              const SizedBox(height: 12),
              Text(
                l.feedbackUnreached(context.n(unreached)),
                textAlign: TextAlign.center,
                style: Fonts.body(12.5, color: Palette.inkSoft),
              ),
            ],
            if (perfect.isNotEmpty) ...[
              const SizedBox(height: 14),
              AppCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                color: Palette.greenSoft,
                child: Row(
                  children: [
                    Icon(Icons.verified_rounded, color: Palette.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.feedbackPerfect(context.n(perfect.length)),
                        style: Fonts.body(13.5, weight: FontWeight.w500),
                      ),
                    ),
                    if (allLearnt)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.check_rounded, color: Palette.green),
                      )
                    else
                      TextButton(
                        onPressed: () => context
                            .read<HifzCubit>()
                            .markMemorized(surah, perfect),
                        child: Text(l.feedbackMarkLearnt),
                      ),
                  ],
                ),
              ),
            ],
            if (mistakes.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                l.feedbackReview,
                style: Fonts.body(14, weight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              for (final w in mistakes)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: AyahMarker(w.ayah, size: 30),
                  title: Text(
                    stripTajweed(w.word),
                    textDirection: TextDirection.rtl,
                    style: Fonts.mushaf(
                      22,
                      height: 1.6,
                      color: result.markOf(w) == WordMark.wrong
                          ? _mistakeColor
                          : _skippedColor,
                    ),
                  ),
                  subtitle: Text(switch (result.heardAs[(w.ayah, w.index)]) {
                    final heard? => l.feedbackHeardAs(heard),
                    null => l.feedbackSkippedWord,
                  }, style: Fonts.body(12.5, color: Palette.inkSoft)),
                ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.mic_none_rounded),
                    label: Text(l.retry),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l.feedbackDone),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color);

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          context.n(value),
          style: Fonts.body(20, weight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Fonts.body(12, color: Palette.inkSoft),
        ),
      ],
    ),
  );
}
