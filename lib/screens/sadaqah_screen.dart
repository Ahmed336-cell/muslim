import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clock_cubit.dart';
import '../bloc/extra_reminders_cubit.dart';
import '../bloc/sadaqah_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/extra_reminder_tile.dart';

String _money(double v) =>
    v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

extension on SadaqahKind {
  IconData get icon => switch (this) {
    SadaqahKind.money => Icons.payments_outlined,
    SadaqahKind.food => Icons.restaurant_rounded,
    SadaqahKind.help => Icons.handshake_outlined,
    SadaqahKind.other => Icons.favorite_border_rounded,
  };

  String label(L10n l) => switch (this) {
    SadaqahKind.money => l.sadaqahMoney,
    SadaqahKind.food => l.sadaqahFood,
    SadaqahKind.help => l.sadaqahHelp,
    SadaqahKind.other => l.sadaqahOther,
  };
}

/// Private sadaqah log with a monthly goal and a Friday reminder.
class SadaqahScreen extends StatelessWidget {
  const SadaqahScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const SadaqahScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final log = context.watch<SadaqahCubit>().state;
    final now = context.watch<ClockCubit>().state;
    final currency = context.select((SettingsCubit c) => c.state.city.currency);
    final month = log.totalIn(now);
    final count = log.inMonth(now).length;
    final goal = log.monthlyGoal;
    final loc = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.featSadaqah)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, currency),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.sadaqahAdd),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Caption(loc.formatMonthYear(now)),
                const SizedBox(height: 8),
                Text(
                  '${context.n(_money(month))} $currency',
                  style: Fonts.display(30),
                ),
                const SizedBox(height: 4),
                Text(
                  l.sadaqahCount(context.n(count)),
                  style: Fonts.body(13.5, color: Palette.inkSoft),
                ),
                if (goal > 0) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (month / goal).clamp(0, 1),
                      minHeight: 8,
                      color: Palette.green,
                      backgroundColor: Palette.green.withValues(alpha: .12),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => _setGoal(context, goal, currency),
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: Text(
                    goal > 0
                        ? l.sadaqahGoalOf(context.n(_money(goal)), currency)
                        : l.sadaqahSetGoal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: Palette.clay),
                const SizedBox(width: 12),
                Expanded(child: Text(l.sadaqahStreak, style: Fonts.body(15))),
                Text(
                  l.sadaqahWeeks(context.n(log.weekStreak(now))),
                  style: Fonts.body(15, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const AppCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ExtraReminderTile(ExtraKind.sadaqah),
                ExtraRemindersDenied(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              l.sadaqahHadith,
              textAlign: TextAlign.center,
              style: Fonts.body(13, color: Palette.inkSoft),
            ),
          ),
          if (log.entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l.sadaqahEmpty,
                textAlign: TextAlign.center,
                style: Fonts.body(14, color: Palette.inkSoft),
              ),
            )
          else ...[
            SectionHeader(l.sadaqahHistory),
            for (final e in log.entries.take(200))
              Dismissible(
                key: ValueKey(e),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Palette.clay.withValues(alpha: .15),
                  child: Icon(Icons.delete_outline, color: Palette.clay),
                ),
                onDismissed: (_) => context.read<SadaqahCubit>().remove(e),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Palette.greenSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(e.kind.icon, color: Palette.green, size: 20),
                  ),
                  title: Text(
                    e.note.isEmpty ? e.kind.label(l) : e.note,
                    style: Fonts.body(15),
                  ),
                  subtitle: Text(
                    context.n(loc.formatMediumDate(e.date)),
                    style: Fonts.body(12.5, color: Palette.inkSoft),
                  ),
                  trailing: e.amount > 0
                      ? Text(
                          '${context.n(_money(e.amount))} $currency',
                          style: Fonts.body(14, weight: FontWeight.w600),
                        )
                      : null,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _setGoal(
    BuildContext context,
    double goal,
    String currency,
  ) async {
    final l = context.l;
    final cubit = context.read<SadaqahCubit>();
    final value = await showAmountDialog(
      context,
      title: l.sadaqahGoalTitle,
      initial: goal > 0 ? _money(goal) : '',
      currency: currency,
      clearLabel: l.sadaqahNoGoal,
      clearValue: 0,
    );
    if (value != null) cubit.setGoal(value);
  }

  void _add(BuildContext context, String currency) {
    final cubit = context.read<SadaqahCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _AddSheet(currency: currency),
      ),
    );
  }
}

class _AddSheet extends StatefulWidget {
  const _AddSheet({required this.currency});

  final String currency;

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  var _kind = SadaqahKind.money;
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    context.read<SadaqahCubit>().add(
      _kind,
      amount: double.tryParse(_amount.text) ?? 0,
      note: _note.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.sadaqahAdd, style: Fonts.display(20)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in SadaqahKind.values)
                ChoiceChip(
                  avatar: Icon(k.icon, size: 18),
                  label: Text(k.label(l)),
                  selected: k == _kind,
                  onSelected: (_) => setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText: l.sadaqahAmount,
              suffixText: widget.currency,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _note,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.sadaqahNote),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: _save, child: Text(l.save)),
          const SizedBox(height: 6),
          Text(
            l.sadaqahPrivate,
            textAlign: TextAlign.center,
            style: Fonts.body(12, color: Palette.inkSoft),
          ),
        ],
      ),
    );
  }
}
