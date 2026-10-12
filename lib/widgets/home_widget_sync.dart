import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';

import '../bloc/hisn_cubit.dart';
import '../bloc/names/names_bloc.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/tab_cubit.dart';
import '../l10n/l10n.dart';
import '../screens/calendar_screen.dart';
import '../screens/hadith_screen.dart';
import '../screens/hisn_screen.dart';
import '../screens/names_screen.dart';
import '../screens/quran_screen.dart';
import '../services/clock.dart';
import '../services/hadith.dart';
import '../services/home_widgets.dart';
import '../services/islamic_events.dart';
import '../services/prayer_calc.dart';
import '../services/quran_text.dart';

/// Keeps the home and lock screen widgets fed, and opens the screen a tapped
/// widget points at.
class HomeWidgetSync extends StatefulWidget {
  const HomeWidgetSync({super.key, required this.child});

  final Widget child;

  @override
  State<HomeWidgetSync> createState() => _HomeWidgetSyncState();
}

class _HomeWidgetSyncState extends State<HomeWidgetSync>
    with WidgetsBindingObserver {
  StreamSubscription<Uri?>? _clicks;
  Timer? _debounce;
  String? _ayahsFor;
  String? _hadithsFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clicks = HomeWidget.widgetClicked.listen(_open, onError: (Object _) {});
    HomeWidget.initiallyLaunchedFromHomeWidget().then(
      _open,
      onError: (Object _) {},
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _schedule();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _sync);
  }

  /// Same pools all day, so unchanged data is not rewritten.
  Random _daily(int salt) {
    final now = DateTime.now();
    return Random(now.year * 1000 + now.month * 40 + now.day + salt);
  }

  Future<void> _sync() async {
    if (!mounted) return;
    final l = context.l;
    final lang = context.lang;
    final widgets = context.read<HomeWidgets>();
    final day = context.read<PrayerTimesBloc>().state.day;
    final hisn = context.read<HisnCubit>().state.book;
    final names = context.read<NamesBloc>().state.book;
    final format = (
      name: (p, d) => context.prayerName(p.name, day: d),
      clock: (p) => '${context.clock(p)} ${context.period(p)}',
    );

    final values = <String, Object?>{
      WidgetKeys.labels: {
        'rtl': context.isAr,
        'next': l.nextPrayer,
        'verse': l.widgetVerse,
        'dua': l.widgetDua,
        'name': l.namesTitle,
        'empty': l.widgetEmpty,
        'hadith': l.widgetHadith,
        'hijri': l.widgetHijri,
        'tasbih': l.featTasbih,
        'phrases': [
          l.widgetSubhanallah,
          l.widgetAlhamdulillah,
          l.widgetAllahuAkbar,
        ],
        'reset': l.widgetReset,
      },
      WidgetKeys.hijri: hijriWidgetData(appNow(), _hijriText),
      if (day != null)
        WidgetKeys.prayer: prayerWidgetData(
          day,
          DateTime.now(),
          format,
          city: context.read<SettingsCubit>().state.city.name(context.isAr),
        ),
      if (hisn != null)
        WidgetKeys.duas: duaWidgetData(hisn, lang: lang, random: _daily(2)),
      if (names != null && names.names.isNotEmpty)
        WidgetKeys.names: nameWidgetData(names, random: _daily(3)),
    };

    final today = '${DateTime.now().day}:$lang';
    if (_ayahsFor != today) {
      try {
        values[WidgetKeys.ayahs] = await ayahWidgetData(
          context.read<QuranText>(),
          lang: lang,
          digits: (n) => context.n(n),
          random: _daily(1),
        );
        _ayahsFor = today;
      } catch (_) {}
    }
    if (!mounted) return;
    if (_hadithsFor != today) {
      try {
        final repo = context.read<HadithRepository>();
        final books = [for (final b in HadithBook.values) await repo.load(b)];
        values[WidgetKeys.hadiths] = hadithWidgetData(
          books,
          lang: lang,
          random: _daily(4),
        );
        _hadithsFor = today;
      } catch (_) {}
    }
    if (!mounted) return;
    await widgets.update(values);
  }

  HijriDayText _hijriText(DateTime day) {
    final l = context.l;
    final shift = context.read<SettingsCubit>().state.hijriShift;
    final h = HijriDate.of(day, shift: shift);
    final hijri = context.isAr
        ? context.n('${h.day} ${hijriMonthsAr[h.month - 1]} ${h.year} هـ')
        : '${h.day} ${hijriMonthsEn[h.month - 1]} ${h.year} AH';
    final next = upcomingEvents(day, shift: shift, count: 1).firstOrNull;
    String? event;
    if (next != null) {
      final (e, _, date) = next;
      final days = date.difference(day).inDays;
      event = days == 0
          ? e.title(l)
          : l.widgetEventIn(e.title(l), context.n(days));
    }
    return (hijri: hijri, civil: context.date(day, 'EEEE d MMMM'), next: event);
  }

  void _open(Uri? uri) {
    if (uri == null || !mounted) return;
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    switch (uri.host) {
      case 'prayer':
        context.read<TabCubit>().select(AppTab.prayer);
      case 'ayah':
        nav.push(QuranScreen.route());
      case 'dua':
        nav.push(HisnScreen.route());
      case 'name':
        nav.push(NamesScreen.route());
      case 'hadith':
        nav.push(HadithScreen.route());
      case 'hijri':
        nav.push(CalendarScreen.route());
      case 'tasbih':
        context.read<TabCubit>().select(AppTab.tasbih);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clicks?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<PrayerTimesBloc, PrayerTimesState>(
        listenWhen: (a, b) => a.day != b.day,
        listener: (_, _) => _schedule(),
      ),
      BlocListener<HisnCubit, HisnState>(
        listenWhen: (a, b) => a.book != b.book,
        listener: (_, _) => _schedule(),
      ),
      BlocListener<NamesBloc, NamesState>(
        listenWhen: (a, b) => a.book != b.book,
        listener: (_, _) => _schedule(),
      ),
    ],
    child: widget.child,
  );
}
