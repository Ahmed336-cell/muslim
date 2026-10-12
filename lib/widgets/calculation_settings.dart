import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../services/prayer_calc.dart';
import '../theme.dart';

const _prayerKeys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

/// Calculation method and manual adjustments, for the settings screen.
class CalculationTiles extends StatelessWidget {
  const CalculationTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<SettingsCubit>().state;
    final adjusted = s.offsets.any((o) => o != 0) || s.hijriShift != 0;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => _showMethods(context),
          leading: Icon(Icons.calculate_outlined, color: Palette.green),
          title: Text(l.calcMethod, style: Fonts.body(15)),
          subtitle: Text(
            calcMethodById(s.method).name(context.isAr),
            style: Fonts.body(13, color: Palette.inkSoft),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => _showAdjustments(context),
          leading: Icon(Icons.tune_rounded, color: Palette.green),
          title: Text(l.adjustTimes, style: Fonts.body(15)),
          subtitle: Text(
            adjusted ? l.adjustSome : l.adjustNone,
            style: Fonts.body(13, color: Palette.inkSoft),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
        ),
      ],
    );
  }
}

Future<void> _showMethods(BuildContext context) async {
  final cubit = context.read<SettingsCubit>();
  final s = cubit.state;
  final ar = context.isAr;
  final cityMethod = s.city.method;
  final picked = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .7,
      maxChildSize: .92,
      builder: (_, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(sheet.l.calcMethod, style: Fonts.display(22)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              sheet.l.calcOffline,
              style: Fonts.body(12.5, color: Palette.inkSoft),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              children: [
                for (final m in calcMethods)
                  ListTile(
                    onTap: () => Navigator.pop(sheet, m.id),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(
                      m.name(ar),
                      style: Fonts.body(
                        15.5,
                        weight: m.id == s.method
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    subtitle: m.id == cityMethod
                        ? Text(
                            sheet.l.calcCityDefault(s.city.name(ar)),
                            style: Fonts.body(12, color: Palette.green),
                          )
                        : null,
                    trailing: m.id == s.method
                        ? Icon(Icons.check_rounded, color: Palette.green)
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  if (picked != null) cubit.setMethod(picked == cityMethod ? null : picked);
}

Future<void> _showAdjustments(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: _Adjustments(),
      ),
    );

class _Adjustments extends StatelessWidget {
  const _Adjustments();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<SettingsCubit>();
    final s = context.watch<SettingsCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.adjustTimes, style: Fonts.display(22))),
            TextButton(
              onPressed: s.offsets.any((o) => o != 0) || s.hijriShift != 0
                  ? () {
                      cubit.resetOffsets();
                      cubit.setHijriShift(0);
                    }
                  : null,
              child: Text(l.reset),
            ),
          ],
        ),
        Text(l.adjustTimesSub, style: Fonts.body(12.5, color: Palette.inkSoft)),
        const SizedBox(height: 8),
        for (final (i, key) in _prayerKeys.indexed)
          _Stepper(
            label: context.prayerName(key),
            value: s.offsets[i],
            format: l.minutesOnly,
            onChanged: (v) => cubit.setOffset(i, v),
            min: -30,
            max: 30,
          ),
        const Divider(height: 24),
        _Stepper(
          label: l.hijriAdjust,
          value: s.hijriShift,
          onChanged: cubit.setHijriShift,
          min: -2,
          max: 2,
        ),
        Text(l.hijriAdjustSub, style: Fonts.body(12, color: Palette.inkSoft)),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.format,
  });

  final String label;
  final int value;
  final String Function(String n)? format;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final sign = value > 0
        ? '+'
        : value < 0
        ? '−'
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Fonts.body(15))),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: Palette.green,
          ),
          SizedBox(
            width: 56,
            child: Text(
              '$sign${format?.call(context.n(value.abs())) ?? context.n(value.abs())}',
              textAlign: TextAlign.center,
              style: Fonts.body(
                15,
                weight: FontWeight.w600,
                color: value == 0 ? Palette.inkSoft : Palette.ink,
              ),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: Palette.green,
          ),
        ],
      ),
    );
  }
}
