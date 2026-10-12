/// Short ayahs that stand on their own, one shown per day.
const dailyAyahs = <(int, int)>[
  (2, 152), (2, 153), (2, 186), (2, 201), (2, 286), (3, 8), //
  (3, 139), (3, 173), (3, 200), (7, 56), (9, 51), (13, 28),
  (14, 7), (16, 97), (16, 128), (18, 10), (25, 74), (29, 69),
  (33, 41), (39, 53), (40, 60), (47, 7), (49, 10), (51, 56),
  (55, 60), (59, 18), (65, 3), (93, 3), (93, 5), (94, 5),
];

class Hadith {
  const Hadith(this.ar, this.en, this.sourceAr, this.sourceEn);

  final String ar;
  final String en;
  final String sourceAr;
  final String sourceEn;

  String text(String lang) => lang == 'ar' ? ar : en;
  String source(String lang) => lang == 'ar' ? sourceAr : sourceEn;
}

const _bm = ('متفق عليه', 'Al-Bukhari & Muslim');
const _b = ('رواه البخاري', 'Al-Bukhari');
const _m = ('رواه مسلم', 'Muslim');
const _t = ('رواه الترمذي', 'At-Tirmidhi');
const _dt = ('رواه أبو داود والترمذي', 'Abu Dawud & At-Tirmidhi');

Hadith _h(String ar, String en, (String, String) src) =>
    Hadith(ar, en, src.$1, src.$2);

/// Short, well-known sahih and hasan hadith, one shown per day.
final dailyHadith = [
  _h(
    'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى',
    'Actions are only by intentions, and every person will have only what they intended.',
    _bm,
  ),
  _h(
    'لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه',
    'None of you truly believes until he loves for his brother what he loves for himself.',
    _bm,
  ),
  _h(
    'من كان يؤمن بالله واليوم الآخر فليقل خيرًا أو ليصمت',
    'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
    _bm,
  ),
  _h(
    'من حسن إسلام المرء تركه ما لا يعنيه',
    'Part of the excellence of a person’s Islam is leaving what does not concern him.',
    _t,
  ),
  _h('لا تغضب', 'Do not become angry.', _b),
  _h('الكلمة الطيبة صدقة', 'A good word is charity.', _bm),
  _h(
    'تبسمك في وجه أخيك لك صدقة',
    'Your smile in the face of your brother is charity.',
    _t,
  ),
  _h(
    'خيركم من تعلم القرآن وعلمه',
    'The best of you are those who learn the Quran and teach it.',
    _b,
  ),
  _h('الطهور شطر الإيمان', 'Purity is half of faith.', _m),
  _h(
    'اتق الله حيثما كنت، وأتبع السيئة الحسنة تمحها، وخالق الناس بخلق حسن',
    'Fear Allah wherever you are, follow a bad deed with a good one and it will erase it, and treat people with good character.',
    _t,
  ),
  _h(
    'أحب الأعمال إلى الله أدومها وإن قل',
    'The most beloved deeds to Allah are the most constant, even if small.',
    _bm,
  ),
  _h('الدين النصيحة', 'The religion is sincere counsel.', _m),
  _h(
    'المسلم من سلم المسلمون من لسانه ويده',
    'The Muslim is the one from whose tongue and hand the Muslims are safe.',
    _bm,
  ),
  _h(
    'ليس الشديد بالصرعة، إنما الشديد الذي يملك نفسه عند الغضب',
    'The strong one is not the one who wrestles others down, but the one who controls himself when angry.',
    _bm,
  ),
  _h(
    'من سلك طريقًا يلتمس فيه علمًا سهل الله له به طريقًا إلى الجنة',
    'Whoever takes a path seeking knowledge, Allah makes easy for him a path to Paradise.',
    _m,
  ),
  _h(
    'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن: سبحان الله وبحمده، سبحان الله العظيم',
    'Two words are light on the tongue, heavy on the Scale and beloved to the Most Merciful: SubhanAllahi wa bihamdihi, SubhanAllahil-Azim.',
    _bm,
  ),
  _h('ما نقصت صدقة من مال', 'Charity never decreases wealth.', _m),
  _h(
    'الراحمون يرحمهم الرحمن، ارحموا من في الأرض يرحمكم من في السماء',
    'The merciful are shown mercy by the Most Merciful. Be merciful to those on earth, and the One above the heavens will have mercy on you.',
    _dt,
  ),
  _h(
    'من لا يشكر الناس لا يشكر الله',
    'Whoever does not thank people does not thank Allah.',
    _dt,
  ),
  _h(
    'إن الله رفيق يحب الرفق في الأمر كله',
    'Allah is Gentle and loves gentleness in every matter.',
    _bm,
  ),
  _h(
    'أكمل المؤمنين إيمانًا أحسنهم خلقًا',
    'The most complete of the believers in faith are those with the best character.',
    _dt,
  ),
  _h(
    'يسروا ولا تعسروا، وبشروا ولا تنفروا',
    'Make things easy and do not make them hard; give glad tidings and do not drive people away.',
    _bm,
  ),
  _h(
    'من صلى البردين دخل الجنة',
    'Whoever prays the two cool prayers (Fajr and Asr) will enter Paradise.',
    _bm,
  ),
  _h(
    'أقرب ما يكون العبد من ربه وهو ساجد، فأكثروا الدعاء',
    'A servant is closest to his Lord while prostrating, so make plenty of supplication.',
    _m,
  ),
  _h('الدعاء هو العبادة', 'Supplication is worship.', _dt),
  _h(
    'اقرؤوا القرآن فإنه يأتي يوم القيامة شفيعًا لأصحابه',
    'Read the Quran, for it will come on the Day of Resurrection as an intercessor for its companions.',
    _m,
  ),
  _h(
    'كن في الدنيا كأنك غريب أو عابر سبيل',
    'Be in this world as if you were a stranger or a traveller.',
    _b,
  ),
  _h(
    'إن الله لا ينظر إلى صوركم وأموالكم، ولكن ينظر إلى قلوبكم وأعمالكم',
    'Allah does not look at your appearance or your wealth, but He looks at your hearts and your deeds.',
    _m,
  ),
  _h(
    'من دل على خير فله مثل أجر فاعله',
    'Whoever guides someone to good will have a reward like the one who does it.',
    _m,
  ),
];

int _dayIndex(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

(int, int) ayahOfDay(DateTime day) =>
    dailyAyahs[_dayIndex(day) % dailyAyahs.length];

/// Offset so the ayah and hadith don't cycle in step.
Hadith hadithOfDay(DateTime day) =>
    dailyHadith[(_dayIndex(day) * 7 + 3) % dailyHadith.length];
