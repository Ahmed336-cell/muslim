/// 617927.98 → "617,928"; small values keep decimals: 12.5 → "12.50".
String money(double v) {
  final abs = v.abs();
  final fixed = abs >= 1000 ? abs.round().toString() : abs.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => ',',
  );
  final out = parts.length > 1 ? '$whole.${parts[1]}' : whole;
  return v < 0 ? '−$out' : out;
}
