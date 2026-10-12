import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/recitation_cubit.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

const sleepMinutes = [5, 15, 30, 45, 60];

/// Off, minutes or end of surah.
Future<void> showSleepTimer(BuildContext context) {
  final cubit = context.read<RecitationCubit>();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) {
      final l = sheet.l;
      final s = cubit.state;
      void pick(VoidCallback set) {
        set();
        Navigator.pop(sheet);
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.sleepTimer, style: Fonts.display(20)),
            const SizedBox(height: 8),
            for (final m in sleepMinutes)
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l.sleepMinutes(sheet.n(m))),
                onTap: () =>
                    pick(() => cubit.setSleepTimer(Duration(minutes: m))),
              ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: Text(l.sleepEndOfSurah),
              selected: s.sleepAfterSurah,
              onTap: () => pick(cubit.sleepAfterThisSurah),
            ),
            if (s.sleepOn)
              ListTile(
                leading: const Icon(Icons.timer_off_outlined),
                title: Text(l.sleepOff),
                onTap: () => pick(() => cubit.setSleepTimer(null)),
              ),
          ],
        ),
      );
    },
  );
}

/// Time left on the sleep timer, ticking each second.
class SleepCountdown extends StatefulWidget {
  const SleepCountdown({super.key, this.style});

  final TextStyle? style;

  @override
  State<SleepCountdown> createState() => _SleepCountdownState();
}

class _SleepCountdownState extends State<SleepCountdown> {
  late final Timer _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<RecitationCubit>().state;
    final String text;
    if (s.sleepAfterSurah) {
      text = context.l.sleepEndOfSurah;
    } else if (s.sleepAt case final at?) {
      final left = at.difference(DateTime.now());
      final secs = left.isNegative ? 0 : left.inSeconds;
      text = context.n(
        '${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}',
      );
    } else {
      return const SizedBox.shrink();
    }
    return Text(text, style: widget.style);
  }
}
