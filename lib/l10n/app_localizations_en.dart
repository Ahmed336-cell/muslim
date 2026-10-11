// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Muslim';

  @override
  String get navHome => 'Home';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navTasbih => 'Tasbih';

  @override
  String get navMore => 'More';

  @override
  String get retry => 'Try again';

  @override
  String get errMissingKey =>
      'The API key is missing. Run the app with --dart-define-from-file=env.json';

  @override
  String get errNetwork => 'Couldn\'t reach the server. Check your connection.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get refreshFailed => 'Couldn\'t refresh';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get listen => 'Listen';

  @override
  String get stop => 'Stop';

  @override
  String get seeAll => 'See all';

  @override
  String noMatch(String query) {
    return 'Nothing matches “$query”.';
  }

  @override
  String get am => 'am';

  @override
  String get pm => 'pm';

  @override
  String hoursMinutes(String h, String m) {
    return '${h}h ${m}m';
  }

  @override
  String minutesOnly(String m) {
    return '${m}m';
  }

  @override
  String get hijriSuffix => 'AH';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get jumuah => 'Jumu\'ah';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get greeting => 'Assalamu alaikum';

  @override
  String get nextPrayer => 'Next prayer';

  @override
  String inDuration(String d) {
    return 'in $d';
  }

  @override
  String get explore => 'Explore';

  @override
  String get todayPrayers => 'Today\'s prayers';

  @override
  String prayedCount(String n) {
    return '$n of 5 prayed';
  }

  @override
  String get verseTitle => 'A verse for today';

  @override
  String get verseTranslation =>
      '“For indeed, with hardship comes ease. Indeed, with hardship comes ease.”';

  @override
  String get verseRef => 'Ash-Sharh 94:5–6';

  @override
  String get nameOfDay => 'A name to reflect on';

  @override
  String get allNames => 'All 99 names';

  @override
  String get duaOfDay => 'A dua for today';

  @override
  String get allDuas => 'Duas for every occasion';

  @override
  String get featPrayer => 'Prayer times';

  @override
  String get featPrayerSub => 'Times, tracker and fasting';

  @override
  String get featQuran => 'Quran';

  @override
  String get featQuranSub => 'All 114 surahs';

  @override
  String get featQibla => 'Qibla';

  @override
  String get featQiblaSub => 'Direction to the Kaaba';

  @override
  String get featTasbih => 'Tasbih';

  @override
  String get featTasbihSub => 'Adhkar after salah';

  @override
  String get featDuas => 'Duas';

  @override
  String get featDuasSub => 'For every occasion';

  @override
  String get featNames => '99 Names';

  @override
  String get featNamesSub => 'Meanings and recitation';

  @override
  String get featZakat => 'Zakat';

  @override
  String get featZakatSub => 'Calculator with today\'s nisab';

  @override
  String get featRuqyah => 'Ruqyah';

  @override
  String get featRuqyahSub => 'Protection and healing';

  @override
  String get featFasting => 'Fasting';

  @override
  String get featFastingSub => 'Sahur, iftar and white days';

  @override
  String get prayerTitle => 'Prayer times';

  @override
  String get changeCity => 'Change city';

  @override
  String get trackerHint => 'Tap the circle once you\'ve prayed.';

  @override
  String get nextBadge => 'Next';

  @override
  String get allPrayed => 'All five prayed today. May Allah accept it.';

  @override
  String get fastingTitle => 'Fasting';

  @override
  String get sahurEnds => 'Sahur ends';

  @override
  String get iftar => 'Iftar';

  @override
  String fastLength(String d) {
    return '$d from dawn to sunset';
  }

  @override
  String get sunnahMonday => 'Tomorrow is Monday — a sunnah fast.';

  @override
  String get sunnahThursday => 'Tomorrow is Thursday — a sunnah fast.';

  @override
  String get whiteDays => 'White days';

  @override
  String get whiteDaysHint => 'The 13th, 14th and 15th of every Hijri month.';

  @override
  String get approx => 'approx.';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get kmToKaaba => 'km to the Kaaba';

  @override
  String get facingQibla => 'You\'re facing the Qibla';

  @override
  String turnRight(String deg) {
    return 'Turn right $deg°';
  }

  @override
  String turnLeft(String deg) {
    return 'Turn left $deg°';
  }

  @override
  String get dragHint => 'Drag the dial to line it up';

  @override
  String get compassN => 'N';

  @override
  String get compassE => 'E';

  @override
  String get compassS => 'S';

  @override
  String get compassW => 'W';

  @override
  String get dirN => 'North';

  @override
  String get dirNE => 'Northeast';

  @override
  String get dirE => 'East';

  @override
  String get dirSE => 'Southeast';

  @override
  String get dirS => 'South';

  @override
  String get dirSW => 'Southwest';

  @override
  String get dirW => 'West';

  @override
  String get dirNW => 'Northwest';

  @override
  String get tasbihTitle => 'Tasbih';

  @override
  String get reset => 'Reset';

  @override
  String afterSalah(String i, String n) {
    return 'After salah · $i of $n';
  }

  @override
  String get tapToCount => 'Tap anywhere to count';

  @override
  String todayTotal(String n) {
    return '$n today';
  }

  @override
  String get setComplete => 'Adhkar complete — may Allah accept them.';

  @override
  String get zakatTitle => 'Zakat';

  @override
  String get currency => 'Currency';

  @override
  String get standardClassical => 'Classical';

  @override
  String get standardCommon => 'Common';

  @override
  String get nisabToday => 'Today\'s nisab — tap one to measure against';

  @override
  String get gold => 'Gold';

  @override
  String get silver => 'Silver';

  @override
  String get goldLower => 'gold';

  @override
  String get silverLower => 'silver';

  @override
  String gramsTimes(String g, String price) {
    return '$g g × $price';
  }

  @override
  String priceAsOf(String date) {
    return 'Market price as of $date';
  }

  @override
  String get whatYouOwn => 'What you own';

  @override
  String get whatYouOwe => 'What you owe';

  @override
  String get clear => 'Clear';

  @override
  String get fieldCash => 'Cash & bank';

  @override
  String get fieldGold => 'Gold';

  @override
  String get fieldSilver => 'Silver';

  @override
  String get fieldInvestments => 'Shares & investments';

  @override
  String get fieldReceivables => 'Money owed to you';

  @override
  String get fieldDebts => 'Debts due now';

  @override
  String get gramsUnit => 'g';

  @override
  String get zakatDue => 'Zakat due';

  @override
  String get waitingNisab => 'Waiting for today\'s nisab…';

  @override
  String get addWhatYouOwn => 'Add what you own';

  @override
  String get privacyNote => 'Nothing you enter leaves your phone.';

  @override
  String get noZakat => 'No zakat due';

  @override
  String belowNisab(String net, String metal, String threshold) {
    return 'You hold $net, below the $metal nisab of $threshold.';
  }

  @override
  String aboveNisab(String net, String metal, String threshold) {
    return '2.5% of $net — above the $metal nisab of $threshold.';
  }

  @override
  String get zakatFootnote =>
      'Zakat is due once a full lunar year (hawl) has passed while your wealth stayed above the nisab. Gold and silver are valued at the pure (24k) market price. For business stock, property or complex cases, ask a scholar you trust.';

  @override
  String get curEGP => 'Egyptian pound';

  @override
  String get curSAR => 'Saudi riyal';

  @override
  String get curAED => 'UAE dirham';

  @override
  String get curKWD => 'Kuwaiti dinar';

  @override
  String get curQAR => 'Qatari riyal';

  @override
  String get curJOD => 'Jordanian dinar';

  @override
  String get curMAD => 'Moroccan dirham';

  @override
  String get curTRY => 'Turkish lira';

  @override
  String get curPKR => 'Pakistani rupee';

  @override
  String get curINR => 'Indian rupee';

  @override
  String get curBDT => 'Bangladeshi taka';

  @override
  String get curIDR => 'Indonesian rupiah';

  @override
  String get curMYR => 'Malaysian ringgit';

  @override
  String get curUSD => 'US dollar';

  @override
  String get curEUR => 'Euro';

  @override
  String get curGBP => 'British pound';

  @override
  String get curCAD => 'Canadian dollar';

  @override
  String get curAUD => 'Australian dollar';

  @override
  String get quranTitle => 'Quran';

  @override
  String get quranSearch => 'Surah name, meaning or number';

  @override
  String ayahCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ayahs',
      one: '1 ayah',
    );
    return '$_temp0';
  }

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String get quranSummary => '114 surahs · 6,236 ayahs';

  @override
  String get lastRead => 'Last read';

  @override
  String get markLastRead => 'Mark as last read';

  @override
  String get markedLastRead => 'Saved as last read';

  @override
  String get surahNumber => 'Surah';

  @override
  String get revelation => 'Revelation';

  @override
  String get ayahs => 'Ayahs';

  @override
  String get namesTitle => 'Names of Allah';

  @override
  String get namesSearch => 'Search a name or meaning';

  @override
  String get hearIt => 'Hear it';

  @override
  String get duasTitle => 'Duas';

  @override
  String get duasSubtitle => 'Supplications from the Quran and Sunnah';

  @override
  String duasCount(String duas, String topics) {
    return '$duas supplications in $topics topics';
  }

  @override
  String get duasSearch => 'Travel, rain, anxiety, sleep…';

  @override
  String get duasLoading => 'Fetching about a thousand duas…';

  @override
  String noDuaMatch(String query) {
    return 'No dua mentions “$query”.';
  }

  @override
  String duaCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n duas',
      one: '1 dua',
    );
    return '$_temp0';
  }

  @override
  String sectionCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sections',
      one: '1 section',
    );
    return '$_temp0';
  }

  @override
  String get ruqyahTitle => 'Ruqyah';

  @override
  String get ruqyahSubtitle =>
      'Healing and protection through the words of Allah and the supplications of the Prophet ﷺ.';

  @override
  String get recite => 'Recite';

  @override
  String get learn => 'Learn';

  @override
  String get programBrief => 'Brief';

  @override
  String get programMedium => 'Medium';

  @override
  String get programLong => 'Long';

  @override
  String get listenFull => 'Listen to the full recitation';

  @override
  String get playing => 'Playing…';

  @override
  String get fromQuran => 'Quran';

  @override
  String get fromSunnah => 'Sunnah';

  @override
  String get showMeaning => 'Show meaning';

  @override
  String get hideMeaning => 'Hide meaning';

  @override
  String get moreTitle => 'More';

  @override
  String get allFeatures => 'All features';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get city => 'City';

  @override
  String get chooseCity => 'Choose your city';

  @override
  String get asrMethod => 'Asr time';

  @override
  String get asrStandard => 'Standard';

  @override
  String get asrHanafi => 'Hanafi';

  @override
  String get asrHint =>
      'Hanafi Asr starts later, when shadows are twice an object\'s length.';

  @override
  String get about => 'About';

  @override
  String get aboutBody =>
      'Prayer times, fasting, nisab, duas, names and ruqyah come from islamicapi.com. Your prayer log, tasbih and settings stay on this device.';
}
