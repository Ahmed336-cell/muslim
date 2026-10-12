import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/nisab/nisab_bloc.dart';
import '../bloc/zakat_cubit.dart';
import '../format.dart';
import '../l10n/l10n.dart';
import '../services/islamic_api.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';
import '../widgets/star_pattern.dart';

const _currencies = [
  'EGP', 'SAR', 'AED', 'KWD', 'QAR', 'JOD', 'MAD', 'TRY', 'PKR', //
  'INR', 'BDT', 'IDR', 'MYR', 'USD', 'EUR', 'GBP', 'CAD', 'AUD',
];

class ZakatScreen extends StatelessWidget {
  const ZakatScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const ZakatScreen());

  Future<void> _pickCurrency(BuildContext context, String current) async {
    final picked = await showModalBottomSheet<String>(
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(sheet.l.currency, style: Fonts.display(22)),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  for (final code in _currencies)
                    ListTile(
                      onTap: () => Navigator.pop(sheet, code),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      title: Text(
                        sheet.currencyName(code),
                        style: Fonts.body(
                          16,
                          weight: code == current
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      trailing: Text(
                        code,
                        style: Fonts.mono(
                          13,
                          color: code == current
                              ? Palette.green
                              : Palette.inkSoft,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null && picked != current && context.mounted) {
      context.read<NisabBloc>().add(NisabCurrencyChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final currency = context.select((NisabBloc b) => b.state.currency);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.zakatTitle),
        actions: [
          ActionChip(
            onPressed: () => _pickCurrency(context, currency),
            backgroundColor: Palette.card,
            side: BorderSide(color: Palette.rule),
            shape: const StadiumBorder(),
            avatar: Icon(
              Icons.currency_exchange_rounded,
              size: 18,
              color: Palette.green,
            ),
            label: Text(currency, style: Fonts.mono(13)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: 4, bottom: 32),
          children: const [
            _StandardToggle(),
            SizedBox(height: 16),
            _NisabPanel(),
            SizedBox(height: 24),
            _Inputs(),
            SizedBox(height: 20),
            _Result(),
            SizedBox(height: 16),
            _Footnote(),
          ],
        ),
      ),
    );
  }
}

class _StandardToggle extends StatelessWidget {
  const _StandardToggle();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final standard = context.select((NisabBloc b) => b.state.standard);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<NisabStandard>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: NisabStandard.classical,
            label: Text(l.standardClassical),
          ),
          ButtonSegment(
            value: NisabStandard.common,
            label: Text(l.standardCommon),
          ),
        ],
        selected: {standard},
        onSelectionChanged: (s) =>
            context.read<NisabBloc>().add(NisabStandardChanged(s.first)),
      ),
    );
  }
}

class _NisabPanel extends StatelessWidget {
  const _NisabPanel();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<NisabBloc>().state;
    final basis = context.select((ZakatCubit c) => c.state.basis);
    final nisab = state.nisab;

    if (nisab == null) {
      return SizedBox(
        height: 150,
        child: state.status == NisabStatus.failure
            ? Center(
                child: ErrorState(
                  error: state.error,
                  onRetry: () =>
                      context.read<NisabBloc>().add(const NisabRequested()),
                ),
              )
            : const Padding(padding: EdgeInsets.all(16), child: CardSkeleton()),
      );
    }

    final stale = state.current == null;
    final updated = nisab.updatedAt?.toLocal();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Caption(l.nisabToday),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: stale ? .4 : 1,
            child: Row(
              children: [
                for (final m in Metal.values) ...[
                  if (m != Metal.values.first) const SizedBox(width: 10),
                  Expanded(
                    child: _MetalTile(
                      metal: m,
                      threshold: nisab.of(m),
                      selected: basis == m,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Text(
              state.status == NisabStatus.failure
                  ? context.error(state.error)
                  : updated == null
                  ? ''
                  : l.priceAsOf(context.date(updated, 'd MMM, HH:mm')),
              style: Fonts.body(
                12,
                color: state.status == NisabStatus.failure
                    ? Palette.clay
                    : Palette.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetalTile extends StatelessWidget {
  const _MetalTile({
    required this.metal,
    required this.threshold,
    required this.selected,
  });

  final Metal metal;
  final NisabThreshold threshold;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final gold = metal == Metal.gold;
    return Material(
      color: selected ? Palette.greenSoft : Palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? Palette.green : Palette.rule,
          width: selected ? 1.4 : .7,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.read<ZakatCubit>().setBasis(metal),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gold ? Palette.brass : const Color(0xFF9EA3A0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gold ? l.gold : l.silver,
                      style: Fonts.body(14, weight: FontWeight.w500),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Palette.green,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.n(money(threshold.amount)),
                  style: Fonts.display(26),
                ),
              ),
              Text(
                l.gramsTimes(
                  context.n(threshold.grams),
                  context.n(money(threshold.pricePerGram)),
                ),
                style: Fonts.body(11.5, color: Palette.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Inputs extends StatelessWidget {
  const _Inputs();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final currency = context.select((NisabBloc b) => b.state.currency);
    final owned = ZakatField.values.where((f) => f != ZakatField.debts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          l.whatYouOwn,
          action: l.clear,
          onAction: () => context.read<ZakatCubit>().clear(),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final (i, f) in owned.indexed) ...[
                if (i > 0) const Divider(),
                _AmountRow(field: f, currency: currency),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(l.whatYouOwe),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _AmountRow(field: ZakatField.debts, currency: currency),
        ),
      ],
    );
  }
}

class _AmountRow extends StatefulWidget {
  const _AmountRow({required this.field, required this.currency});

  final ZakatField field;
  final String currency;

  @override
  State<_AmountRow> createState() => _AmountRowState();
}

class _AmountRowState extends State<_AmountRow> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _label(L10n l) => switch (widget.field) {
    ZakatField.cash => l.fieldCash,
    ZakatField.goldGrams => l.fieldGold,
    ZakatField.silverGrams => l.fieldSilver,
    ZakatField.investments => l.fieldInvestments,
    ZakatField.receivables => l.fieldReceivables,
    ZakatField.debts => l.fieldDebts,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return BlocListener<ZakatCubit, ZakatState>(
      listenWhen: (a, b) => b.isEmpty && !a.isEmpty,
      listener: (_, _) => _controller.clear(),
      child: Row(
        children: [
          Expanded(child: Text(_label(l), style: Fonts.body(15))),
          SizedBox(
            width: 130,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.end,
              textDirection: TextDirection.ltr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: Fonts.mono(16),
              cursorColor: Palette.clay,
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: '0',
                hintStyle: Fonts.mono(16, color: Palette.rule),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onChanged: (v) => context.read<ZakatCubit>().set(
                widget.field,
                double.tryParse(v) ?? 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              widget.field.unit == null ? widget.currency : l.gramsUnit,
              style: Fonts.body(12, color: Palette.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final nisab = context.select((NisabBloc b) => b.state.current);
    final zakat = context.watch<ZakatCubit>().state;
    final result = nisab == null ? null : zakat.compute(nisab);
    final metal = zakat.basis == Metal.gold ? l.goldLower : l.silverLower;
    String m(double v) => context.n(money(v));

    final String headline;
    final String detail;
    if (result == null) {
      headline = '—';
      detail = l.waitingNisab;
    } else if (zakat.isEmpty) {
      headline = l.addWhatYouOwn;
      detail = l.privacyNote;
    } else if (!result.aboveNisab) {
      headline = l.noZakat;
      detail = l.belowNisab(m(result.net), metal, m(result.threshold));
    } else {
      headline = '${m(result.due)} ${nisab!.currency}';
      detail = l.aboveNisab(m(result.net), metal, m(result.threshold));
    }

    return AppCard(
      color: Palette.ink,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const PositionedDirectional(
            end: -30,
            top: -30,
            bottom: -30,
            width: 140,
            child: StarPattern(color: Color(0x22B0812F), cell: 40),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Caption(l.zakatDue, color: Palette.brass),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    headline,
                    style: Fonts.display(34, color: Palette.cream),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: Fonts.body(
                    13,
                    color: Palette.cream.withValues(alpha: .7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        context.l.zakatFootnote,
        style: Fonts.body(12, color: Palette.inkSoft).copyWith(height: 1.6),
      ),
    );
  }
}
