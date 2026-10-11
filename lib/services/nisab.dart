/// classical: gold 87.48 g / silver 612.36 g. common: gold 85 g / silver 595 g.
enum NisabStandard { classical, common }

enum Metal { gold, silver }

class NisabThreshold {
  const NisabThreshold({
    required this.grams,
    required this.pricePerGram,
    required this.amount,
  });

  final double grams;
  final double pricePerGram;
  final double amount;

  factory NisabThreshold.fromJson(Map<String, dynamic> j) => NisabThreshold(
    grams: (j['weight'] as num).toDouble(),
    pricePerGram: (j['unit_price'] as num).toDouble(),
    amount: (j['nisab_amount'] as num).toDouble(),
  );
}

class Nisab {
  const Nisab({
    required this.standard,
    required this.currency,
    required this.gold,
    required this.silver,
    required this.rate,
    this.updatedAt,
  });

  final NisabStandard standard;
  final String currency;
  final NisabThreshold gold;
  final NisabThreshold silver;

  /// 0.025 for 2.5%.
  final double rate;
  final DateTime? updatedAt;

  NisabThreshold of(Metal m) => m == Metal.gold ? gold : silver;

  factory Nisab.fromJson(Map<String, dynamic> body) {
    final data = body['data'] as Map<String, dynamic>;
    final t = data['nisab_thresholds'] as Map<String, dynamic>;
    final rate = double.tryParse(
      '${data['zakat_rate'] ?? '2.5'}'.replaceAll('%', '').trim(),
    );
    return Nisab(
      standard: NisabStandard.values.byName(
        '${body['calculation_standard'] ?? 'classical'}',
      ),
      currency: '${body['currency'] ?? ''}'.toUpperCase(),
      gold: NisabThreshold.fromJson(t['gold'] as Map<String, dynamic>),
      silver: NisabThreshold.fromJson(t['silver'] as Map<String, dynamic>),
      rate: (rate ?? 2.5) / 100,
      updatedAt: DateTime.tryParse('${body['updated_at']}'),
    );
  }
}
