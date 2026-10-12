import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Muslim'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayer;

  /// No description provided for @navQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// No description provided for @navTasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get navTasbih;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @errMissingKey.
  ///
  /// In en, this message translates to:
  /// **'The API key is missing. Add it to assets/env/env.json'**
  String get errMissingKey;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check your connection.'**
  String get errNetwork;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh'**
  String get refreshFailed;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”.'**
  String noMatch(String query);

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'am'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'pm'**
  String get pm;

  /// No description provided for @hoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String hoursMinutes(String h, String m);

  /// No description provided for @minutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String minutesOnly(String m);

  /// No description provided for @hijriSuffix.
  ///
  /// In en, this message translates to:
  /// **'AH'**
  String get hijriSuffix;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @jumuah.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah'**
  String get jumuah;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaikum'**
  String get greeting;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @inDuration.
  ///
  /// In en, this message translates to:
  /// **'in {d}'**
  String inDuration(String d);

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @todayPrayers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayers'**
  String get todayPrayers;

  /// No description provided for @prayedCount.
  ///
  /// In en, this message translates to:
  /// **'{n} of 5 prayed'**
  String prayedCount(String n);

  /// No description provided for @verseTitle.
  ///
  /// In en, this message translates to:
  /// **'A verse for today'**
  String get verseTitle;

  /// No description provided for @verseTranslation.
  ///
  /// In en, this message translates to:
  /// **'“For indeed, with hardship comes ease. Indeed, with hardship comes ease.”'**
  String get verseTranslation;

  /// No description provided for @verseRef.
  ///
  /// In en, this message translates to:
  /// **'Ash-Sharh 94:5–6'**
  String get verseRef;

  /// No description provided for @nameOfDay.
  ///
  /// In en, this message translates to:
  /// **'A name to reflect on'**
  String get nameOfDay;

  /// No description provided for @allNames.
  ///
  /// In en, this message translates to:
  /// **'All 99 names'**
  String get allNames;

  /// No description provided for @duaOfDay.
  ///
  /// In en, this message translates to:
  /// **'A dua for today'**
  String get duaOfDay;

  /// No description provided for @allDuas.
  ///
  /// In en, this message translates to:
  /// **'Duas for every occasion'**
  String get allDuas;

  /// No description provided for @featPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get featPrayer;

  /// No description provided for @featPrayerSub.
  ///
  /// In en, this message translates to:
  /// **'Times, tracker and fasting'**
  String get featPrayerSub;

  /// No description provided for @featQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get featQuran;

  /// No description provided for @featQuranSub.
  ///
  /// In en, this message translates to:
  /// **'Mushaf & tafsir'**
  String get featQuranSub;

  /// No description provided for @featQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get featQibla;

  /// No description provided for @featQiblaSub.
  ///
  /// In en, this message translates to:
  /// **'Direction to the Kaaba'**
  String get featQiblaSub;

  /// No description provided for @featTasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get featTasbih;

  /// No description provided for @featTasbihSub.
  ///
  /// In en, this message translates to:
  /// **'Adhkar after salah'**
  String get featTasbihSub;

  /// No description provided for @featDuas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get featDuas;

  /// No description provided for @featDuasSub.
  ///
  /// In en, this message translates to:
  /// **'For every occasion'**
  String get featDuasSub;

  /// No description provided for @featNames.
  ///
  /// In en, this message translates to:
  /// **'99 Names'**
  String get featNames;

  /// No description provided for @featNamesSub.
  ///
  /// In en, this message translates to:
  /// **'Meanings and recitation'**
  String get featNamesSub;

  /// No description provided for @featZakat.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get featZakat;

  /// No description provided for @featZakatSub.
  ///
  /// In en, this message translates to:
  /// **'Calculator with today\'s nisab'**
  String get featZakatSub;

  /// No description provided for @featRuqyah.
  ///
  /// In en, this message translates to:
  /// **'Ruqyah'**
  String get featRuqyah;

  /// No description provided for @featRuqyahSub.
  ///
  /// In en, this message translates to:
  /// **'Protection and healing'**
  String get featRuqyahSub;

  /// No description provided for @featFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get featFasting;

  /// No description provided for @featFastingSub.
  ///
  /// In en, this message translates to:
  /// **'Sahur, iftar and white days'**
  String get featFastingSub;

  /// No description provided for @prayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get prayerTitle;

  /// No description provided for @changeCity.
  ///
  /// In en, this message translates to:
  /// **'Change city'**
  String get changeCity;

  /// No description provided for @trackerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the circle once you\'ve prayed.'**
  String get trackerHint;

  /// No description provided for @nextBadge.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextBadge;

  /// No description provided for @allPrayed.
  ///
  /// In en, this message translates to:
  /// **'All five prayed today. May Allah accept it.'**
  String get allPrayed;

  /// No description provided for @fastingTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get fastingTitle;

  /// No description provided for @sahurEnds.
  ///
  /// In en, this message translates to:
  /// **'Sahur ends'**
  String get sahurEnds;

  /// No description provided for @iftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftar;

  /// No description provided for @fastLength.
  ///
  /// In en, this message translates to:
  /// **'{d} from dawn to sunset'**
  String fastLength(String d);

  /// No description provided for @sunnahMonday.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow is Monday — a sunnah fast.'**
  String get sunnahMonday;

  /// No description provided for @sunnahThursday.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow is Thursday — a sunnah fast.'**
  String get sunnahThursday;

  /// No description provided for @whiteDays.
  ///
  /// In en, this message translates to:
  /// **'White days'**
  String get whiteDays;

  /// No description provided for @whiteDaysHint.
  ///
  /// In en, this message translates to:
  /// **'The 13th, 14th and 15th of every Hijri month.'**
  String get whiteDaysHint;

  /// No description provided for @approx.
  ///
  /// In en, this message translates to:
  /// **'approx.'**
  String get approx;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// No description provided for @kmToKaaba.
  ///
  /// In en, this message translates to:
  /// **'km to the Kaaba'**
  String get kmToKaaba;

  /// No description provided for @facingQibla.
  ///
  /// In en, this message translates to:
  /// **'You\'re facing the Qibla'**
  String get facingQibla;

  /// No description provided for @turnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right {deg}°'**
  String turnRight(String deg);

  /// No description provided for @turnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left {deg}°'**
  String turnLeft(String deg);

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the dial to line it up'**
  String get dragHint;

  /// No description provided for @compassN.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get compassN;

  /// No description provided for @compassE.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get compassE;

  /// No description provided for @compassS.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get compassS;

  /// No description provided for @compassW.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get compassW;

  /// No description provided for @dirN.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get dirN;

  /// No description provided for @dirNE.
  ///
  /// In en, this message translates to:
  /// **'Northeast'**
  String get dirNE;

  /// No description provided for @dirE.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get dirE;

  /// No description provided for @dirSE.
  ///
  /// In en, this message translates to:
  /// **'Southeast'**
  String get dirSE;

  /// No description provided for @dirS.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get dirS;

  /// No description provided for @dirSW.
  ///
  /// In en, this message translates to:
  /// **'Southwest'**
  String get dirSW;

  /// No description provided for @dirW.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get dirW;

  /// No description provided for @dirNW.
  ///
  /// In en, this message translates to:
  /// **'Northwest'**
  String get dirNW;

  /// No description provided for @tasbihTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbihTitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @afterSalah.
  ///
  /// In en, this message translates to:
  /// **'After salah · {i} of {n}'**
  String afterSalah(String i, String n);

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to count'**
  String get tapToCount;

  /// No description provided for @todayTotal.
  ///
  /// In en, this message translates to:
  /// **'{n} today'**
  String todayTotal(String n);

  /// No description provided for @setComplete.
  ///
  /// In en, this message translates to:
  /// **'Adhkar complete — may Allah accept them.'**
  String get setComplete;

  /// No description provided for @zakatTitle.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get zakatTitle;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @standardClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get standardClassical;

  /// No description provided for @standardCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get standardCommon;

  /// No description provided for @nisabToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s nisab — tap one to measure against'**
  String get nisabToday;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @goldLower.
  ///
  /// In en, this message translates to:
  /// **'gold'**
  String get goldLower;

  /// No description provided for @silverLower.
  ///
  /// In en, this message translates to:
  /// **'silver'**
  String get silverLower;

  /// No description provided for @gramsTimes.
  ///
  /// In en, this message translates to:
  /// **'{g} g × {price}'**
  String gramsTimes(String g, String price);

  /// No description provided for @priceAsOf.
  ///
  /// In en, this message translates to:
  /// **'Market price as of {date}'**
  String priceAsOf(String date);

  /// No description provided for @whatYouOwn.
  ///
  /// In en, this message translates to:
  /// **'What you own'**
  String get whatYouOwn;

  /// No description provided for @whatYouOwe.
  ///
  /// In en, this message translates to:
  /// **'What you owe'**
  String get whatYouOwe;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @fieldCash.
  ///
  /// In en, this message translates to:
  /// **'Cash & bank'**
  String get fieldCash;

  /// No description provided for @fieldGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get fieldGold;

  /// No description provided for @fieldSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get fieldSilver;

  /// No description provided for @fieldInvestments.
  ///
  /// In en, this message translates to:
  /// **'Shares & investments'**
  String get fieldInvestments;

  /// No description provided for @fieldReceivables.
  ///
  /// In en, this message translates to:
  /// **'Money owed to you'**
  String get fieldReceivables;

  /// No description provided for @fieldDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts due now'**
  String get fieldDebts;

  /// No description provided for @gramsUnit.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get gramsUnit;

  /// No description provided for @zakatDue.
  ///
  /// In en, this message translates to:
  /// **'Zakat due'**
  String get zakatDue;

  /// No description provided for @waitingNisab.
  ///
  /// In en, this message translates to:
  /// **'Waiting for today\'s nisab…'**
  String get waitingNisab;

  /// No description provided for @addWhatYouOwn.
  ///
  /// In en, this message translates to:
  /// **'Add what you own'**
  String get addWhatYouOwn;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing you enter leaves your phone.'**
  String get privacyNote;

  /// No description provided for @noZakat.
  ///
  /// In en, this message translates to:
  /// **'No zakat due'**
  String get noZakat;

  /// No description provided for @belowNisab.
  ///
  /// In en, this message translates to:
  /// **'You hold {net}, below the {metal} nisab of {threshold}.'**
  String belowNisab(String net, String metal, String threshold);

  /// No description provided for @aboveNisab.
  ///
  /// In en, this message translates to:
  /// **'2.5% of {net} — above the {metal} nisab of {threshold}.'**
  String aboveNisab(String net, String metal, String threshold);

  /// No description provided for @zakatFootnote.
  ///
  /// In en, this message translates to:
  /// **'Zakat is due once a full lunar year (hawl) has passed while your wealth stayed above the nisab. Gold and silver are valued at the pure (24k) market price. For business stock, property or complex cases, ask a scholar you trust.'**
  String get zakatFootnote;

  /// No description provided for @curEGP.
  ///
  /// In en, this message translates to:
  /// **'Egyptian pound'**
  String get curEGP;

  /// No description provided for @curSAR.
  ///
  /// In en, this message translates to:
  /// **'Saudi riyal'**
  String get curSAR;

  /// No description provided for @curAED.
  ///
  /// In en, this message translates to:
  /// **'UAE dirham'**
  String get curAED;

  /// No description provided for @curKWD.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti dinar'**
  String get curKWD;

  /// No description provided for @curQAR.
  ///
  /// In en, this message translates to:
  /// **'Qatari riyal'**
  String get curQAR;

  /// No description provided for @curJOD.
  ///
  /// In en, this message translates to:
  /// **'Jordanian dinar'**
  String get curJOD;

  /// No description provided for @curMAD.
  ///
  /// In en, this message translates to:
  /// **'Moroccan dirham'**
  String get curMAD;

  /// No description provided for @curTRY.
  ///
  /// In en, this message translates to:
  /// **'Turkish lira'**
  String get curTRY;

  /// No description provided for @curPKR.
  ///
  /// In en, this message translates to:
  /// **'Pakistani rupee'**
  String get curPKR;

  /// No description provided for @curINR.
  ///
  /// In en, this message translates to:
  /// **'Indian rupee'**
  String get curINR;

  /// No description provided for @curBDT.
  ///
  /// In en, this message translates to:
  /// **'Bangladeshi taka'**
  String get curBDT;

  /// No description provided for @curIDR.
  ///
  /// In en, this message translates to:
  /// **'Indonesian rupiah'**
  String get curIDR;

  /// No description provided for @curMYR.
  ///
  /// In en, this message translates to:
  /// **'Malaysian ringgit'**
  String get curMYR;

  /// No description provided for @curUSD.
  ///
  /// In en, this message translates to:
  /// **'US dollar'**
  String get curUSD;

  /// No description provided for @curEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get curEUR;

  /// No description provided for @curGBP.
  ///
  /// In en, this message translates to:
  /// **'British pound'**
  String get curGBP;

  /// No description provided for @curCAD.
  ///
  /// In en, this message translates to:
  /// **'Canadian dollar'**
  String get curCAD;

  /// No description provided for @curAUD.
  ///
  /// In en, this message translates to:
  /// **'Australian dollar'**
  String get curAUD;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// No description provided for @quranSearch.
  ///
  /// In en, this message translates to:
  /// **'Surah name, meaning or number'**
  String get quranSearch;

  /// No description provided for @ayahCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 ayah} other{{n} ayahs}}'**
  String ayahCount(int n);

  /// No description provided for @meccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get medinan;

  /// No description provided for @quranSummary.
  ///
  /// In en, this message translates to:
  /// **'114 surahs · 6,236 ayahs'**
  String get quranSummary;

  /// No description provided for @lastRead.
  ///
  /// In en, this message translates to:
  /// **'Last read'**
  String get lastRead;

  /// No description provided for @markLastRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as last read'**
  String get markLastRead;

  /// No description provided for @markedLastRead.
  ///
  /// In en, this message translates to:
  /// **'Saved as last read'**
  String get markedLastRead;

  /// No description provided for @surahNumber.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surahNumber;

  /// No description provided for @revelation.
  ///
  /// In en, this message translates to:
  /// **'Revelation'**
  String get revelation;

  /// No description provided for @ayahs.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get ayahs;

  /// No description provided for @readSurah.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readSurah;

  /// No description provided for @tapAyahHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any ayah to read its tafsir'**
  String get tapAyahHint;

  /// No description provided for @ayahRef.
  ///
  /// In en, this message translates to:
  /// **'{surah} · Ayah {n}'**
  String ayahRef(String surah, String n);

  /// No description provided for @ayahOf.
  ///
  /// In en, this message translates to:
  /// **'Ayah {n} of {total}'**
  String ayahOf(String n, String total);

  /// No description provided for @viewSurahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get viewSurahs;

  /// No description provided for @viewJuz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get viewJuz;

  /// No description provided for @recentlyRead.
  ///
  /// In en, this message translates to:
  /// **'Recently read'**
  String get recentlyRead;

  /// No description provided for @fromAyah.
  ///
  /// In en, this message translates to:
  /// **'From ayah {n}'**
  String fromAyah(String n);

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @useMyLocationSub.
  ///
  /// In en, this message translates to:
  /// **'Prayer times for where you are now'**
  String get useMyLocationSub;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get locating;

  /// No description provided for @nearCity.
  ///
  /// In en, this message translates to:
  /// **'Method and currency of {city}'**
  String nearCity(String city);

  /// No description provided for @locDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are off.'**
  String get locDisabled;

  /// No description provided for @locDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Tap to try again.'**
  String get locDenied;

  /// No description provided for @locBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked. Allow it in Settings.'**
  String get locBlocked;

  /// No description provided for @locFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. Try again.'**
  String get locFailed;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @pageN.
  ///
  /// In en, this message translates to:
  /// **'Page {n}'**
  String pageN(String n);

  /// No description provided for @juzN.
  ///
  /// In en, this message translates to:
  /// **'Juz {n}'**
  String juzN(String n);

  /// No description provided for @sajdah.
  ///
  /// In en, this message translates to:
  /// **'Sajdah'**
  String get sajdah;

  /// No description provided for @nextSurah.
  ///
  /// In en, this message translates to:
  /// **'Next surah'**
  String get nextSurah;

  /// No description provided for @previousSurah.
  ///
  /// In en, this message translates to:
  /// **'Previous surah'**
  String get previousSurah;

  /// No description provided for @readingSettings.
  ///
  /// In en, this message translates to:
  /// **'Reading settings'**
  String get readingSettings;

  /// No description provided for @mushafType.
  ///
  /// In en, this message translates to:
  /// **'Mushaf'**
  String get mushafType;

  /// No description provided for @mushafUthmani.
  ///
  /// In en, this message translates to:
  /// **'Uthmani script'**
  String get mushafUthmani;

  /// No description provided for @mushafUthmaniSub.
  ///
  /// In en, this message translates to:
  /// **'The Madinah mushaf script'**
  String get mushafUthmaniSub;

  /// No description provided for @mushafTajweed.
  ///
  /// In en, this message translates to:
  /// **'Colour-coded tajweed'**
  String get mushafTajweed;

  /// No description provided for @mushafTajweedSub.
  ///
  /// In en, this message translates to:
  /// **'Uthmani script, rules in colour'**
  String get mushafTajweedSub;

  /// No description provided for @mushafSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple script'**
  String get mushafSimple;

  /// No description provided for @mushafSimpleSub.
  ///
  /// In en, this message translates to:
  /// **'Modern spelling with full diacritics'**
  String get mushafSimpleSub;

  /// No description provided for @mushafPlain.
  ///
  /// In en, this message translates to:
  /// **'Without diacritics'**
  String get mushafPlain;

  /// No description provided for @mushafPlainSub.
  ///
  /// In en, this message translates to:
  /// **'Plain letters, easy to scan'**
  String get mushafPlainSub;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @tajweedKey.
  ///
  /// In en, this message translates to:
  /// **'Colour key'**
  String get tajweedKey;

  /// No description provided for @tjSilent.
  ///
  /// In en, this message translates to:
  /// **'Not pronounced'**
  String get tjSilent;

  /// No description provided for @tjMadd.
  ///
  /// In en, this message translates to:
  /// **'Prolongation (madd)'**
  String get tjMadd;

  /// No description provided for @tjGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Nasalisation (ghunnah)'**
  String get tjGhunnah;

  /// No description provided for @tjIkhfa.
  ///
  /// In en, this message translates to:
  /// **'Concealment (ikhfa)'**
  String get tjIkhfa;

  /// No description provided for @tjIdgham.
  ///
  /// In en, this message translates to:
  /// **'Merging (idgham)'**
  String get tjIdgham;

  /// No description provided for @tjIqlab.
  ///
  /// In en, this message translates to:
  /// **'Conversion (iqlab)'**
  String get tjIqlab;

  /// No description provided for @tjQalqalah.
  ///
  /// In en, this message translates to:
  /// **'Echo (qalqalah)'**
  String get tjQalqalah;

  /// No description provided for @tafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get tafsir;

  /// No description provided for @tafsirMuyassar.
  ///
  /// In en, this message translates to:
  /// **'Al-Muyassar'**
  String get tafsirMuyassar;

  /// No description provided for @tafsirJalalayn.
  ///
  /// In en, this message translates to:
  /// **'Al-Jalalayn'**
  String get tafsirJalalayn;

  /// No description provided for @tafsirBaghawi.
  ///
  /// In en, this message translates to:
  /// **'Al-Baghawi'**
  String get tafsirBaghawi;

  /// No description provided for @tafsirQurtubi.
  ///
  /// In en, this message translates to:
  /// **'Al-Qurtubi'**
  String get tafsirQurtubi;

  /// No description provided for @tafsirWaseet.
  ///
  /// In en, this message translates to:
  /// **'Al-Waseet'**
  String get tafsirWaseet;

  /// No description provided for @tafsirIbnKathir.
  ///
  /// In en, this message translates to:
  /// **'Ibn Kathir (abridged)'**
  String get tafsirIbnKathir;

  /// No description provided for @tafsirSaheeh.
  ///
  /// In en, this message translates to:
  /// **'Saheeh International'**
  String get tafsirSaheeh;

  /// No description provided for @tafsirArabicNote.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get tafsirArabicNote;

  /// No description provided for @tafsirEnglishNote.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get tafsirEnglishNote;

  /// No description provided for @tafsirEmpty.
  ///
  /// In en, this message translates to:
  /// **'This source has no commentary on this ayah.'**
  String get tafsirEmpty;

  /// No description provided for @namesTitle.
  ///
  /// In en, this message translates to:
  /// **'Names of Allah'**
  String get namesTitle;

  /// No description provided for @namesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search a name or meaning'**
  String get namesSearch;

  /// No description provided for @hearIt.
  ///
  /// In en, this message translates to:
  /// **'Hear it'**
  String get hearIt;

  /// No description provided for @duasTitle.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duasTitle;

  /// No description provided for @duasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supplications from the Quran and Sunnah'**
  String get duasSubtitle;

  /// No description provided for @duasCount.
  ///
  /// In en, this message translates to:
  /// **'{duas} supplications in {topics} topics'**
  String duasCount(String duas, String topics);

  /// No description provided for @duasSearch.
  ///
  /// In en, this message translates to:
  /// **'Travel, rain, anxiety, sleep…'**
  String get duasSearch;

  /// No description provided for @duasLoading.
  ///
  /// In en, this message translates to:
  /// **'Fetching about a thousand duas…'**
  String get duasLoading;

  /// No description provided for @noDuaMatch.
  ///
  /// In en, this message translates to:
  /// **'No dua mentions “{query}”.'**
  String noDuaMatch(String query);

  /// No description provided for @duaCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 dua} other{{n} duas}}'**
  String duaCount(int n);

  /// No description provided for @sectionCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 section} other{{n} sections}}'**
  String sectionCount(int n);

  /// No description provided for @ruqyahTitle.
  ///
  /// In en, this message translates to:
  /// **'Ruqyah'**
  String get ruqyahTitle;

  /// No description provided for @ruqyahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Healing and protection through the words of Allah and the supplications of the Prophet ﷺ.'**
  String get ruqyahSubtitle;

  /// No description provided for @recite.
  ///
  /// In en, this message translates to:
  /// **'Recite'**
  String get recite;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @programBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief'**
  String get programBrief;

  /// No description provided for @programMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get programMedium;

  /// No description provided for @programLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get programLong;

  /// No description provided for @listenFull.
  ///
  /// In en, this message translates to:
  /// **'Listen to the full recitation'**
  String get listenFull;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing…'**
  String get playing;

  /// No description provided for @fromQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get fromQuran;

  /// No description provided for @fromSunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get fromSunnah;

  /// No description provided for @showMeaning.
  ///
  /// In en, this message translates to:
  /// **'Show meaning'**
  String get showMeaning;

  /// No description provided for @hideMeaning.
  ///
  /// In en, this message translates to:
  /// **'Hide meaning'**
  String get hideMeaning;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @allFeatures.
  ///
  /// In en, this message translates to:
  /// **'All features'**
  String get allFeatures;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get chooseCity;

  /// No description provided for @asrMethod.
  ///
  /// In en, this message translates to:
  /// **'Asr time'**
  String get asrMethod;

  /// No description provided for @asrStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get asrStandard;

  /// No description provided for @asrHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get asrHanafi;

  /// No description provided for @asrHint.
  ///
  /// In en, this message translates to:
  /// **'Hanafi Asr starts later, when shadows are twice an object\'s length.'**
  String get asrHint;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Prayer times, fasting, nisab, duas, names and ruqyah come from islamicapi.com; Quran text and tafsir from alquran.cloud and quran.com. Your prayer log, tasbih and settings stay on this device.'**
  String get aboutBody;

  /// No description provided for @obSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get obSkip;

  /// No description provided for @obNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get obNext;

  /// No description provided for @obBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get obBack;

  /// No description provided for @obStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get obStart;

  /// No description provided for @obWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get obWelcomeTitle;

  /// No description provided for @obWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A quiet companion for prayer, Quran and remembrance. Let\'s set it up for you — it takes a minute.'**
  String get obWelcomeBody;

  /// No description provided for @obChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get obChooseLanguage;

  /// No description provided for @obLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you pray?'**
  String get obLocationTitle;

  /// No description provided for @obLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Prayer times and the Qibla depend on where you are. Allow location access, or pick a city.'**
  String get obLocationBody;

  /// No description provided for @obChooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city instead'**
  String get obChooseCity;

  /// No description provided for @obNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a prayer'**
  String get obNotifyTitle;

  /// No description provided for @obNotifyBody.
  ///
  /// In en, this message translates to:
  /// **'Get a gentle reminder when each prayer time begins, for the prayers you choose.'**
  String get obNotifyBody;

  /// No description provided for @obAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get obAllowNotifications;

  /// No description provided for @obMushafTitle.
  ///
  /// In en, this message translates to:
  /// **'Your mushaf'**
  String get obMushafTitle;

  /// No description provided for @obMushafBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the script, text size and tafsir you read best. You can change them anytime from the reader.'**
  String get obMushafBody;

  /// No description provided for @obDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'All set'**
  String get obDoneTitle;

  /// No description provided for @obDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what you chose. Tap any item to change it.'**
  String get obDoneBody;

  /// No description provided for @prayerReminders.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders'**
  String get prayerReminders;

  /// No description provided for @prayerRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'A notification when each prayer time begins'**
  String get prayerRemindersSub;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for this app. Allow them in Settings.'**
  String get notificationsDenied;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for {prayer}'**
  String reminderTitle(String prayer);

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Hayya ‘ala as-salah — come to prayer.'**
  String get reminderBody;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindersOff;

  /// No description provided for @remindersCount.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total} prayers'**
  String remindersCount(String n, String total);

  /// No description provided for @defaultTafsir.
  ///
  /// In en, this message translates to:
  /// **'Default tafsir'**
  String get defaultTafsir;

  /// No description provided for @quranReading.
  ///
  /// In en, this message translates to:
  /// **'Quran reading'**
  String get quranReading;

  /// No description provided for @replayTour.
  ///
  /// In en, this message translates to:
  /// **'Show the welcome tour'**
  String get replayTour;

  /// No description provided for @featReciters.
  ///
  /// In en, this message translates to:
  /// **'Reciters'**
  String get featReciters;

  /// No description provided for @featRecitersSub.
  ///
  /// In en, this message translates to:
  /// **'Full surahs from 240+ reciters, offline too'**
  String get featRecitersSub;

  /// No description provided for @recitersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search reciters'**
  String get recitersSearch;

  /// No description provided for @surahCount.
  ///
  /// In en, this message translates to:
  /// **'{n} surahs'**
  String surahCount(String n);

  /// No description provided for @listenFromHere.
  ///
  /// In en, this message translates to:
  /// **'Listen from here'**
  String get listenFromHere;

  /// No description provided for @listenPage.
  ///
  /// In en, this message translates to:
  /// **'Listen to this page'**
  String get listenPage;

  /// No description provided for @ayahReciter.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get ayahReciter;

  /// No description provided for @ayahReciterSub.
  ///
  /// In en, this message translates to:
  /// **'Recites ayah by ayah as you read'**
  String get ayahReciterSub;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @removeDownload.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get removeDownload;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection.'**
  String get downloadFailed;

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline'**
  String get savedOffline;

  /// No description provided for @playbackError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play. Tap to retry.'**
  String get playbackError;

  /// No description provided for @playTip.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playTip;

  /// No description provided for @pauseTip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTip;

  /// No description provided for @nextTip.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextTip;

  /// No description provided for @previousTip.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousTip;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get playAll;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get recentlyPlayed;

  /// No description provided for @popularReciters.
  ///
  /// In en, this message translates to:
  /// **'Popular reciters'**
  String get popularReciters;

  /// No description provided for @allReciters.
  ///
  /// In en, this message translates to:
  /// **'All reciters'**
  String get allReciters;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlaying;

  /// No description provided for @fromMushaf.
  ///
  /// In en, this message translates to:
  /// **'From the mushaf'**
  String get fromMushaf;

  /// No description provided for @openInMushaf.
  ///
  /// In en, this message translates to:
  /// **'Open in the mushaf'**
  String get openInMushaf;

  /// No description provided for @repeatTip.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatTip;

  /// No description provided for @searchTip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTip;

  /// No description provided for @ambientTitle.
  ///
  /// In en, this message translates to:
  /// **'Background sounds'**
  String get ambientTitle;

  /// No description provided for @ambientSub.
  ///
  /// In en, this message translates to:
  /// **'Mix calm sounds under the recitation'**
  String get ambientSub;

  /// No description provided for @ambientRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get ambientRain;

  /// No description provided for @ambientStorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get ambientStorm;

  /// No description provided for @ambientFire.
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get ambientFire;

  /// No description provided for @ambientWaves.
  ///
  /// In en, this message translates to:
  /// **'Ocean waves'**
  String get ambientWaves;

  /// No description provided for @ambientBirds.
  ///
  /// In en, this message translates to:
  /// **'Forest birds'**
  String get ambientBirds;

  /// No description provided for @ambientNight.
  ///
  /// In en, this message translates to:
  /// **'Quiet night'**
  String get ambientNight;

  /// No description provided for @ambientWind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get ambientWind;

  /// No description provided for @ambientClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get ambientClear;

  /// No description provided for @adhanVoice.
  ///
  /// In en, this message translates to:
  /// **'Adhan voice'**
  String get adhanVoice;

  /// No description provided for @adhanPlainSound.
  ///
  /// In en, this message translates to:
  /// **'Notification sound only'**
  String get adhanPlainSound;

  /// No description provided for @adhanIosNote.
  ///
  /// In en, this message translates to:
  /// **'iPhone plays the first 30 seconds of the adhan with the notification.'**
  String get adhanIosNote;

  /// No description provided for @previewTip.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewTip;

  /// No description provided for @featHisn.
  ///
  /// In en, this message translates to:
  /// **'Hisn al-Muslim'**
  String get featHisn;

  /// No description provided for @featHisnSub.
  ///
  /// In en, this message translates to:
  /// **'Fortress of the Muslim — adhkar for every moment'**
  String get featHisnSub;

  /// No description provided for @featAzkar.
  ///
  /// In en, this message translates to:
  /// **'Morning & evening'**
  String get featAzkar;

  /// No description provided for @featAzkarSub.
  ///
  /// In en, this message translates to:
  /// **'Daily adhkar with a counter'**
  String get featAzkarSub;

  /// No description provided for @morningAzkar.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar'**
  String get morningAzkar;

  /// No description provided for @eveningAzkar.
  ///
  /// In en, this message translates to:
  /// **'Evening adhkar'**
  String get eveningAzkar;

  /// No description provided for @azkarProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String azkarProgress(String done, String total);

  /// No description provided for @azkarAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done today — may Allah accept.'**
  String get azkarAllDone;

  /// No description provided for @azkarTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to count'**
  String get azkarTapHint;

  /// No description provided for @azkarStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get azkarStart;

  /// No description provided for @azkarContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get azkarContinue;

  /// No description provided for @azkarReset.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get azkarReset;

  /// No description provided for @azkarResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear today\'s counts for this session?'**
  String get azkarResetConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @timesCount.
  ///
  /// In en, this message translates to:
  /// **'×{n}'**
  String timesCount(String n);

  /// No description provided for @hisnSearch.
  ///
  /// In en, this message translates to:
  /// **'Search chapters or words'**
  String get hisnSearch;

  /// No description provided for @hisnChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get hisnChapters;

  /// No description provided for @hisnChapterCount.
  ///
  /// In en, this message translates to:
  /// **'{n} chapters'**
  String hisnChapterCount(String n);

  /// No description provided for @noHisnMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing found for “{q}”'**
  String noHisnMatch(String q);

  /// No description provided for @hisnSource.
  ///
  /// In en, this message translates to:
  /// **'From Hisn al-Muslim by Sa‘id ibn Wahf al-Qahtani.'**
  String get hisnSource;

  /// No description provided for @hisnLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the book.'**
  String get hisnLoadFailed;

  /// No description provided for @azkarReminders.
  ///
  /// In en, this message translates to:
  /// **'Adhkar reminders'**
  String get azkarReminders;

  /// No description provided for @azkarRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'A daily nudge for the morning and evening adhkar'**
  String get azkarRemindersSub;

  /// No description provided for @azkarReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Take a few minutes for your adhkar.'**
  String get azkarReminderBody;

  /// No description provided for @azkarRemindAt.
  ///
  /// In en, this message translates to:
  /// **'Remind me at {time}'**
  String azkarRemindAt(String time);

  /// No description provided for @azkarOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get azkarOff;

  /// No description provided for @listenTip.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listenTip;

  /// No description provided for @copyTip.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyTip;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @photoCredit.
  ///
  /// In en, this message translates to:
  /// **'Photo: {author} · {licence} · Wikimedia Commons'**
  String photoCredit(String author, String licence);

  /// No description provided for @widgetVerse.
  ///
  /// In en, this message translates to:
  /// **'A verse'**
  String get widgetVerse;

  /// No description provided for @widgetDua.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get widgetDua;

  /// No description provided for @widgetEmpty.
  ///
  /// In en, this message translates to:
  /// **'Open the app to load'**
  String get widgetEmpty;

  /// No description provided for @widgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Home & lock screen widgets'**
  String get widgetsTitle;

  /// No description provided for @widgetPrayerSub.
  ///
  /// In en, this message translates to:
  /// **'Time left until the next prayer'**
  String get widgetPrayerSub;

  /// No description provided for @widgetAyahSub.
  ///
  /// In en, this message translates to:
  /// **'A new verse every half hour'**
  String get widgetAyahSub;

  /// No description provided for @widgetDuaSub.
  ///
  /// In en, this message translates to:
  /// **'A new dua every half hour'**
  String get widgetDuaSub;

  /// No description provided for @widgetNameSub.
  ///
  /// In en, this message translates to:
  /// **'A name of Allah every half hour'**
  String get widgetNameSub;

  /// No description provided for @widgetAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get widgetAdd;

  /// No description provided for @widgetAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Your launcher can\'t add widgets from here. Long-press the home screen and choose Widgets.'**
  String get widgetAddFailed;

  /// No description provided for @widgetIosHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press the home or lock screen, tap Edit or +, then search for Muslim.'**
  String get widgetIosHint;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return L10nAr();
    case 'en':
      return L10nEn();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
