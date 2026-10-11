import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/nisab.dart';

enum ZakatField {
  cash('Cash & bank'),
  goldGrams('Gold', unit: 'g'),
  silverGrams('Silver', unit: 'g'),
  investments('Shares & investments'),
  receivables('Money owed to you'),
  debts('Debts due now');

  const ZakatField(this.label, {this.unit});

  final String label;

  /// null = amount in the selected currency.
  final String? unit;
}

class ZakatResult {
  const ZakatResult({
    required this.net,
    required this.threshold,
    required this.due,
  });

  final double net;
  final double threshold;
  final double due;

  bool get aboveNisab => net >= threshold && net > 0;
}

final class ZakatState extends Equatable {
  const ZakatState({this.values = const {}, this.basis = Metal.silver});

  final Map<ZakatField, double> values;

  /// Which nisab wealth is measured against. Silver is the more
  /// cautious choice and is what most fatwa bodies use for cash.
  final Metal basis;

  double operator [](ZakatField f) => values[f] ?? 0;

  bool get isEmpty => values.values.every((v) => v == 0);

  ZakatResult compute(Nisab nisab) {
    final assets =
        this[ZakatField.cash] +
        this[ZakatField.investments] +
        this[ZakatField.receivables] +
        this[ZakatField.goldGrams] * nisab.gold.pricePerGram +
        this[ZakatField.silverGrams] * nisab.silver.pricePerGram;
    final net = assets - this[ZakatField.debts];
    final threshold = nisab.of(basis).amount;
    return ZakatResult(
      net: net,
      threshold: threshold,
      due: net >= threshold && net > 0 ? net * nisab.rate : 0,
    );
  }

  @override
  List<Object> get props => [values, basis];
}

class ZakatCubit extends Cubit<ZakatState> {
  ZakatCubit() : super(const ZakatState());

  void set(ZakatField field, double value) => emit(
    ZakatState(values: {...state.values, field: value}, basis: state.basis),
  );

  void setBasis(Metal basis) =>
      emit(ZakatState(values: state.values, basis: basis));

  void clear() => emit(ZakatState(basis: state.basis));
}
