import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../services/mushaf_pages.dart';

String _key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);

/// A plan to finish the Quran in [days] days, tracked by pages read.
final class Khatmah extends Equatable {
  const Khatmah({
    this.start,
    this.days = 30,
    this.read = const {},
    this.log = const {},
    this.completed = 0,
  });

  /// null while no plan is running.
  final DateTime? start;
  final int days;

  /// Pages read in this plan.
  final Set<int> read;

  /// Pages read per day ('yyyy-mm-dd'), across plans, for the streak.
  final Map<String, int> log;

  /// Plans finished so far.
  final int completed;

  bool get active => start != null;

  bool get done => read.length >= pageCount;

  double get progress => read.length / pageCount;

  /// The first page not read yet.
  int get nextPage {
    for (var p = 1; p <= pageCount; p++) {
      if (!read.contains(p)) return p;
    }
    return pageCount;
  }

  /// 1-based day of the plan; can pass [days] when behind.
  int dayOf(DateTime now) =>
      _date(now).difference(_date(start ?? now)).inDays + 1;

  int daysLeft(DateTime now) => (days - dayOf(now) + 1).clamp(1, days);

  int readOn(DateTime now) => log[_key(now)] ?? 0;

  /// Pages to read today so the plan ends on time, counting today's reading.
  int todayTarget(DateTime now) {
    final remaining = pageCount - read.length + readOn(now);
    return (remaining / daysLeft(now)).ceil().clamp(0, pageCount);
  }

  /// Pages that should be read by the end of today to stay on schedule.
  int expectedBy(DateTime now) =>
      (pageCount * dayOf(now) / days).ceil().clamp(0, pageCount);

  /// Pages left for today, from [nextPage].
  int leftToday(DateTime now) =>
      (todayTarget(now) - readOn(now)).clamp(0, pageCount - read.length);

  /// Today's remaining portion as (first, last) page, or null when done.
  (int, int)? portion(DateTime now) {
    final left = leftToday(now);
    if (left == 0) return null;
    final first = nextPage;
    return (first, (first + left - 1).clamp(first, pageCount));
  }

  /// Days in a row with some reading, ending today or yesterday.
  int streak(DateTime now) {
    var day = _date(now);
    if ((log[_key(day)] ?? 0) == 0) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while ((log[_key(day)] ?? 0) > 0) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  Khatmah copyWith({
    DateTime? Function()? start,
    int? days,
    Set<int>? read,
    Map<String, int>? log,
    int? completed,
  }) => Khatmah(
    start: start != null ? start() : this.start,
    days: days ?? this.days,
    read: read ?? this.read,
    log: log ?? this.log,
    completed: completed ?? this.completed,
  );

  @override
  List<Object?> get props => [start, days, read, log, completed];
}

class KhatmahCubit extends HydratedCubit<Khatmah> {
  KhatmahCubit({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(const Khatmah());

  final DateTime Function() _clock;

  static const durations = [7, 10, 15, 20, 30, 60, 90, 120, 180, 365];

  void startPlan(int days) => emit(
    state.copyWith(start: () => _date(_clock()), days: days, read: const {}),
  );

  void stop() => emit(state.copyWith(start: () => null, read: const {}));

  /// Records [page] as read; ignored when no plan is running.
  void markRead(int page) {
    if (!state.active || state.read.contains(page)) return;
    if (page < 1 || page > pageCount) return;
    final key = _key(_clock());
    final read = {...state.read, page};
    final finished = read.length >= pageCount && !state.done;
    emit(
      state.copyWith(
        read: read,
        log: {...state.log, key: (state.log[key] ?? 0) + 1},
        completed: state.completed + (finished ? 1 : 0),
      ),
    );
  }

  /// Records today's remaining portion as read.
  void readPortion() {
    if (!state.active) return;
    final range = state.portion(_clock());
    if (range == null) return;
    final (first, last) = range;
    final added = [
      for (var p = first; p <= last; p++)
        if (!state.read.contains(p)) p,
    ];
    final key = _key(_clock());
    final read = {...state.read, ...added};
    emit(
      state.copyWith(
        read: read,
        log: {...state.log, key: (state.log[key] ?? 0) + added.length},
        completed:
            state.completed + (read.length >= pageCount && !state.done ? 1 : 0),
      ),
    );
  }

  /// Marks every page up to [page] as read, e.g. when joining mid-way.
  void readUpTo(int page) {
    if (!state.active) return;
    final added = [
      for (var p = 1; p <= page.clamp(0, pageCount); p++)
        if (!state.read.contains(p)) p,
    ];
    if (added.isEmpty) return;
    final read = {...state.read, ...added};
    emit(
      state.copyWith(
        read: read,
        completed:
            state.completed + (read.length >= pageCount && !state.done ? 1 : 0),
      ),
    );
  }

  @override
  Khatmah? fromJson(Map<String, dynamic> json) {
    final start = json['start'] as String?;
    return Khatmah(
      start: start == null ? null : DateTime.tryParse(start),
      days: json['days'] as int? ?? 30,
      read: {for (final p in json['read'] as List? ?? const []) p as int},
      log: {
        for (final MapEntry(:key, :value)
            in (json['log'] as Map? ?? const {}).entries)
          key as String: value as int,
      },
      completed: json['completed'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson(Khatmah state) {
    // Keep the streak log short.
    final cutoff = _key(_clock().subtract(const Duration(days: 400)));
    return {
      'start': state.start?.toIso8601String(),
      'days': state.days,
      'read': (state.read.toList()..sort()),
      'log': {
        for (final e in state.log.entries)
          if (e.key.compareTo(cutoff) >= 0) e.key: e.value,
      },
      'completed': state.completed,
    };
  }
}
