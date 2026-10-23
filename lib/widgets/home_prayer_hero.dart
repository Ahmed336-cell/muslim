import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/prayer_log_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/islamic_api.dart';
import '../theme.dart';
import 'city_picker.dart';
import 'common.dart';
import 'home_sky_scene.dart';
import 'shimmer.dart';

/// Home prayer block inspired by classic prayer apps: countdown, sky scene,
/// times row (incl. sunrise), and night markers.
class HomePrayerHero extends StatelessWidget {
  const HomePrayerHero({super.key});

  @override
  Widget build(BuildContext context) {
    final day = context.watch<PrayerTimesBloc>().state.day;
    final status = context.watch<PrayerTimesBloc>().state.status;
    final error = context.watch<PrayerTimesBloc>().state.error;
    final now = context.watch<ClockCubit>().state;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, MediaQuery.paddingOf(context).top + 8, 12, 0),
      child: Material(
        color: Palette.card,
        elevation: 1.5,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: day == null
            ? SizedBox(
                height: 320,
                child: status == PrayerTimesStatus.failure
                    ? Center(
                        child: ErrorState(
                          error: error,
                          onRetry: () => context
                              .read<PrayerTimesBloc>()
                              .add(const PrayerTimesRequested()),
                        ),
                      )
                    : const CardSkeleton(lines: 4),
              )
            : _Body(day: day, now: now),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.day, required this.now});

  final PrayerDay day;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cityNow = day.cityNow(now);
    final (:next, :at, :since) = upcoming(day.prayers, cityNow);
    final night = nightMarks(day.prayers, day.following.firstOrNull, cityNow);
    final times = [
      for (final p in day.prayers)
        if (p.isObligatory || p.name == 'Sunrise') p,
    ];
    final prayed = context.watch<PrayerLogCubit>().today;
    final period = skyPeriodFor(day.prayers, cityNow);
    final (labelColor, countColor) = skyTextColors(period);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          child: HomeSkyScene(
            period: period,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: CityChip(color: labelColor),
                  ),
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 500),
                          style: Fonts.body(
                            15,
                            color: labelColor,
                            weight: FontWeight.w700,
                          ),
                          child: Text(
                            l.prayerIn(context.prayerName(next.name, day: at)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _Countdown(until: at, now: cityNow, color: countColor),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          color: Palette.paperDeep.withValues(alpha: .45),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              
              Expanded(
                child: Text(
                  [
                    context.date(cityNow, 'EEEE d MMMM'),
                    if (context.hijri(day).isNotEmpty) context.hijri(day),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Fonts.body(12.5, color: Palette.ink, weight: FontWeight.w600),
                ),
              ),
            
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
          child: Row(
            children: [
              for (final p in times)
                Expanded(
                  child: _TimeCell(
                    prayer: p,
                    name: context.prayerName(p.name, day: cityNow),
                    isNext: p.name == next.name,
                    prayed: prayed.contains(p.name),
                  ),
                ),
            ],
          ),
        ),
        if (night != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: _NightPill(
                    label: l.midnight,
                    time: _clockOf(night.midnight, context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NightPill(
                    label: l.lastThird,
                    time: _clockOf(night.lastThird, context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _clockOf(DateTime t, BuildContext context) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = '${t.minute}'.padLeft(2, '0');
    return context.n('$h:$m');
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown({
    required this.until,
    required this.now,
    required this.color,
  });

  final DateTime until;
  final DateTime now;
  final Color color;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late DateTime _now = widget.now;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void didUpdateWidget(covariant _Countdown old) {
    super.didUpdateWidget(old);
    if (old.now != widget.now) _now = widget.now;
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var left = widget.until.difference(_now);
    if (left.isNegative) left = Duration.zero;
    final h = left.inHours;
    final m = left.inMinutes.remainder(60);
    final s = left.inSeconds.remainder(60);
    final raw =
        '${'$h'.padLeft(2, '0')}:${'$m'.padLeft(2, '0')}:${'$s'.padLeft(2, '0')}';
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 500),
      style: Fonts.mono(44, color: widget.color).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        height: 1.05,
      ),
      child: Text(context.n(raw)),
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.prayer,
    required this.name,
    required this.isNext,
    required this.prayed,
  });

  final Prayer prayer;
  final String name;
  final bool isNext;
  final bool prayed;

  IconData get _icon => switch (prayer.name) {
    'Fajr' => Icons.nights_stay_outlined,
    'Sunrise' => Icons.wb_twilight_rounded,
    'Dhuhr' => Icons.wb_sunny_outlined,
    'Asr' => Icons.wb_cloudy_outlined,
    'Maghrib' => Icons.wb_twilight_rounded,
    'Isha' => Icons.dark_mode_outlined,
    _ => Icons.schedule_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final canToggle = prayer.isObligatory;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: canToggle
          ? () => context.read<PrayerLogCubit>().toggle(prayer.name)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: isNext ? Palette.greenSoft : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Fonts.body(
                11.5,
                color: isNext ? Palette.green : Palette.inkSoft,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              _icon,
              size: 20,
              color: isNext ? Palette.green : Palette.brass,
            ),
            const SizedBox(height: 4),
            Text(
              context.clock(prayer),
              style: Fonts.mono(
                13.5,
                color: isNext ? Palette.green : Palette.ink,
              ),
            ),
            if (canToggle) ...[
              const SizedBox(height: 6),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: prayed ? Palette.green : null,
                  border: Border.all(
                    color: prayed ? Palette.green : Palette.rule,
                    width: 1.4,
                  ),
                ),
                child: prayed
                    ? const Icon(Icons.check_rounded, size: 11, color: Palette.cream)
                    : null,
              ),
            ] else
              const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

class _NightPill extends StatelessWidget {
  const _NightPill({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Palette.greenSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Fonts.body(12.5, color: Palette.green, weight: FontWeight.w600),
            ),
          ),
          Text(
            time,
            style: Fonts.mono(14, color: Palette.green),
          ),
        ],
      ),
    );
  }
}

/// Soft sky + simple mosque silhouette (no asset needed).