/// Confirmed sunnah rawatib linked to each obligatory prayer.
/// Counts are rak'ahs; [before] then [after].
class Rawatib {
  const Rawatib({required this.before, required this.after});

  final int before;
  final int after;

  bool get isEmpty => before == 0 && after == 0;
}

/// Mu'akkadah rawatib most schools agree on.
const rawatibOf = <String, Rawatib>{
  'Fajr': Rawatib(before: 2, after: 0),
  'Dhuhr': Rawatib(before: 4, after: 2),
  'Asr': Rawatib(before: 0, after: 0),
  'Maghrib': Rawatib(before: 0, after: 2),
  'Isha': Rawatib(before: 0, after: 2),
};

Rawatib? rawatibFor(String prayer) => rawatibOf[prayer];
