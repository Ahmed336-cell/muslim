import 'prayer_calc.dart';

/// Yearly occasions by Hijri date.
enum IslamicEvent {
  newYear(1, 1),
  ashura(1, 10),
  ramadan(9, 1),
  lastTen(9, 21),
  eidFitr(10, 1),
  dhulHijjah(12, 1),
  arafah(12, 9),
  eidAdha(12, 10),
  tashreeq(12, 11);

  const IslamicEvent(this.month, this.day);

  final int month;
  final int day;

  bool get isEid => this == eidFitr || this == eidAdha;

  static List<IslamicEvent> on(int month, int day) => [
    for (final e in values)
      if (e.month == month && e.day == day) e,
  ];
}

/// The white days (13th–15th), recommended for fasting.
bool isWhiteDay(int day) => day >= 13 && day <= 15;

/// The next [count] events from [today], with their civil dates.
List<(IslamicEvent, HijriDate, DateTime)> upcomingEvents(
  DateTime today, {
  int shift = 0,
  int count = 9,
}) {
  final start = DateTime(today.year, today.month, today.day);
  final year = HijriDate.of(start, shift: shift).year;
  return [
    for (final y in [year, year + 1])
      for (final e in IslamicEvent.values)
        if (HijriDate(y, e.month, e.day) case final h
            when !h.toGregorian(shift: shift).isBefore(start))
          (e, h, h.toGregorian(shift: shift)),
  ].take(count).toList();
}
