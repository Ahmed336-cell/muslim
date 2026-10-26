import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/location_cubit.dart';
import '../bloc/prayer_times/prayer_times_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../services/location.dart';
import '../theme.dart';

const _prayers = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

/// On each launch, asks again when location is not allowed. After the user
/// grants it, opens a sheet to shift every prayer by hours and minutes.
class LocationPrompt extends StatefulWidget {
  const LocationPrompt({super.key, required this.child});

  final Widget child;

  @override
  State<LocationPrompt> createState() => _LocationPromptState();
}

class _LocationPromptState extends State<LocationPrompt>
    with WidgetsBindingObserver {
  var _awaitingSettings = false;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ask());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSettings) {
      _awaitingSettings = false;
      _ask();
    }
  }

  Future<void> _ask() async {
    if (!mounted || _busy) return;
    _busy = true;
    try {
      final cubit = context.read<LocationCubit>();
      if (cubit.state.grantedNow) {
        await _tune();
        return;
      }
      if (cubit.state.locating) {
        await cubit.stream.firstWhere((s) => !s.locating);
        if (!mounted) return;
        if (cubit.state.grantedNow) await _tune();
        return;
      }
      final access = await context.read<LocationService>().access();
      if (!mounted || access == LocationAccess.unknown) return;
      if (access == LocationAccess.granted) {
        if (context.read<SettingsCubit>().state.usesLocation) {
          await cubit.locate(silent: true);
        }
        return;
      }
      if (access == LocationAccess.blocked ||
          access == LocationAccess.disabled) {
        final open = await _explain(access);
        if (!mounted || open != true) return;
        _awaitingSettings = true;
        final service = context.read<LocationService>();
        if (access == LocationAccess.disabled) {
          await service.openLocationSettings();
        } else {
          await service.openSettings();
        }
        return;
      }
      await cubit.locate();
      if (!mounted || !cubit.state.grantedNow) return;
      await _tune();
    } finally {
      _busy = false;
    }
  }

  Future<bool?> _explain(LocationAccess access) {
    final l = context.l;
    return showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.useMyLocation, style: Fonts.display(22)),
        content: Text(
          access == LocationAccess.disabled ? l.locDisabled : l.locBlocked,
          style: Fonts.body(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l.stop),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.openSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _tune() async {
    final cubit = context.read<LocationCubit>();
    cubit.acknowledgeGrant();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _TuneSheet(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _TuneSheet extends StatelessWidget {
  const _TuneSheet();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final settings = context.watch<SettingsCubit>();
    final offsets = settings.state.offsets;
    final day = context.watch<PrayerTimesBloc>().state.day;
    final height = MediaQuery.sizeOf(context).height * .78;
    return SizedBox(
      height: height,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(l.adjustTimes, style: Fonts.display(22)),
          const SizedBox(height: 4),
          Text(l.adjustTimesSub, style: Fonts.body(13, color: Palette.inkSoft)),
          const SizedBox(height: 12),
          for (final (i, key) in _prayers.indexed) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.prayerName(key),
                    style: Fonts.body(16, weight: FontWeight.w600),
                  ),
                ),
                if (day != null && i < day.prayers.length)
                  Text(
                    '${context.clock(day.prayers[i])} ${context.period(day.prayers[i])}',
                    style: Fonts.mono(16, color: Palette.green),
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Nudge(
                    label: l.tuneHour,
                    onMinus: () => settings.setOffset(i, offsets[i] - 60),
                    onPlus: () => settings.setOffset(i, offsets[i] + 60),
                  ),
                ),
                Expanded(
                  child: _Nudge(
                    label: l.tuneMinute,
                    onMinus: () => settings.setOffset(i, offsets[i] - 1),
                    onPlus: () => settings.setOffset(i, offsets[i] + 1),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    _shift(context, offsets[i]),
                    textAlign: TextAlign.end,
                    style: Fonts.body(
                      14,
                      weight: FontWeight.w600,
                      color: offsets[i] == 0 ? Palette.inkSoft : Palette.ink,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.save),
            ),
          ),
        ],
      ),
    );
  }
}

class _Nudge extends StatelessWidget {
  const _Nudge({
    required this.label,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onMinus,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline_rounded),
          color: Palette.green,
        ),
        Text(label, style: Fonts.body(13, color: Palette.inkSoft)),
        IconButton(
          onPressed: onPlus,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline_rounded),
          color: Palette.green,
        ),
      ],
    );
  }
}

String _shift(BuildContext context, int minutes) {
  if (minutes == 0) return context.n(0);
  final sign = minutes > 0 ? '+' : '−';
  final abs = minutes.abs();
  final h = abs ~/ 60;
  final m = abs % 60;
  final parts = [
    if (h > 0) '${context.n(h)}${context.isAr ? 'س' : 'h'}',
    if (m > 0) '${context.n(m)}${context.isAr ? 'د' : 'm'}',
  ];
  return '$sign${parts.join(' ')}';
}
