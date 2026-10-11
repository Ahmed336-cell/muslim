import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/nisab/nisab_bloc.dart';
import 'package:muslim/bloc/zakat_cubit.dart';
import 'package:muslim/format.dart';
import 'package:muslim/services/islamic_api.dart';

final _body = {
  'calculation_standard': 'classical',
  'currency': 'egp',
  'updated_at': '2026-10-11T01:31:50+00:00',
  'data': {
    'nisab_thresholds': {
      'gold': {
        'weight': 87.48,
        'unit_price': 7063.6486,
        'nisab_amount': 617927.98,
      },
      'silver': {
        'weight': 612.36,
        'unit_price': 102.4363,
        'nisab_amount': 62727.91,
      },
    },
    'zakat_rate': '2.5%',
  },
};

class _FakeApi extends IslamicApi {
  _FakeApi() : super(apiKey: 'test');

  final calls = <String>[];

  @override
  Future<Nisab> fetchNisab({
    required NisabStandard standard,
    required String currency,
  }) async {
    calls.add('${standard.name}/$currency');
    if (currency == 'XYZ') throw const ApiException('Invalid currency code.');
    return Nisab.fromJson({
      ..._body,
      'calculation_standard': standard.name,
      'currency': currency.toLowerCase(),
    });
  }
}

void main() {
  final nisab = Nisab.fromJson(_body);

  test('parses nisab payload', () {
    expect(nisab.currency, 'EGP');
    expect(nisab.standard, NisabStandard.classical);
    expect(nisab.rate, .025);
    expect(nisab.silver.amount, 62727.91);
    expect(nisab.gold.pricePerGram, 7063.6486);
  });

  test('below silver nisab owes nothing', () {
    final s = const ZakatState(values: {ZakatField.cash: 50000});
    final r = s.compute(nisab);
    expect(r.aboveNisab, isFalse);
    expect(r.due, 0);
  });

  test('cash + gold grams minus debts, 2.5%', () {
    const s = ZakatState(
      values: {
        ZakatField.cash: 100000,
        ZakatField.goldGrams: 10,
        ZakatField.debts: 20000,
      },
    );
    final r = s.compute(nisab);
    expect(r.net, closeTo(100000 + 70636.486 - 20000, .001));
    expect(r.due, closeTo(r.net * .025, .001));
  });

  test('same wealth can be due on silver but not on gold', () {
    const silver = ZakatState(values: {ZakatField.cash: 100000});
    const gold = ZakatState(
      values: {ZakatField.cash: 100000},
      basis: Metal.gold,
    );
    expect(silver.compute(nisab).aboveNisab, isTrue);
    expect(gold.compute(nisab).aboveNisab, isFalse);
  });

  test('money formatting', () {
    expect(money(617927.98), '617,928');
    expect(money(102.4363), '102.44');
    expect(money(-1500), '−1,500');
  });

  blocTest<NisabBloc, NisabState>(
    'currency change refetches and keeps selection',
    build: () => NisabBloc(api: _FakeApi()),
    act: (b) => b.add(const NisabCurrencyChanged('USD')),
    verify: (b) {
      expect(b.state.status, NisabStatus.success);
      expect(b.state.currency, 'USD');
      expect(b.state.current?.currency, 'USD');
    },
  );

  blocTest<NisabBloc, NisabState>(
    'bad currency fails without dropping previous nisab',
    build: () => NisabBloc(api: _FakeApi()),
    seed: () => NisabState(status: NisabStatus.success, nisab: nisab),
    act: (b) => b.add(const NisabCurrencyChanged('XYZ')),
    verify: (b) {
      expect(b.state.status, NisabStatus.failure);
      expect(b.state.nisab, same(nisab));
      expect(b.state.current, isNull);
    },
  );
}
