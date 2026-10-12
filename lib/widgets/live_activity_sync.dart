import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/live_activity_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../services/islamic_api.dart';
import '../services/live_activity.dart';

/// Keeps the Live Activity on the next prayer while the app runs; in the
/// background it shows the prayer as due once its time passes.
class LiveActivitySync extends StatefulWidget {
  const LiveActivitySync({super.key, required this.child});

  final Widget child;

  @override
  State<LiveActivitySync> createState() => _LiveActivitySyncState();
}

class _LiveActivitySyncState extends State<LiveActivitySync> {
  String? _shown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  /// Wall-clock time in the city to an instant.
  static DateTime _instant(PrayerDay day, DateTime cityTime) {
    final offset = day.utcOffset;
    if (offset == null) return cityTime;
    return DateTime.utc(
      cityTime.year,
      cityTime.month,
      cityTime.day,
      cityTime.hour,
      cityTime.minute,
    ).subtract(offset);
  }

  Future<void> _sync() async {
    if (!mounted) return;
    final live = context.read<LiveActivity>();
    if (!live.supported) return;
    final day = context.read<PrayerTimesBloc>().state.day;
    if (!context.read<LiveActivityCubit>().state) {
      if (_shown != null) {
        _shown = null;
        await live.end();
      }
      return;
    }
    if (day == null) return;

    final cityNow = day.cityNow(context.read<ClockCubit>().state);
    final (:next, :at, :since) = upcoming(day.prayers, cityNow);
    final key = '${next.name}$at${context.lang}';
    if (key == _shown) return;
    _shown = key;
    final l = context.l;
    await live.show(
      name: context.prayerName(next.name, day: at),
      clock: '${context.clock(next)} ${context.period(next)}',
      at: _instant(day, at),
      since: _instant(day, since),
      label: l.nextPrayer,
      nowLabel: l.liveNow,
      city: context.read<SettingsCubit>().state.city.name(context.isAr),
      rtl: context.isAr,
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<LiveActivityCubit, bool>(listener: (_, _) => _sync()),
      BlocListener<PrayerTimesBloc, PrayerTimesState>(
        listenWhen: (a, b) => a.day != b.day,
        listener: (_, _) => _sync(),
      ),
      BlocListener<ClockCubit, DateTime>(listener: (_, _) => _sync()),
    ],
    child: widget.child,
  );
}
