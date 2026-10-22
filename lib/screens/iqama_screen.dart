import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../theme.dart';

/// Home imam mode: countdown to iqama so the family stands together.
class IqamaScreen extends StatefulWidget {
  const IqamaScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const IqamaScreen());

  @override
  State<IqamaScreen> createState() => _IqamaScreenState();
}

class _IqamaScreenState extends State<IqamaScreen> {
  static const _choices = [3, 5, 10, 15];
  var _minutes = 5;
  Duration? _left;
  Timer? _tick;
  var _done = false;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _start() {
    _tick?.cancel();
    setState(() {
      _done = false;
      _left = Duration(minutes: _minutes);
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = _left;
      if (left == null) return;
      if (left.inSeconds <= 1) {
        _tick?.cancel();
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
        setState(() {
          _left = Duration.zero;
          _done = true;
        });
        return;
      }
      setState(() => _left = left - const Duration(seconds: 1));
    });
  }

  void _stop() {
    _tick?.cancel();
    setState(() {
      _left = null;
      _done = false;
    });
  }

  String _clock(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final running = _left != null && !_done;

    return Scaffold(
      appBar: AppBar(title: Text(l.iqamaTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            l.iqamaIntro,
            textAlign: TextAlign.center,
            style: Fonts.body(15, color: Palette.inkSoft),
          ),
          const SizedBox(height: 28),
          if (_done) ...[
            Icon(Icons.mosque_rounded, size: 72, color: Palette.green),
            const SizedBox(height: 16),
            Text(
              l.iqamaStanding,
              textAlign: TextAlign.center,
              style: Fonts.display(28),
            ),
            const SizedBox(height: 8),
            Text(
              'قَدْ قَامَتِ الصَّلَاةُ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: Fonts.arabic(26, color: Palette.green),
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: _stop, child: Text(l.iqamaAgain)),
          ] else if (running) ...[
            Text(
              _clock(_left!),
              textAlign: TextAlign.center,
              style: Fonts.mono(64, color: Palette.green),
            ),
            const SizedBox(height: 8),
            Text(
              l.iqamaUntil,
              textAlign: TextAlign.center,
              style: Fonts.body(15, color: Palette.inkSoft),
            ),
            const SizedBox(height: 28),
            OutlinedButton(onPressed: _stop, child: Text(l.iqamaCancel)),
          ] else ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in _choices)
                  ChoiceChip(
                    label: Text(l.iqamaMinutes(context.n(m))),
                    selected: _minutes == m,
                    onSelected: (_) => setState(() => _minutes = m),
                    selectedColor: Palette.greenSoft,
                    labelStyle: Fonts.body(
                      14,
                      weight: FontWeight.w600,
                      color: _minutes == m ? Palette.green : Palette.ink,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.timer_outlined),
              label: Text(l.iqamaStart),
            ),
          ],
        ],
      ),
    );
  }
}
