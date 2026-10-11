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
  /// **'The API key is missing. Run the app with --dart-define-from-file=env.json'**
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
  /// **'All 114 surahs'**
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
  /// **'Prayer times, fasting, nisab, duas, names and ruqyah come from islamicapi.com. Your prayer log, tasbih and settings stay on this device.'**
  String get aboutBody;
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
