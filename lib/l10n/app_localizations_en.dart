// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sabeelak';

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
      'The API key is missing. Add it to assets/env/env.json';

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
  String get featQuranSub => 'Mushaf & tafsir';

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
  String get sebhaCustomize => 'Sebha look';

  @override
  String get sebhaCustomizeSub => 'Pick a bead style and color.';

  @override
  String get sebhaType => 'Type';

  @override
  String get sebhaColor => 'Color';

  @override
  String get sebhaStyleWood => 'Wood';

  @override
  String get sebhaStyleAmber => 'Amber';

  @override
  String get sebhaStyleStone => 'Stone';

  @override
  String get sebhaStylePearl => 'Pearl';

  @override
  String get sebhaStyleDigital => 'Digital';

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
  String get quranSearch => 'Surah, number, 2:255 or words of an ayah';

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
  String get readSurah => 'Read';

  @override
  String get tapAyahHint => 'Tap any ayah to read its tafsir';

  @override
  String ayahRef(String surah, String n) {
    return '$surah · Ayah $n';
  }

  @override
  String ayahOf(String n, String total) {
    return 'Ayah $n of $total';
  }

  @override
  String get viewSurahs => 'Surahs';

  @override
  String get viewJuz => 'Juz';

  @override
  String get recentlyRead => 'Recently read';

  @override
  String fromAyah(String n) {
    return 'From ayah $n';
  }

  @override
  String get myLocation => 'My location';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get useMyLocationSub => 'Prayer times for where you are now';

  @override
  String get locating => 'Finding your location…';

  @override
  String nearCity(String city) {
    return 'Method and currency of $city';
  }

  @override
  String get locDisabled => 'Location services are off.';

  @override
  String get locDenied => 'Location permission was denied. Tap to try again.';

  @override
  String get locBlocked => 'Location access is blocked. Allow it in Settings.';

  @override
  String get locFailed => 'Couldn\'t get your location. Try again.';

  @override
  String get openSettings => 'Open settings';

  @override
  String pageN(String n) {
    return 'Page $n';
  }

  @override
  String juzN(String n) {
    return 'Juz $n';
  }

  @override
  String get sajdah => 'Sajdah';

  @override
  String get nextSurah => 'Next surah';

  @override
  String get previousSurah => 'Previous surah';

  @override
  String get readingSettings => 'Reading settings';

  @override
  String get mushafType => 'Mushaf';

  @override
  String get mushafUthmani => 'Uthmani script';

  @override
  String get mushafUthmaniSub => 'The Madinah mushaf script';

  @override
  String get mushafTajweed => 'Colour-coded tajweed';

  @override
  String get mushafTajweedSub => 'Uthmani script, rules in colour';

  @override
  String get mushafSimple => 'Simple script';

  @override
  String get mushafSimpleSub => 'Modern spelling with full diacritics';

  @override
  String get mushafPlain => 'Without diacritics';

  @override
  String get mushafPlainSub => 'Plain letters, easy to scan';

  @override
  String get textSize => 'Text size';

  @override
  String get tajweedKey => 'Colour key';

  @override
  String get tjSilent => 'Not pronounced';

  @override
  String get tjMadd => 'Prolongation (madd)';

  @override
  String get tjGhunnah => 'Nasalisation (ghunnah)';

  @override
  String get tjIkhfa => 'Concealment (ikhfa)';

  @override
  String get tjIdgham => 'Merging (idgham)';

  @override
  String get tjIqlab => 'Conversion (iqlab)';

  @override
  String get tjQalqalah => 'Echo (qalqalah)';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get tafsirMuyassar => 'Al-Muyassar';

  @override
  String get tafsirJalalayn => 'Al-Jalalayn';

  @override
  String get tafsirBaghawi => 'Al-Baghawi';

  @override
  String get tafsirQurtubi => 'Al-Qurtubi';

  @override
  String get tafsirWaseet => 'Al-Waseet';

  @override
  String get tafsirIbnKathir => 'Ibn Kathir (abridged)';

  @override
  String get tafsirSaheeh => 'Saheeh International';

  @override
  String get tafsirArabicNote => 'Arabic';

  @override
  String get tafsirEnglishNote => 'English';

  @override
  String get tafsirEmpty => 'This source has no commentary on this ayah.';

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
      'Prayer times and the Hijri date are calculated on this device. The Quran text is bundled; recitations, tafsir and other content are downloaded from the sources in Credits. Your prayer log, tasbih and settings stay on this device.';

  @override
  String get obSkip => 'Skip';

  @override
  String get obNext => 'Next';

  @override
  String get obBack => 'Back';

  @override
  String get obStart => 'Start';

  @override
  String get obWelcomeTitle => 'Welcome';

  @override
  String get obWelcomeBody =>
      'A quiet companion for prayer, Quran and remembrance. Let\'s set it up for you — it takes a minute.';

  @override
  String get obChooseLanguage => 'Choose your language';

  @override
  String get obLocationTitle => 'Where do you pray?';

  @override
  String get obLocationBody =>
      'Prayer times and the Qibla depend on where you are. Allow location access, or pick a city.';

  @override
  String get obChooseCity => 'Choose a city instead';

  @override
  String get obNotifyTitle => 'Never miss a prayer';

  @override
  String get obNotifyBody =>
      'Get a gentle reminder when each prayer time begins, for the prayers you choose.';

  @override
  String get obAllowNotifications => 'Allow notifications';

  @override
  String get obMushafTitle => 'Your mushaf';

  @override
  String get obMushafBody =>
      'Pick the script, text size and tafsir you read best. You can change them anytime from the reader.';

  @override
  String get obDoneTitle => 'All set';

  @override
  String get obDoneBody => 'Here\'s what you chose. Tap any item to change it.';

  @override
  String get prayerReminders => 'Prayer reminders';

  @override
  String get prayerRemindersSub =>
      'A notification when each prayer time begins';

  @override
  String get notificationsDenied =>
      'Notifications are off for this app. Allow them in Settings.';

  @override
  String reminderTitle(String prayer) {
    return 'Time for $prayer';
  }

  @override
  String get reminderBody => 'Hayya ‘ala as-salah — come to prayer.';

  @override
  String get remindersOff => 'Off';

  @override
  String remindersCount(String n, String total) {
    return '$n of $total prayers';
  }

  @override
  String get defaultTafsir => 'Default tafsir';

  @override
  String get quranReading => 'Quran reading';

  @override
  String get replayTour => 'Show the welcome tour';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get rateAppSub =>
      'A rating on Google Play helps others find Sabeelak.';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateBody =>
      'A new version is on the Play Store. Update to keep using Sabeelak.';

  @override
  String get forceUpdateAction => 'Update';

  @override
  String get featReciters => 'Reciters';

  @override
  String get featRecitersSub => 'Full surahs from 240+ reciters, offline too';

  @override
  String get recitersSearch => 'Search reciters';

  @override
  String surahCount(String n) {
    return '$n surahs';
  }

  @override
  String get listenFromHere => 'Listen from here';

  @override
  String get listenPage => 'Listen to this page';

  @override
  String get ayahReciter => 'Reciter';

  @override
  String get ayahReciterSub => 'Recites ayah by ayah as you read';

  @override
  String get download => 'Download';

  @override
  String get removeDownload => 'Remove download';

  @override
  String get downloadFailed => 'Download failed. Check your connection.';

  @override
  String get savedOffline => 'Saved offline';

  @override
  String get playbackError => 'Couldn\'t play. Tap to retry.';

  @override
  String get playTip => 'Play';

  @override
  String get pauseTip => 'Pause';

  @override
  String get nextTip => 'Next';

  @override
  String get previousTip => 'Previous';

  @override
  String get playAll => 'Play all';

  @override
  String get recentlyPlayed => 'Recently played';

  @override
  String get popularReciters => 'Popular reciters';

  @override
  String get allReciters => 'All reciters';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get fromMushaf => 'From the mushaf';

  @override
  String get openInMushaf => 'Open in the mushaf';

  @override
  String get repeatTip => 'Repeat';

  @override
  String get searchTip => 'Search';

  @override
  String get ambientTitle => 'Background sounds';

  @override
  String get ambientSub => 'Mix calm sounds under the recitation';

  @override
  String get ambientRain => 'Rain';

  @override
  String get ambientStorm => 'Thunderstorm';

  @override
  String get ambientFire => 'Fireplace';

  @override
  String get ambientWaves => 'Ocean waves';

  @override
  String get ambientBirds => 'Forest birds';

  @override
  String get ambientNight => 'Quiet night';

  @override
  String get ambientWind => 'Wind';

  @override
  String get ambientClear => 'Clear';

  @override
  String get adhanVoice => 'Adhan voice';

  @override
  String get adhanPlainSound => 'Notification sound only';

  @override
  String get adhanIosNote =>
      'iPhone plays the first 30 seconds of the adhan with the notification.';

  @override
  String get previewTip => 'Preview';

  @override
  String get featHisn => 'Hisn al-Muslim';

  @override
  String get featHisnSub => 'Fortress of the Muslim — adhkar for every moment';

  @override
  String get featAzkar => 'Morning & evening';

  @override
  String get featAzkarSub => 'Daily adhkar with a counter';

  @override
  String get morningAzkar => 'Morning adhkar';

  @override
  String get eveningAzkar => 'Evening adhkar';

  @override
  String azkarProgress(String done, String total) {
    return '$done of $total done';
  }

  @override
  String get azkarAllDone => 'All done today — may Allah accept.';

  @override
  String get azkarTapHint => 'Tap a card to count';

  @override
  String get azkarStart => 'Start';

  @override
  String get azkarContinue => 'Continue';

  @override
  String get azkarReset => 'Start over';

  @override
  String get azkarResetConfirm => 'Clear today\'s counts for this session?';

  @override
  String get cancel => 'Cancel';

  @override
  String timesCount(String n) {
    return '×$n';
  }

  @override
  String get hisnSearch => 'Search chapters or words';

  @override
  String get hisnChapters => 'Chapters';

  @override
  String hisnChapterCount(String n) {
    return '$n chapters';
  }

  @override
  String noHisnMatch(String q) {
    return 'Nothing found for “$q”';
  }

  @override
  String get hisnSource => 'From Hisn al-Muslim by Sa‘id ibn Wahf al-Qahtani.';

  @override
  String get hisnLoadFailed => 'Couldn\'t open the book.';

  @override
  String get azkarReminders => 'Adhkar reminders';

  @override
  String get azkarRemindersSub =>
      'A daily nudge for the morning and evening adhkar';

  @override
  String get azkarReminderBody => 'Take a few minutes for your adhkar.';

  @override
  String azkarRemindAt(String time) {
    return 'Remind me at $time';
  }

  @override
  String get azkarOff => 'Off';

  @override
  String get listenTip => 'Listen';

  @override
  String get copyTip => 'Copy';

  @override
  String get morning => 'Morning';

  @override
  String get evening => 'Evening';

  @override
  String photoCredit(String author, String licence) {
    return 'Photo: $author · $licence · Wikimedia Commons';
  }

  @override
  String get widgetVerse => 'A verse';

  @override
  String get widgetDua => 'Dua';

  @override
  String get widgetEmpty => 'Open the app to load';

  @override
  String get widgetsTitle => 'Home & lock screen widgets';

  @override
  String get widgetPrayerSub => 'Time left until the next prayer';

  @override
  String get widgetAyahSub => 'A new verse every half hour';

  @override
  String get widgetDuaSub => 'A new dua every half hour';

  @override
  String get widgetNameSub => 'A name of Allah every half hour';

  @override
  String get widgetAdd => 'Add';

  @override
  String get widgetAddFailed =>
      'Your launcher can\'t add widgets from here. Long-press the home screen and choose Widgets.';

  @override
  String get widgetIosHint =>
      'Long-press the home or lock screen, tap Edit or +, then search for Sabeelak.';

  @override
  String get calcMethod => 'Calculation method';

  @override
  String calcCityDefault(String city) {
    return 'Recommended for $city';
  }

  @override
  String get calcOffline =>
      'Times are calculated on your device, so they work offline.';

  @override
  String get adjustTimes => 'Adjust times';

  @override
  String get adjustTimesSub =>
      'Add or subtract minutes to match your local mosque.';

  @override
  String get adjustNone => 'No adjustments';

  @override
  String get adjustSome => 'Custom adjustments';

  @override
  String get hijriAdjust => 'Hijri date';

  @override
  String get hijriAdjustSub =>
      'Shift by a day if the moon was sighted differently where you live.';

  @override
  String get credits => 'Credits & licences';

  @override
  String get creditsSub => 'Sources of the Quran text, audio and data';

  @override
  String get creditsPhotos => 'Reciter photos';

  @override
  String get creditsPhotosSub =>
      'Wikimedia Commons; the author and licence also appear under each photo.';

  @override
  String get openSourceLicences => 'Open-source licences';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyPolicySub => 'No account, no ads';

  @override
  String get privacyNoAccountTitle => 'No account, no ads';

  @override
  String get privacyNoAccount =>
      'The app has no sign-in or ads. Your prayer log, tasbih counts, bookmarks, Khatmah progress and settings are stored only on this device and are deleted with the app.';

  @override
  String get privacyCrashesTitle => 'Crash reports';

  @override
  String get privacyCrashes =>
      'If the app crashes or hits an error, a report is sent to Sentry (sentry.io): the error, a stack trace, the app version and the device type. It does not include your name, location, prayer log or anything you typed.';

  @override
  String get privacyLocationTitle => 'Location';

  @override
  String get privacyLocation =>
      'If you choose \"my location\", your position is used on the device to calculate prayer times and the qibla. It is rounded to about 100 m and is only sent to islamicapi.com to fetch fasting times. It is never stored on a server by us.';

  @override
  String get privacyNetworkTitle => 'Online content';

  @override
  String get privacyNetwork =>
      'Recitations, tafsir, duas and other content are downloaded from the services listed in Credits. Those services see your IP address like any website. Downloads are cached on the device so they work offline.';

  @override
  String get privacyNotificationsTitle => 'Notifications and widgets';

  @override
  String get privacyNotifications =>
      'Reminders are scheduled locally on the device. Widgets read data the app saves on the device; nothing is sent anywhere.';

  @override
  String get privacyContactTitle => 'Questions';

  @override
  String get privacyContact =>
      'For any privacy question, contact the developer through the app store listing.';

  @override
  String ayahMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ayahs',
      one: '1 ayah',
    );
    return '$_temp0';
  }

  @override
  String ayahMatchesMore(String shown) {
    return 'Showing the first $shown. Add a word to narrow it down.';
  }

  @override
  String goToAyah(String surah, String ayah) {
    return 'Go to $surah, ayah $ayah';
  }

  @override
  String get searchArabicHint => 'Type Arabic words to search inside ayahs.';

  @override
  String get khatmah => 'Khatmah';

  @override
  String get khatmahSub => 'Plan to finish the whole Quran';

  @override
  String get khatmahIntro =>
      'Pick how many days you want to finish the Quran in. We\'ll split it into a daily portion and track the pages you read.';

  @override
  String get khatmahFinishIn => 'Finish in';

  @override
  String khatmahDays(String n) {
    return '$n days';
  }

  @override
  String khatmahPerDay(String n) {
    return '≈ $n pages a day';
  }

  @override
  String get khatmahStart => 'Start khatmah';

  @override
  String get khatmahToday => 'Today\'s portion';

  @override
  String khatmahTodayGoal(String read, String target) {
    return '$read of $target pages';
  }

  @override
  String get khatmahTodayDone => 'Today\'s portion is done. Barak Allahu feek!';

  @override
  String khatmahPages(String read, String total) {
    return '$read of $total pages';
  }

  @override
  String khatmahDayOf(String day, String days) {
    return 'Day $day of $days';
  }

  @override
  String get khatmahStreak => 'Streak';

  @override
  String khatmahStreakDays(String n) {
    return '$n days';
  }

  @override
  String get khatmahAhead => 'Ahead of schedule';

  @override
  String get khatmahOnTrack => 'On track';

  @override
  String khatmahBehind(String n) {
    return '$n pages behind';
  }

  @override
  String khatmahContinue(String page) {
    return 'Continue from page $page';
  }

  @override
  String get khatmahHint =>
      'A page counts once you turn past it or keep it open for 20 seconds.';

  @override
  String get khatmahDone =>
      'You finished the Quran. May Allah accept it from you!';

  @override
  String khatmahCompleted(String n) {
    return 'Khatmahs completed: $n';
  }

  @override
  String get khatmahNew => 'Start a new khatmah';

  @override
  String get khatmahEnd => 'End plan';

  @override
  String get khatmahEndConfirm =>
      'End this khatmah? Its progress will be cleared.';

  @override
  String get khatmahReadUpTo => 'Already read some?';

  @override
  String khatmahReadUpToSub(String page) {
    return 'Mark every page up to page $page as read.';
  }

  @override
  String get khatmahMark => 'Mark as read';

  @override
  String get featCalendar => 'Hijri calendar';

  @override
  String get featCalendarSub => 'Months and Islamic occasions';

  @override
  String get featKhatmah => 'Khatmah';

  @override
  String get featKhatmahSub => 'Daily wird to finish the Quran';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarUpcoming => 'Upcoming';

  @override
  String get calendarWhiteDays => 'White days (13–15): recommended fasting';

  @override
  String calendarInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'In $n days',
      one: 'Tomorrow',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get calendarNoEvents => 'No occasions on this day.';

  @override
  String get calendarShiftNote =>
      'Dates follow the Umm al-Qura calendar. Adjust by a day in Settings → Adjust times if your country sighted the moon differently.';

  @override
  String get evNewYear => 'Islamic New Year';

  @override
  String get evNewYearSub => '1 Muharram';

  @override
  String get evAshura => 'Day of Ashura';

  @override
  String get evAshuraSub =>
      'Fasting it expiates the past year; fast the 9th too.';

  @override
  String get evRamadan => 'Ramadan begins';

  @override
  String get evRamadanSub => 'The month of fasting';

  @override
  String get evLastTen => 'Last ten nights';

  @override
  String get evLastTenSub => 'Seek Laylat al-Qadr in the odd nights.';

  @override
  String get evEidFitr => 'Eid al-Fitr';

  @override
  String get evEidFitrSub => 'Then six days of Shawwal';

  @override
  String get evDhulHijjah => 'First ten days of Dhul Hijjah';

  @override
  String get evDhulHijjahSub => 'The best days of the year for good deeds';

  @override
  String get evArafah => 'Day of Arafah';

  @override
  String get evArafahSub => 'Fasting it expiates two years.';

  @override
  String get evEidAdha => 'Eid al-Adha';

  @override
  String get evEidAdhaSub => 'The day of sacrifice';

  @override
  String get evTashreeq => 'Days of Tashreeq';

  @override
  String get evTashreeqSub =>
      '11–13 Dhul Hijjah: days of eating and remembrance';

  @override
  String get featHifz => 'Hifz';

  @override
  String get featHifzSub => 'Memorise with repetition';

  @override
  String get hifzSurah => 'Surah';

  @override
  String hifzRange(String from, String to) {
    return 'Ayahs $from–$to';
  }

  @override
  String get hifzAyahRepeat => 'Repeat each ayah';

  @override
  String get hifzRangeRepeat => 'Repeat the whole range';

  @override
  String hifzTimes(String n) {
    return '$n×';
  }

  @override
  String get hifzPlay => 'Start listening';

  @override
  String get hifzStop => 'Stop';

  @override
  String get hifzShow => 'Show';

  @override
  String get hifzFirstWords => 'First words';

  @override
  String get hifzHideAll => 'Hide';

  @override
  String get hifzTapReveal => 'Tap to reveal';

  @override
  String hifzMemorized(String n, String total) {
    return 'Memorised $n of $total ayahs in this surah';
  }

  @override
  String get hifzMark => 'Mark as memorised';

  @override
  String get hifzUnmark => 'Memorised';

  @override
  String get hifzTestHint =>
      'Hide the text, recite from memory, then tap an ayah to check yourself.';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get tracker => 'Prayer tracker';

  @override
  String get featTracker => 'Tracker';

  @override
  String get featTrackerSub => 'Streaks, history and missed prayers';

  @override
  String get trackerWeek => 'Last 7 days';

  @override
  String get trackerByPrayer => 'By prayer · 30 days';

  @override
  String get trackerStreak => 'Days with all five';

  @override
  String get trackerLast7 => 'Last 7 days';

  @override
  String get trackerLast30 => 'Last 30 days';

  @override
  String get trackerTapHint =>
      'Tap a circle to log a prayer on an earlier day.';

  @override
  String get trackerEmpty =>
      'Mark your prayers on the home screen to see stats here.';

  @override
  String get qadaTitle => 'Qada · missed prayers';

  @override
  String get qadaNone => 'Nothing to make up';

  @override
  String qadaLeft(String n) {
    return '$n prayers to make up';
  }

  @override
  String get qadaHint =>
      'Add the prayers you owe, then tap − each time you make one up.';

  @override
  String get qadaMadeUp => 'Made one up';

  @override
  String get qadaAdd => 'Add';

  @override
  String get featRamadan => 'Ramadan';

  @override
  String get featRamadanSub => 'Iftar countdown, duas and a 30-day tracker';

  @override
  String get featFriday => 'Jumu\'ah';

  @override
  String get featFridaySub => 'Al-Kahf, salawat and the last hour';

  @override
  String get dailyAyahTitle => 'Ayah of the day';

  @override
  String get kahfReminderTitle => 'Friday · Surah Al-Kahf';

  @override
  String get kahfReminderBody =>
      'Read Surah Al-Kahf today — a light between two Fridays.';

  @override
  String get fridayHourTitle => 'The last hour of Friday';

  @override
  String get fridayHourBody =>
      'Last hour before Maghrib — make du\'a.\n\nرَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n\nOur Lord, give us good in this world and the Hereafter, and protect us from the Fire.';

  @override
  String fridayHourRange(String from, String to) {
    return 'From $from until Maghrib at $to';
  }

  @override
  String get suhoorTitle => 'Suhoor';

  @override
  String suhoorBody(String n) {
    return 'Fajr is in $n minutes — time for suhoor.';
  }

  @override
  String get dailyAyahReminder => 'Ayah of the day';

  @override
  String get kahfReminder => 'Surah Al-Kahf on Friday';

  @override
  String get kahfReminderSub => 'Friday at 10:00 AM';

  @override
  String get fridayHourReminder => 'Last hour of Friday';

  @override
  String get fridayHourReminderSub => 'An hour before Maghrib';

  @override
  String get suhoorReminder => 'Suhoor in Ramadan';

  @override
  String get suhoorReminderSub => '45 minutes before Fajr';

  @override
  String get moreReminders => 'Daily & weekly reminders';

  @override
  String get reminders => 'Reminders';

  @override
  String get jumuahMubarak => 'Jumu\'ah Mubarak';

  @override
  String get fridayTomorrow => 'Friday is tomorrow';

  @override
  String fridayIn(String n) {
    return 'Friday in $n days';
  }

  @override
  String get fridayIntro => 'The best day the sun rises on.';

  @override
  String get fridayHomeSub => 'Al-Kahf, salawat and the last hour';

  @override
  String get fridaySunnahs => 'Sunnahs of Friday';

  @override
  String get sunnahGhusl => 'Take a ghusl (full bath) before the prayer.';

  @override
  String get sunnahClothes => 'Wear your best clothes and use perfume.';

  @override
  String get sunnahEarly => 'Go early to the mosque, walking if you can.';

  @override
  String get sunnahKhutbah => 'Listen to the khutbah in silence.';

  @override
  String get sunnahKahf => 'Read Surah Al-Kahf.';

  @override
  String get sunnahSalawat => 'Send plenty of salawat on the Prophet ﷺ.';

  @override
  String get sunnahDua =>
      'Make du\'a, especially in the last hour before Maghrib.';

  @override
  String get readKahf => 'Read Surah Al-Kahf';

  @override
  String get kahfHint => 'Tick it once you\'ve read it today.';

  @override
  String get kahfDone => 'Read today — may Allah accept it.';

  @override
  String get salawatCounter => 'Salawat on the Prophet ﷺ';

  @override
  String get salawatHint => 'Tap the circle with each one.';

  @override
  String get iftarDua => 'Dua when breaking the fast';

  @override
  String get iftarDuaMeaning =>
      'The thirst has gone, the veins are moistened, and the reward is certain, if Allah wills.';

  @override
  String get iftarDuaSource => 'Abu Dawud';

  @override
  String get qadrDua => 'Dua for Laylat al-Qadr';

  @override
  String get qadrDuaMeaning =>
      'O Allah, You are Pardoning and love to pardon, so pardon me.';

  @override
  String get qadrDuaSource => 'At-Tirmidhi';

  @override
  String ramadanTracker(String year) {
    return 'Ramadan $year';
  }

  @override
  String ramadanDay(String n) {
    return 'Day $n of Ramadan';
  }

  @override
  String get iftarIn => 'Iftar in';

  @override
  String get suhoorEndsIn => 'Suhoor ends in';

  @override
  String ramadanIn(String n) {
    return 'Ramadan in $n days';
  }

  @override
  String get deedFast => 'Fasted';

  @override
  String get deedTaraweeh => 'Taraweeh';

  @override
  String get deedJuz => 'A juz read';

  @override
  String get ramadanTrackerHint =>
      'Tap a day to tick its fast, taraweeh and juz.';

  @override
  String get shareAyah => 'Share ayah';

  @override
  String get shareHadith => 'Share hadith';

  @override
  String get shareName => 'Share name';

  @override
  String get shareDua => 'Share dua';

  @override
  String get shareImage => 'Share as image';

  @override
  String get includeTranslation => 'Include translation';

  @override
  String get share => 'Share';

  @override
  String get hadithTitle => 'Hadith of the day';

  @override
  String get liveActivity => 'Lock screen countdown';

  @override
  String get liveActivitySub =>
      'A Live Activity counting down to the next prayer';

  @override
  String get liveNow => 'It\'s time';

  @override
  String get fridayPriorities => 'Today\'s deeds, by priority';

  @override
  String get deedJumuah => 'Pray Jumu\'ah and listen to the khutbah.';

  @override
  String get tagFard => 'Obligatory';

  @override
  String get tagMuakkad => 'Emphasized sunnah';

  @override
  String get tagSunnah => 'Sunnah';

  @override
  String get kahfOpen => 'Open';

  @override
  String get hifzPlayAyah => 'Play this ayah';

  @override
  String get hifzPageHint =>
      'Tap an ayah to hear it. Tap its number to mark it learnt.';

  @override
  String get hifzFrom => 'From';

  @override
  String get hifzTo => 'To';

  @override
  String get reciteCheck => 'Recite & check';

  @override
  String get reciteHint =>
      'Recite the range from memory. It\'s checked on your device.';

  @override
  String get reciteModelTitle => 'Download the recitation model?';

  @override
  String reciteModelBody(String size) {
    return 'A $size Quran speech model (Tarteel AI) is downloaded once. Your recordings never leave your phone.';
  }

  @override
  String get reciteDownload => 'Download';

  @override
  String get reciteWorkDownload => 'Downloading the recitation model';

  @override
  String reciteDownloading(String percent) {
    return 'Downloading model… $percent';
  }

  @override
  String get reciteListening => 'Listening… tap to finish';

  @override
  String get reciteChecking => 'Checking your recitation…';

  @override
  String reciteResult(String correct, String total) {
    return '$correct of $total words matched';
  }

  @override
  String reciteMistakes(String count) {
    return '$count possible mistakes';
  }

  @override
  String reciteMissed(String count) {
    return '$count skipped';
  }

  @override
  String get reciteLegend =>
      'Green: matched · red: possible mistake · underlined: skipped. Automatic check, it can be wrong.';

  @override
  String get reciteHeard => 'What was heard';

  @override
  String get reciteClear => 'Clear';

  @override
  String get reciteNoPermission =>
      'Microphone access is needed to check your recitation.';

  @override
  String get reciteFailed => 'Couldn\'t check the recitation. Try again.';

  @override
  String get reciteNothing => 'Nothing was heard. Recite a little louder.';

  @override
  String get reciteDownloadFailed => 'Download failed. Check your connection.';

  @override
  String get reciteRevealLive => 'Show the words as I recite';

  @override
  String get reciteRevealLiveHint =>
      'The page stays covered and each word appears once it\'s heard.';

  @override
  String reciteProgress(String done, String total) {
    return '$done of $total words';
  }

  @override
  String get feedbackTitle => 'Your recitation';

  @override
  String get gradeExcellent => 'Excellent, mashaAllah';

  @override
  String get gradeVeryGood => 'Very good';

  @override
  String get gradeGood => 'Good, review the marked words';

  @override
  String get gradeReview => 'Needs more review';

  @override
  String get feedbackMatched => 'Matched';

  @override
  String get feedbackMistakes => 'Possible mistakes';

  @override
  String get feedbackSkipped => 'Skipped';

  @override
  String get feedbackReview => 'Words to review';

  @override
  String feedbackHeardAs(String word) {
    return 'heard: $word';
  }

  @override
  String get feedbackSkippedWord => 'skipped';

  @override
  String feedbackPerfect(String count) {
    return '$count ayahs recited without mistakes';
  }

  @override
  String get feedbackMarkLearnt => 'Mark as learnt';

  @override
  String feedbackUnreached(String count) {
    return 'Stopped before the end: $count words not recited.';
  }

  @override
  String get feedbackOpen => 'Feedback';

  @override
  String get feedbackDone => 'Done';

  @override
  String get featHadith => 'Hadith';

  @override
  String get featHadithSub => 'Nawawi\'s Forty, Qudsi, Riyad as-Salihin';

  @override
  String get hadithSearch => 'Search hadith in Arabic or English';

  @override
  String hadithCount(String count) {
    return '$count hadith';
  }

  @override
  String hadithNumber(String number) {
    return 'Hadith $number';
  }

  @override
  String get hadithSaved => 'Saved hadith';

  @override
  String get hadithSave => 'Save';

  @override
  String get hadithUnsave => 'Remove from saved';

  @override
  String hadithNoMatch(String query) {
    return 'No hadith matches “$query”';
  }

  @override
  String get hadithChapters => 'Books';

  @override
  String get hadithSource =>
      'Arabic text and English translation from Sunnah.com, via the open hadith-json project.';

  @override
  String get wirdReminder => 'Daily Quran wird';

  @override
  String get wirdReminderTitle => 'Your daily wird';

  @override
  String get wirdReminderBody =>
      'Read today\'s portion of the Quran and keep your streak.';

  @override
  String wirdPortion(String first, String last) {
    return 'Today: pages $first–$last';
  }

  @override
  String wirdPortionOne(String page) {
    return 'Today: page $page';
  }

  @override
  String get wirdMarkDone => 'I read today\'s portion';

  @override
  String get sadaqahReminder => 'Friday sadaqah reminder';

  @override
  String get sadaqahReminderTitle => 'Sadaqah';

  @override
  String get sadaqahReminderBody =>
      'Charity does not decrease wealth. Give something today, even a little.';

  @override
  String sadaqahRemindAt(String time) {
    return 'Fridays at $time';
  }

  @override
  String get save => 'Save';

  @override
  String get featSadaqah => 'Sadaqah';

  @override
  String get featSadaqahSub => 'Private log, monthly goal, Friday reminder';

  @override
  String get sadaqahAdd => 'Log sadaqah';

  @override
  String get sadaqahMoney => 'Money';

  @override
  String get sadaqahFood => 'Food';

  @override
  String get sadaqahHelp => 'Help';

  @override
  String get sadaqahOther => 'Other';

  @override
  String get sadaqahAmount => 'Amount (optional)';

  @override
  String get sadaqahNote => 'Note (optional)';

  @override
  String get sadaqahPrivate => 'Stays on your phone only.';

  @override
  String sadaqahCount(String count) {
    return '$count this month';
  }

  @override
  String get sadaqahSetGoal => 'Set a monthly goal';

  @override
  String sadaqahGoalOf(String amount, String currency) {
    return 'Goal: $amount $currency';
  }

  @override
  String get sadaqahGoalTitle => 'Monthly goal';

  @override
  String get sadaqahNoGoal => 'No goal';

  @override
  String get sadaqahStreak => 'Weeks in a row';

  @override
  String sadaqahWeeks(String count) {
    return '$count weeks';
  }

  @override
  String get sadaqahHistory => 'History';

  @override
  String get sadaqahEmpty => 'Nothing logged yet. Even a smile is charity.';

  @override
  String get sadaqahHadith =>
      '“Charity does not decrease wealth.” — Sahih Muslim';

  @override
  String get featQada => 'Missed fasts';

  @override
  String get featQadaSub => 'Qada, fidyah and kaffarah tracker';

  @override
  String get qadaRemaining => 'Fasts left to make up';

  @override
  String qadaMadeOf(String made, String owed) {
    return '$made of $owed made up';
  }

  @override
  String get qadaLess => 'One less';

  @override
  String get qadaMore => 'One more';

  @override
  String get qadaMarkToday => 'I\'m fasting today';

  @override
  String get qadaFastedToday => 'Fasting today';

  @override
  String get qadaAllDone => 'All made up. May Allah accept it.';

  @override
  String get qadaTip =>
      'Mondays, Thursdays and the white days (13–15) are good days to make up fasts.';

  @override
  String get qadaIntro =>
      'Missed days of Ramadan for illness, travel, pregnancy or menstruation? Add them with + and tick each day you make one up.';

  @override
  String qadaFromRamadan(String year, String count) {
    return 'Your Ramadan $year tracker has $count days not marked as fasted.';
  }

  @override
  String get qadaFidyah => 'Fidyah';

  @override
  String get qadaFidyahInfo =>
      'For anyone who can never fast, like the very old or chronically ill: feed one poor person for each day missed.';

  @override
  String qadaFidyahMeals(String count) {
    return '$count meals';
  }

  @override
  String qadaFidyahTotal(String count, String total) {
    return '$count meals ≈ $total';
  }

  @override
  String get qadaMealCost => 'Cost of one meal';

  @override
  String get qadaKaffarah => 'Kaffarah';

  @override
  String get qadaKaffarahInfo =>
      'Breaking a Ramadan fast by intercourse needs kaffarah: fasting 60 days in a row, or feeding 60 poor people if unable.';

  @override
  String get qadaKaffarahStart => 'Start 60 days';

  @override
  String qadaKaffarahProgress(String days, String total) {
    return '$days of $total days in a row';
  }

  @override
  String get qadaKaffarahBroken =>
      'A day was missed, so the count must start again (unless the break was for illness or menstruation).';

  @override
  String get qadaKaffarahRestart => 'Start again';

  @override
  String get qadaKaffarahDone => 'Kaffarah complete. May Allah accept it.';

  @override
  String get qadaDisclaimer =>
      'Rulings differ between scholars; ask a scholar about your own case.';

  @override
  String get featSleep => 'Bedtime';

  @override
  String get featSleepSub => 'Sleep adhkar, al-Mulk and a sleep timer';

  @override
  String get sleepIntro =>
      'End your day with remembrance. Recitations fade out gently when the timer ends.';

  @override
  String get sleepAdhkar => 'Adhkar before sleeping';

  @override
  String sleepAdhkarSub(String count) {
    return '$count adhkar from Hisn al-Muslim';
  }

  @override
  String get sleepRecite => 'Recite before sleeping';

  @override
  String get sleepListen => 'Listen';

  @override
  String get sleepMulk => 'Surah al-Mulk';

  @override
  String get sleepMulkWhy =>
      'It intercedes for its reader until he is forgiven. — Tirmidhi';

  @override
  String get sleepSajdah => 'Surah as-Sajdah';

  @override
  String get sleepSajdahWhy =>
      'The Prophet ﷺ would not sleep until he recited as-Sajdah and al-Mulk. — Tirmidhi';

  @override
  String get sleepKursi => 'Ayat al-Kursi';

  @override
  String get sleepKursiWhy =>
      'A guardian from Allah stays with you until morning. — Bukhari';

  @override
  String get sleepBaqarah => 'Last two ayahs of al-Baqarah';

  @override
  String get sleepBaqarahWhy =>
      'Whoever recites them at night, they suffice him. — Bukhari, Muslim';

  @override
  String get sleepQuls => 'Al-Ikhlas, al-Falaq, an-Nas';

  @override
  String get sleepQulsWhy =>
      'Blow into your palms, recite them and wipe over your body, three times. — Bukhari';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String sleepMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String get sleepEndOfSurah => 'End of surah';

  @override
  String get sleepOff => 'Off';

  @override
  String get sleepTimerHint => 'Also in the player: tap the moon icon.';

  @override
  String get featTravel => 'Traveller';

  @override
  String get featTravelSub => 'Shortening and combining prayers on a journey';

  @override
  String get travelOn => 'You\'re travelling';

  @override
  String get travelOff => 'You\'re at home';

  @override
  String travelFromHome(String km) {
    return '$km km from home';
  }

  @override
  String travelDay(String day) {
    return 'Day $day of your trip';
  }

  @override
  String get travelAuto => 'Auto';

  @override
  String get travelModeOn => 'Travelling';

  @override
  String get travelModeOff => 'At home';

  @override
  String get travelAutoHint =>
      'Auto turns on when your prayer location is over 80 km from home.';

  @override
  String get travelSetHome => 'Make this home';

  @override
  String get travelToday => 'Today\'s prayers';

  @override
  String travelRakahs(String count) {
    return '$count rak\'ahs';
  }

  @override
  String get travelCombine => 'Combining (jam\')';

  @override
  String travelCombineDay(String first, String second, String from, String to) {
    return '$first + $second: in either one\'s time, from $from until $to.';
  }

  @override
  String travelCombineNight(
    String first,
    String second,
    String from,
    String to,
  ) {
    return '$first + $second: in either one\'s time, from $from until $to.';
  }

  @override
  String get travelCombineHint =>
      'Fajr is never combined, and Maghrib stays 3 rak\'ahs.';

  @override
  String get travelRules => 'Key rulings';

  @override
  String get travelRuleDistance =>
      'A journey of about 80 km (48 miles) or more allows shortening, once you leave your town\'s buildings.';

  @override
  String get travelRuleQasr =>
      'Dhuhr, Asr and Isha are prayed as 2 rak\'ahs instead of 4.';

  @override
  String get travelRuleJam =>
      'Dhuhr with Asr, and Maghrib with Isha, may be joined in the time of either.';

  @override
  String get travelRuleStay =>
      'Intending to stay more than 4 days makes you a resident for most scholars (15 days for the Hanafi school).';

  @override
  String get travelRuleSunnah =>
      'The regular sunnahs may be left, except the sunnah of Fajr and witr.';

  @override
  String get travelRuleImam =>
      'Praying behind a resident imam, pray the full 4 with him.';

  @override
  String get travelRuleFast =>
      'You may break the Ramadan fast on a journey and make it up later.';

  @override
  String get travelDuas => 'Duas for the journey';

  @override
  String get travelDuaSetOff => 'Setting off';

  @override
  String get travelDuaSetOffMeaning =>
      'Allah is the Greatest (×3). Glory to Him who has subjected this to us, and we could not have done it ourselves, and to our Lord we will surely return. O Allah, we ask You on this journey for goodness, piety and deeds that please You. O Allah, make this journey easy and shorten its distance for us. O Allah, You are the Companion on the journey and the Guardian of the family. — Muslim';

  @override
  String get travelDuaTown => 'Entering a town';

  @override
  String get travelDuaTownMeaning =>
      'O Allah, Lord of the seven heavens and all they shade, Lord of the seven earths and all they carry, I ask You for the good of this town and the good of its people, and seek refuge in You from its evil and the evil of its people. — Nasa\'i';

  @override
  String get travelDuaStop => 'Stopping somewhere';

  @override
  String get travelDuaStopMeaning =>
      'I seek refuge in the perfect words of Allah from the evil of what He has created. Nothing will harm you until you leave that place. — Muslim';

  @override
  String travelBanner(String km) {
    return 'You seem to be travelling ($km km from home). See how to shorten and combine prayers.';
  }

  @override
  String get featLearn => 'Learn to pray';

  @override
  String get featLearnSub => 'Wudu and salah, step by step';

  @override
  String lessonSteps(String count) {
    return '$count steps';
  }

  @override
  String lessonQuestions(String count) {
    return '$count questions';
  }

  @override
  String lessonStepOf(String number, String total) {
    return 'Step $number of $total';
  }

  @override
  String lessonQuestionOf(String number, String total) {
    return 'Question $number of $total';
  }

  @override
  String get lessonBack => 'Back';

  @override
  String get lessonNext => 'Next';

  @override
  String get lessonStartQuiz => 'Start quiz';

  @override
  String get lessonRight => 'Correct!';

  @override
  String get lessonWrong => 'Not quite.';

  @override
  String get lessonDone => 'Lesson complete';

  @override
  String lessonScore(String correct, String total) {
    return '$correct of $total correct';
  }

  @override
  String get lessonRetryQuiz => 'Try the quiz again';

  @override
  String get featTajweed => 'Tajweed';

  @override
  String get featTajweedSub => 'Rules with examples and quizzes';

  @override
  String get featKids => 'Kids';

  @override
  String get featKidsSub => 'Letters, short surahs and duas, with stars';

  @override
  String kidsStars(String count) {
    return '$count stars';
  }

  @override
  String get kidsStarsHint => 'Finish lessons and learn surahs to earn more.';

  @override
  String get kidsLetters => 'Arabic letters';

  @override
  String get kidsLettersSub => 'Tap a letter to see its name and a word.';

  @override
  String get kidsSurahs => 'Short surahs';

  @override
  String get kidsListen => 'Listen and repeat';

  @override
  String kidsAyahs(String count) {
    return '$count ayahs';
  }

  @override
  String get kidsLearnt => 'I learnt it';

  @override
  String get kidsDuas => 'Duas and prayer';

  @override
  String get widgetHadith => 'Hadith';

  @override
  String get widgetHijri => 'Hijri date';

  @override
  String get widgetSubhanallah => 'SubhanAllah';

  @override
  String get widgetAlhamdulillah => 'Alhamdulillah';

  @override
  String get widgetAllahuAkbar => 'Allahu Akbar';

  @override
  String get widgetReset => 'Reset';

  @override
  String widgetEventIn(String event, String days) {
    return '$event in $days days';
  }

  @override
  String get showLess => 'Show less';

  @override
  String get azkarSleepSub => 'Recite them as you lie down to sleep';

  @override
  String get compassHold =>
      'Hold your phone flat and turn until the Kaaba points up';

  @override
  String get compassCalibrate =>
      'Low accuracy — move your phone in a figure 8 and keep it away from metal';

  @override
  String get qiblaAr => 'AR Qibla';

  @override
  String get qiblaArHint =>
      'Hold your phone upright and turn until the prayer mat faces the Kaaba';

  @override
  String get qiblaArNoCamera =>
      'Camera unavailable. Allow camera access to see the Qibla around you.';

  @override
  String get kaaba => 'Kaaba';

  @override
  String get qiblaArPray => 'You can start your prayer';

  @override
  String get featHajj => 'Hajj & Umrah';

  @override
  String get featHajjSub => 'Rites step by step, with pictures';

  @override
  String get salawatReminderTitle => 'Friday · Salawat';

  @override
  String get salawatReminderBody =>
      'Send salawat on the Prophet ﷺ today.\n\nاللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ';

  @override
  String get salawatReminder => 'Salawat on Friday';

  @override
  String get salawatReminderSub => 'Friday at 11:00 AM';

  @override
  String get featTawashih => 'Tawashih';

  @override
  String get featTawashihSub => 'Munshids and prophetic praise';

  @override
  String get featRadio => 'Quran Radio';

  @override
  String get featRadioSub => 'Live recitation from Cairo';

  @override
  String get radioLive => 'Live';

  @override
  String get radioCity => 'Cairo';

  @override
  String get badgeNew => 'New';

  @override
  String get tawashihIntro =>
      'Prophetic praise by classic munshids. Pick a voice, then a track.';

  @override
  String get rawatibTitle => 'Sunnah rawatib';

  @override
  String rawatibBefore(String n) {
    return '$n rak\'ahs before';
  }

  @override
  String rawatibAfter(String n) {
    return '$n rak\'ahs after';
  }

  @override
  String get rawatibNone => 'No confirmed rawatib for this prayer.';

  @override
  String get rawatibHint => 'After the fard, pray the sunnah rawatib.';

  @override
  String get tahajjudReminder => 'Tahajjud';

  @override
  String get tahajjudReminderSub => 'Start of the last third of the night';

  @override
  String get tahajjudTitle => 'Time for tahajjud';

  @override
  String get tahajjudBody =>
      'The last third of the night has begun — a blessed time to stand in prayer.';

  @override
  String get duhaReminder => 'Duha';

  @override
  String get duhaReminderSub => 'About 20 minutes after sunrise';

  @override
  String get duhaTitle => 'Time for Duha';

  @override
  String get duhaBody => 'Sunrise has passed — pray Duha before Dhuhr.';

  @override
  String get iqamaTitle => 'Iqama countdown';

  @override
  String get iqamaIntro =>
      'Set how long until iqama. When it ends, the family stands for prayer together.';

  @override
  String iqamaMinutes(String n) {
    return '$n min';
  }

  @override
  String get iqamaStart => 'Start countdown';

  @override
  String get iqamaCancel => 'Cancel';

  @override
  String get iqamaUntil => 'until iqama';

  @override
  String get iqamaStanding => 'Stand for prayer';

  @override
  String get iqamaAgain => 'Set again';

  @override
  String get iqamaOpen => 'Iqama for the family';

  @override
  String get comfortReading => 'Comfortable reading';

  @override
  String get comfortReadingSub => 'Large Arabic text for easy reading';

  @override
  String trackCount(String n) {
    return '$n tracks';
  }

  @override
  String get allMunshids => 'All munshids';

  @override
  String get popularMunshids => 'Popular munshids';

  @override
  String prayerIn(String name) {
    return '$name in';
  }

  @override
  String get midnight => 'Midnight';

  @override
  String get lastThird => 'Last third';

  @override
  String get sleepAzkarReminder => 'Sleep adhkar';

  @override
  String get sleepAzkarReminderSub => 'About 45 minutes after Isha';

  @override
  String get sleepAzkarTitle => 'Time for sleep adhkar';

  @override
  String get sleepAzkarBody =>
      'End your day with remembrance before you sleep.';

  @override
  String get featBooks => 'Books';

  @override
  String get featBooksSub => 'Free Arabic Islamic library';

  @override
  String get booksIntro =>
      'Classic Arabic Islamic books — read free inside the app.';

  @override
  String get booksFree => 'Free';

  @override
  String get booksOpenFail => 'Could not load the book.';

  @override
  String get booksOpenExternal => 'Open in browser';

  @override
  String get booksSource => 'Source: IslamHouse — free for personal use.';

  @override
  String get booksCatAqidah => 'Aqidah';

  @override
  String get booksCatTafsir => 'Tafsir';

  @override
  String get booksCatHadith => 'Hadith';

  @override
  String get booksCatSeerah => 'Seerah';

  @override
  String get booksCatAdhkar => 'Adhkar';

  @override
  String get booksCatFiqh => 'Fiqh';
}
