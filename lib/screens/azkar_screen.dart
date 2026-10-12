import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/azkar_cubit.dart';
import '../bloc/hisn_cubit.dart';
import '../l10n/l10n.dart';
import '../services/hisn.dart';
import '../theme.dart';
import '../widgets/azkar_reminder_settings.dart';
import '../widgets/shimmer.dart';
import '../widgets/dhikr_card.dart';

/// Morning or evening adhkar, one card per dhikr; tapping a card counts it.
class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key, required this.session});

  final AzkarSession session;

  static Route<void> route(AzkarSession session) => MaterialPageRoute(
    settings: RouteSettings(name: 'azkar:${session.name}'),
    builder: (_) => AzkarScreen(session: session),
  );

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final _keys = <int, GlobalKey>{};

  AzkarSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    context.read<HisnCubit>().load();
  }

  void _tap(List<Dhikr> items, int i) {
    final result = context.read<AzkarCubit>().tap(_session, items[i], items);
    switch (result) {
      case AzkarTap.counted:
        HapticFeedback.selectionClick();
      case AzkarTap.itemDone:
        HapticFeedback.mediumImpact();
        _scrollToNext(items, i);
      case AzkarTap.sessionDone:
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l.azkarAllDone)));
    }
  }

  void _scrollToNext(List<Dhikr> items, int from) {
    final azkar = context.read<AzkarCubit>();
    final order = [
      for (var k = 1; k <= items.length; k++) (from + k) % items.length,
    ];
    final next = order.firstWhere(
      (j) => !azkar.isDone(_session, items[j]),
      orElse: () => -1,
    );
    final target = _keys[next]?.currentContext;
    if (target == null) return;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: .04,
      );
    });
  }

  Future<void> _confirmReset() async {
    final l = context.l;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l.azkarResetConfirm, style: Fonts.body(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.azkarReset),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      if (!mounted) return;
      context.read<AzkarCubit>().reset(_session);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final hisn = context.watch<HisnCubit>().state;
    final azkar = context.watch<AzkarCubit>();
    final items = hisn.book?.session(_session);

    return Scaffold(
      appBar: AppBar(
        title: Text(azkarTitle(l, _session)),
        actions: [
          IconButton(
            tooltip: l.azkarReminders,
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => showAzkarReminders(context),
          ),
          IconButton(
            tooltip: l.azkarReset,
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: items == null ? null : _confirmReset,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: items == null
          ? hisn.failed
                ? Center(
                    child: Text(
                      l.hisnLoadFailed,
                      style: Fonts.body(14, color: Palette.inkSoft),
                    ),
                  )
                : const SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        SkeletonCard(lines: 3),
                        SizedBox(height: 14),
                        SkeletonCard(lines: 3),
                        SizedBox(height: 14),
                        SkeletonCard(lines: 3),
                      ],
                    ),
                  )
          : Column(
              children: [
                _Progress(
                  done: azkar.doneIn(_session, items),
                  total: items.length,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 6, bottom: 32),
                    child: Column(
                      children: [
                        for (final (i, d) in items.indexed)
                          DhikrCard(
                            key: _keys.putIfAbsent(i, GlobalKey.new),
                            dhikr: d,
                            count: azkar.countOf(_session, d),
                            onTap: () => _tap(items, i),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                          child: Text(
                            l.hisnSource,
                            textAlign: TextAlign.center,
                            style: Fonts.body(12, color: Palette.inkSoft),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final all = done == total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: total == 0 ? 0 : done / total),
              duration: const Duration(milliseconds: 300),
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 5,
                color: Palette.green,
                backgroundColor: Palette.rule.withValues(alpha: .5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            all
                ? l.azkarAllDone
                : '${l.azkarProgress(context.n(done), context.n(total))}  ·  ${l.azkarTapHint}',
            style: Fonts.body(
              12.5,
              color: all ? Palette.green : Palette.inkSoft,
              weight: all ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
