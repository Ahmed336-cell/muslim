import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../services/islamic_events.dart';
import '../services/prayer_calc.dart';
import '../theme.dart';
import '../widgets/common.dart';

extension IslamicEventText on IslamicEvent {
  String title(L10n l) => switch (this) {
    IslamicEvent.newYear => l.evNewYear,
    IslamicEvent.ashura => l.evAshura,
    IslamicEvent.ramadan => l.evRamadan,
    IslamicEvent.lastTen => l.evLastTen,
    IslamicEvent.eidFitr => l.evEidFitr,
    IslamicEvent.dhulHijjah => l.evDhulHijjah,
    IslamicEvent.arafah => l.evArafah,
    IslamicEvent.eidAdha => l.evEidAdha,
    IslamicEvent.tashreeq => l.evTashreeq,
  };

  String subtitle(L10n l) => switch (this) {
    IslamicEvent.newYear => l.evNewYearSub,
    IslamicEvent.ashura => l.evAshuraSub,
    IslamicEvent.ramadan => l.evRamadanSub,
    IslamicEvent.lastTen => l.evLastTenSub,
    IslamicEvent.eidFitr => l.evEidFitrSub,
    IslamicEvent.dhulHijjah => l.evDhulHijjahSub,
    IslamicEvent.arafah => l.evArafahSub,
    IslamicEvent.eidAdha => l.evEidAdhaSub,
    IslamicEvent.tashreeq => l.evTashreeqSub,
  };

  IconData get icon => switch (this) {
    IslamicEvent.newYear => Icons.celebration_outlined,
    IslamicEvent.ashura || IslamicEvent.arafah => Icons.wb_sunny_outlined,
    IslamicEvent.ramadan || IslamicEvent.lastTen => Icons.nightlight_round,
    IslamicEvent.eidFitr || IslamicEvent.eidAdha => Icons.star_rounded,
    IslamicEvent.dhulHijjah ||
    IslamicEvent.tashreeq => Icons.volunteer_activism_outlined,
  };
}

String hijriMonthName(BuildContext context, int month) =>
    (context.isAr ? hijriMonthsAr : hijriMonthsEn)[month - 1];

/// A Hijri month grid with civil dates, and the coming occasions.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const CalendarScreen());

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _offset = 0;
  HijriDate? _selected;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final shift = context.watch<SettingsCubit>().state.hijriShift;
    final now = context.watch<ClockCubit>().state;
    final today = HijriDate.of(now, shift: shift);
    final month = HijriDate(today.year, today.month, 1).addMonths(_offset);
    final selected =
        _selected ??
        (_offset == 0 ? today : HijriDate(month.year, month.month, 1));
    final events = IslamicEvent.on(selected.month, selected.day);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.featCalendar),
        actions: [
          if (_offset != 0)
            TextButton(
              onPressed: () => setState(() {
                _offset = 0;
                _selected = null;
              }),
              child: Text(l.calendarToday),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Column(
              children: [
                _MonthHeader(
                  month: month,
                  shift: shift,
                  onPrevious: () => setState(() {
                    _offset--;
                    _selected = null;
                  }),
                  onNext: () => setState(() {
                    _offset++;
                    _selected = null;
                  }),
                ),
                const SizedBox(height: 8),
                _MonthGrid(
                  month: month,
                  shift: shift,
                  today: today,
                  selected: selected,
                  onSelect: (d) => setState(() => _selected = d),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: _DayDetails(day: selected, shift: shift, events: events),
          ),
          const SizedBox(height: 20),
          SectionHeader(l.calendarUpcoming),
          for (final (e, h, date) in upcomingEvents(now, shift: shift))
            _EventRow(event: e, hijri: h, date: date, now: now),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              l.calendarShiftNote,
              style: Fonts.body(12, color: Palette.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.shift,
    required this.onPrevious,
    required this.onNext,
  });

  final HijriDate month;
  final int shift;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final first = month.toGregorian(shift: shift);
    final last = HijriDate(
      month.year,
      month.month,
      month.monthLength,
    ).toGregorian(shift: shift);
    final civil = first.month == last.month
        ? context.date(first, 'MMMM y')
        : '${context.date(first, 'MMM')} – ${context.date(last, 'MMM y')}';
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
          color: Palette.green,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${hijriMonthName(context, month.month)} ${context.n(month.year)}',
                style: Fonts.display(22),
                textAlign: TextAlign.center,
              ),
              Text(civil, style: Fonts.body(12.5, color: Palette.inkSoft)),
            ],
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          color: Palette.green,
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.shift,
    required this.today,
    required this.selected,
    required this.onSelect,
  });

  final HijriDate month;
  final int shift;
  final HijriDate today;
  final HijriDate selected;
  final ValueChanged<HijriDate> onSelect;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final firstDay = loc.firstDayOfWeekIndex;
    final start = month.toGregorian(shift: shift);
    final lead = (start.weekday % 7 - firstDay + 7) % 7;
    final length = month.monthLength;
    final cells = lead + length;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    loc.narrowWeekdays[(firstDay + i) % 7],
                    style: Fonts.body(12, color: Palette.inkSoft),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var row = 0; row * 7 < cells; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: switch (row * 7 + col - lead + 1) {
                    final d when d >= 1 && d <= length => _DayCell(
                      hijri: HijriDate(month.year, month.month, d),
                      civil: DateTime(
                        start.year,
                        start.month,
                        start.day + d - 1,
                      ),
                      today: today,
                      selected: selected,
                      onTap: onSelect,
                    ),
                    _ => const SizedBox(height: 52),
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.hijri,
    required this.civil,
    required this.today,
    required this.selected,
    required this.onTap,
  });

  final HijriDate hijri;
  final DateTime civil;
  final HijriDate today;
  final HijriDate selected;
  final ValueChanged<HijriDate> onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = hijri == today;
    final isSelected = hijri == selected;
    final events = IslamicEvent.on(hijri.month, hijri.day);
    final eid = events.any((e) => e.isEid);
    final white = isWhiteDay(hijri.day);
    final fg = isToday ? Colors.white : Palette.ink;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isToday
            ? Palette.green
            : white
            ? Palette.brass.withValues(alpha: .12)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected && !isToday
              ? BorderSide(color: Palette.green, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onTap(hijri),
          child: SizedBox(
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.n(hijri.day),
                  style: Fonts.body(
                    15,
                    weight: FontWeight.w600,
                    color: eid && !isToday ? Palette.clay : fg,
                  ),
                ),
                Text(
                  context.n(civil.day),
                  style: Fonts.body(
                    10,
                    color: isToday ? Colors.white70 : Palette.inkSoft,
                  ),
                ),
                if (events.isNotEmpty)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.white : Palette.clay,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayDetails extends StatelessWidget {
  const _DayDetails({
    required this.day,
    required this.shift,
    required this.events,
  });

  final HijriDate day;
  final int shift;
  final List<IslamicEvent> events;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final civil = day.toGregorian(shift: shift);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.n(day.day)} ${hijriMonthName(context, day.month)} '
          '${context.n(day.year)}',
          style: Fonts.body(16, weight: FontWeight.w600),
        ),
        Text(
          context.date(civil, 'EEEE, d MMMM y'),
          style: Fonts.body(13, color: Palette.inkSoft),
        ),
        const SizedBox(height: 10),
        if (events.isEmpty && !isWhiteDay(day.day))
          Text(
            l.calendarNoEvents,
            style: Fonts.body(13.5, color: Palette.inkSoft),
          ),
        for (final e in events)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(e.icon, size: 20, color: Palette.clay),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title(l),
                        style: Fonts.body(14.5, weight: FontWeight.w600),
                      ),
                      Text(
                        e.subtitle(l),
                        style: Fonts.body(13, color: Palette.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (isWhiteDay(day.day))
          Text(
            l.calendarWhiteDays,
            style: Fonts.body(13, color: Palette.brass),
          ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.hijri,
    required this.date,
    required this.now,
  });

  final IslamicEvent event;
  final HijriDate hijri;
  final DateTime date;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final days = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: CircleAvatar(
        backgroundColor: Palette.green.withValues(alpha: .1),
        child: Icon(event.icon, color: Palette.green, size: 20),
      ),
      title: Text(event.title(l), style: Fonts.body(15)),
      subtitle: Text(
        '${context.n(hijri.day)} ${hijriMonthName(context, hijri.month)}'
        '  ·  ${context.date(date, 'EEE d MMM y')}',
        style: Fonts.body(12.5, color: Palette.inkSoft),
      ),
      trailing: Text(
        context.n(l.calendarInDays(days)),
        style: Fonts.body(12.5, color: Palette.green, weight: FontWeight.w600),
      ),
    );
  }
}
