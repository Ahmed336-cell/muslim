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
  /// **'Sabeelak'**
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

  /// No description provided for @sebhaCustomize.
  ///
  /// In en, this message translates to:
  /// **'Sebha look'**
  String get sebhaCustomize;

  /// No description provided for @sebhaCustomizeSub.
  ///
  /// In en, this message translates to:
  /// **'Pick a bead style and color.'**
  String get sebhaCustomizeSub;

  /// No description provided for @sebhaType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get sebhaType;

  /// No description provided for @sebhaColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get sebhaColor;

  /// No description provided for @sebhaStyleWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get sebhaStyleWood;

  /// No description provided for @sebhaStyleAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get sebhaStyleAmber;

  /// No description provided for @sebhaStyleStone.
  ///
  /// In en, this message translates to:
  /// **'Stone'**
  String get sebhaStyleStone;

  /// No description provided for @sebhaStylePearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get sebhaStylePearl;

  /// No description provided for @sebhaStyleDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get sebhaStyleDigital;

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
  /// **'Surah, number, 2:255 or words of an ayah'**
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
  /// **'Prayer times and the Hijri date are calculated on this device. The Quran text is bundled; recitations, tafsir and other content are downloaded from the sources in Credits. Your prayer log, tasbih and settings stay on this device.'**
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

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateApp;

  /// No description provided for @rateAppSub.
  ///
  /// In en, this message translates to:
  /// **'A rating on Google Play helps others find Sabeelak.'**
  String get rateAppSub;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'A new version is on the Play Store. Update to keep using Sabeelak.'**
  String get forceUpdateBody;

  /// No description provided for @forceUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get forceUpdateAction;

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
  /// **'Long-press the home or lock screen, tap Edit or +, then search for Sabeelak.'**
  String get widgetIosHint;

  /// No description provided for @calcMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get calcMethod;

  /// No description provided for @calcCityDefault.
  ///
  /// In en, this message translates to:
  /// **'Recommended for {city}'**
  String calcCityDefault(String city);

  /// No description provided for @calcOffline.
  ///
  /// In en, this message translates to:
  /// **'Times are calculated on your device, so they work offline.'**
  String get calcOffline;

  /// No description provided for @adjustTimes.
  ///
  /// In en, this message translates to:
  /// **'Adjust times'**
  String get adjustTimes;

  /// No description provided for @adjustTimesSub.
  ///
  /// In en, this message translates to:
  /// **'Add or subtract minutes to match your local mosque.'**
  String get adjustTimesSub;

  /// No description provided for @adjustNone.
  ///
  /// In en, this message translates to:
  /// **'No adjustments'**
  String get adjustNone;

  /// No description provided for @adjustSome.
  ///
  /// In en, this message translates to:
  /// **'Custom adjustments'**
  String get adjustSome;

  /// No description provided for @hijriAdjust.
  ///
  /// In en, this message translates to:
  /// **'Hijri date'**
  String get hijriAdjust;

  /// No description provided for @hijriAdjustSub.
  ///
  /// In en, this message translates to:
  /// **'Shift by a day if the moon was sighted differently where you live.'**
  String get hijriAdjustSub;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits & licences'**
  String get credits;

  /// No description provided for @creditsSub.
  ///
  /// In en, this message translates to:
  /// **'Sources of the Quran text, audio and data'**
  String get creditsSub;

  /// No description provided for @creditsPhotos.
  ///
  /// In en, this message translates to:
  /// **'Reciter photos'**
  String get creditsPhotos;

  /// No description provided for @creditsPhotosSub.
  ///
  /// In en, this message translates to:
  /// **'Wikimedia Commons; the author and licence also appear under each photo.'**
  String get creditsPhotosSub;

  /// No description provided for @openSourceLicences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get openSourceLicences;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySub.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads'**
  String get privacyPolicySub;

  /// No description provided for @privacyNoAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads'**
  String get privacyNoAccountTitle;

  /// No description provided for @privacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'The app has no sign-in or ads. Your prayer log, tasbih counts, bookmarks, Khatmah progress and settings are stored only on this device and are deleted with the app.'**
  String get privacyNoAccount;

  /// No description provided for @privacyCrashesTitle.
  ///
  /// In en, this message translates to:
  /// **'Crash reports'**
  String get privacyCrashesTitle;

  /// No description provided for @privacyCrashes.
  ///
  /// In en, this message translates to:
  /// **'If the app crashes or hits an error, a report is sent to Sentry (sentry.io): the error, a stack trace, the app version and the device type. It does not include your name, location, prayer log or anything you typed.'**
  String get privacyCrashes;

  /// No description provided for @privacyLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get privacyLocationTitle;

  /// No description provided for @privacyLocation.
  ///
  /// In en, this message translates to:
  /// **'If you choose \"my location\", your position is used on the device to calculate prayer times and the qibla. It is rounded to about 100 m and is only sent to islamicapi.com to fetch fasting times. It is never stored on a server by us.'**
  String get privacyLocation;

  /// No description provided for @privacyNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Online content'**
  String get privacyNetworkTitle;

  /// No description provided for @privacyNetwork.
  ///
  /// In en, this message translates to:
  /// **'Recitations, tafsir, duas and other content are downloaded from the services listed in Credits. Those services see your IP address like any website. Downloads are cached on the device so they work offline.'**
  String get privacyNetwork;

  /// No description provided for @privacyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications and widgets'**
  String get privacyNotificationsTitle;

  /// No description provided for @privacyNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminders are scheduled locally on the device. Widgets read data the app saves on the device; nothing is sent anywhere.'**
  String get privacyNotifications;

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get privacyContactTitle;

  /// No description provided for @privacyContact.
  ///
  /// In en, this message translates to:
  /// **'For any privacy question, contact the developer through the app store listing.'**
  String get privacyContact;

  /// No description provided for @ayahMatches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ayah} other{{count} ayahs}}'**
  String ayahMatches(int count);

  /// No description provided for @ayahMatchesMore.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {shown}. Add a word to narrow it down.'**
  String ayahMatchesMore(String shown);

  /// No description provided for @goToAyah.
  ///
  /// In en, this message translates to:
  /// **'Go to {surah}, ayah {ayah}'**
  String goToAyah(String surah, String ayah);

  /// No description provided for @searchArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Type Arabic words to search inside ayahs.'**
  String get searchArabicHint;

  /// No description provided for @khatmah.
  ///
  /// In en, this message translates to:
  /// **'Khatmah'**
  String get khatmah;

  /// No description provided for @khatmahSub.
  ///
  /// In en, this message translates to:
  /// **'Plan to finish the whole Quran'**
  String get khatmahSub;

  /// No description provided for @khatmahIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick how many days you want to finish the Quran in. We\'ll split it into a daily portion and track the pages you read.'**
  String get khatmahIntro;

  /// No description provided for @khatmahFinishIn.
  ///
  /// In en, this message translates to:
  /// **'Finish in'**
  String get khatmahFinishIn;

  /// No description provided for @khatmahDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String khatmahDays(String n);

  /// No description provided for @khatmahPerDay.
  ///
  /// In en, this message translates to:
  /// **'≈ {n} pages a day'**
  String khatmahPerDay(String n);

  /// No description provided for @khatmahStart.
  ///
  /// In en, this message translates to:
  /// **'Start khatmah'**
  String get khatmahStart;

  /// No description provided for @khatmahToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s portion'**
  String get khatmahToday;

  /// No description provided for @khatmahTodayGoal.
  ///
  /// In en, this message translates to:
  /// **'{read} of {target} pages'**
  String khatmahTodayGoal(String read, String target);

  /// No description provided for @khatmahTodayDone.
  ///
  /// In en, this message translates to:
  /// **'Today\'s portion is done. Barak Allahu feek!'**
  String get khatmahTodayDone;

  /// No description provided for @khatmahPages.
  ///
  /// In en, this message translates to:
  /// **'{read} of {total} pages'**
  String khatmahPages(String read, String total);

  /// No description provided for @khatmahDayOf.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {days}'**
  String khatmahDayOf(String day, String days);

  /// No description provided for @khatmahStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get khatmahStreak;

  /// No description provided for @khatmahStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String khatmahStreakDays(String n);

  /// No description provided for @khatmahAhead.
  ///
  /// In en, this message translates to:
  /// **'Ahead of schedule'**
  String get khatmahAhead;

  /// No description provided for @khatmahOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get khatmahOnTrack;

  /// No description provided for @khatmahBehind.
  ///
  /// In en, this message translates to:
  /// **'{n} pages behind'**
  String khatmahBehind(String n);

  /// No description provided for @khatmahContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue from page {page}'**
  String khatmahContinue(String page);

  /// No description provided for @khatmahHint.
  ///
  /// In en, this message translates to:
  /// **'A page counts once you turn past it or keep it open for 20 seconds.'**
  String get khatmahHint;

  /// No description provided for @khatmahDone.
  ///
  /// In en, this message translates to:
  /// **'You finished the Quran. May Allah accept it from you!'**
  String get khatmahDone;

  /// No description provided for @khatmahCompleted.
  ///
  /// In en, this message translates to:
  /// **'Khatmahs completed: {n}'**
  String khatmahCompleted(String n);

  /// No description provided for @khatmahNew.
  ///
  /// In en, this message translates to:
  /// **'Start a new khatmah'**
  String get khatmahNew;

  /// No description provided for @khatmahEnd.
  ///
  /// In en, this message translates to:
  /// **'End plan'**
  String get khatmahEnd;

  /// No description provided for @khatmahEndConfirm.
  ///
  /// In en, this message translates to:
  /// **'End this khatmah? Its progress will be cleared.'**
  String get khatmahEndConfirm;

  /// No description provided for @khatmahReadUpTo.
  ///
  /// In en, this message translates to:
  /// **'Already read some?'**
  String get khatmahReadUpTo;

  /// No description provided for @khatmahReadUpToSub.
  ///
  /// In en, this message translates to:
  /// **'Mark every page up to page {page} as read.'**
  String khatmahReadUpToSub(String page);

  /// No description provided for @khatmahMark.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get khatmahMark;

  /// No description provided for @featCalendar.
  ///
  /// In en, this message translates to:
  /// **'Hijri calendar'**
  String get featCalendar;

  /// No description provided for @featCalendarSub.
  ///
  /// In en, this message translates to:
  /// **'Months and Islamic occasions'**
  String get featCalendarSub;

  /// No description provided for @featKhatmah.
  ///
  /// In en, this message translates to:
  /// **'Khatmah'**
  String get featKhatmah;

  /// No description provided for @featKhatmahSub.
  ///
  /// In en, this message translates to:
  /// **'Daily wird to finish the Quran'**
  String get featKhatmahSub;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get calendarUpcoming;

  /// No description provided for @calendarWhiteDays.
  ///
  /// In en, this message translates to:
  /// **'White days (13–15): recommended fasting'**
  String get calendarWhiteDays;

  /// No description provided for @calendarInDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{Today} =1{Tomorrow} other{In {n} days}}'**
  String calendarInDays(int n);

  /// No description provided for @calendarNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No occasions on this day.'**
  String get calendarNoEvents;

  /// No description provided for @calendarShiftNote.
  ///
  /// In en, this message translates to:
  /// **'Dates follow the Umm al-Qura calendar. Adjust by a day in Settings → Adjust times if your country sighted the moon differently.'**
  String get calendarShiftNote;

  /// No description provided for @evNewYear.
  ///
  /// In en, this message translates to:
  /// **'Islamic New Year'**
  String get evNewYear;

  /// No description provided for @evNewYearSub.
  ///
  /// In en, this message translates to:
  /// **'1 Muharram'**
  String get evNewYearSub;

  /// No description provided for @evAshura.
  ///
  /// In en, this message translates to:
  /// **'Day of Ashura'**
  String get evAshura;

  /// No description provided for @evAshuraSub.
  ///
  /// In en, this message translates to:
  /// **'Fasting it expiates the past year; fast the 9th too.'**
  String get evAshuraSub;

  /// No description provided for @evRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan begins'**
  String get evRamadan;

  /// No description provided for @evRamadanSub.
  ///
  /// In en, this message translates to:
  /// **'The month of fasting'**
  String get evRamadanSub;

  /// No description provided for @evLastTen.
  ///
  /// In en, this message translates to:
  /// **'Last ten nights'**
  String get evLastTen;

  /// No description provided for @evLastTenSub.
  ///
  /// In en, this message translates to:
  /// **'Seek Laylat al-Qadr in the odd nights.'**
  String get evLastTenSub;

  /// No description provided for @evEidFitr.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr'**
  String get evEidFitr;

  /// No description provided for @evEidFitrSub.
  ///
  /// In en, this message translates to:
  /// **'Then six days of Shawwal'**
  String get evEidFitrSub;

  /// No description provided for @evDhulHijjah.
  ///
  /// In en, this message translates to:
  /// **'First ten days of Dhul Hijjah'**
  String get evDhulHijjah;

  /// No description provided for @evDhulHijjahSub.
  ///
  /// In en, this message translates to:
  /// **'The best days of the year for good deeds'**
  String get evDhulHijjahSub;

  /// No description provided for @evArafah.
  ///
  /// In en, this message translates to:
  /// **'Day of Arafah'**
  String get evArafah;

  /// No description provided for @evArafahSub.
  ///
  /// In en, this message translates to:
  /// **'Fasting it expiates two years.'**
  String get evArafahSub;

  /// No description provided for @evEidAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha'**
  String get evEidAdha;

  /// No description provided for @evEidAdhaSub.
  ///
  /// In en, this message translates to:
  /// **'The day of sacrifice'**
  String get evEidAdhaSub;

  /// No description provided for @evTashreeq.
  ///
  /// In en, this message translates to:
  /// **'Days of Tashreeq'**
  String get evTashreeq;

  /// No description provided for @evTashreeqSub.
  ///
  /// In en, this message translates to:
  /// **'11–13 Dhul Hijjah: days of eating and remembrance'**
  String get evTashreeqSub;

  /// No description provided for @featHifz.
  ///
  /// In en, this message translates to:
  /// **'Hifz'**
  String get featHifz;

  /// No description provided for @featHifzSub.
  ///
  /// In en, this message translates to:
  /// **'Memorise with repetition'**
  String get featHifzSub;

  /// No description provided for @hifzSurah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get hifzSurah;

  /// No description provided for @hifzRange.
  ///
  /// In en, this message translates to:
  /// **'Ayahs {from}–{to}'**
  String hifzRange(String from, String to);

  /// No description provided for @hifzAyahRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat each ayah'**
  String get hifzAyahRepeat;

  /// No description provided for @hifzRangeRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat the whole range'**
  String get hifzRangeRepeat;

  /// No description provided for @hifzTimes.
  ///
  /// In en, this message translates to:
  /// **'{n}×'**
  String hifzTimes(String n);

  /// No description provided for @hifzPlay.
  ///
  /// In en, this message translates to:
  /// **'Start listening'**
  String get hifzPlay;

  /// No description provided for @hifzStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get hifzStop;

  /// No description provided for @hifzShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get hifzShow;

  /// No description provided for @hifzFirstWords.
  ///
  /// In en, this message translates to:
  /// **'First words'**
  String get hifzFirstWords;

  /// No description provided for @hifzHideAll.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hifzHideAll;

  /// No description provided for @hifzTapReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get hifzTapReveal;

  /// No description provided for @hifzMemorized.
  ///
  /// In en, this message translates to:
  /// **'Memorised {n} of {total} ayahs in this surah'**
  String hifzMemorized(String n, String total);

  /// No description provided for @hifzMark.
  ///
  /// In en, this message translates to:
  /// **'Mark as memorised'**
  String get hifzMark;

  /// No description provided for @hifzUnmark.
  ///
  /// In en, this message translates to:
  /// **'Memorised'**
  String get hifzUnmark;

  /// No description provided for @hifzTestHint.
  ///
  /// In en, this message translates to:
  /// **'Hide the text, recite from memory, then tap an ayah to check yourself.'**
  String get hifzTestHint;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @tracker.
  ///
  /// In en, this message translates to:
  /// **'Prayer tracker'**
  String get tracker;

  /// No description provided for @featTracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get featTracker;

  /// No description provided for @featTrackerSub.
  ///
  /// In en, this message translates to:
  /// **'Streaks, history and missed prayers'**
  String get featTrackerSub;

  /// No description provided for @trackerWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get trackerWeek;

  /// No description provided for @trackerByPrayer.
  ///
  /// In en, this message translates to:
  /// **'By prayer · 30 days'**
  String get trackerByPrayer;

  /// No description provided for @trackerStreak.
  ///
  /// In en, this message translates to:
  /// **'Days with all five'**
  String get trackerStreak;

  /// No description provided for @trackerLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get trackerLast7;

  /// No description provided for @trackerLast30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get trackerLast30;

  /// No description provided for @trackerTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a circle to log a prayer on an earlier day.'**
  String get trackerTapHint;

  /// No description provided for @trackerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Mark your prayers on the home screen to see stats here.'**
  String get trackerEmpty;

  /// No description provided for @qadaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qada · missed prayers'**
  String get qadaTitle;

  /// No description provided for @qadaNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing to make up'**
  String get qadaNone;

  /// No description provided for @qadaLeft.
  ///
  /// In en, this message translates to:
  /// **'{n} prayers to make up'**
  String qadaLeft(String n);

  /// No description provided for @qadaHint.
  ///
  /// In en, this message translates to:
  /// **'Add the prayers you owe, then tap − each time you make one up.'**
  String get qadaHint;

  /// No description provided for @qadaMadeUp.
  ///
  /// In en, this message translates to:
  /// **'Made one up'**
  String get qadaMadeUp;

  /// No description provided for @qadaAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get qadaAdd;

  /// No description provided for @featRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get featRamadan;

  /// No description provided for @featRamadanSub.
  ///
  /// In en, this message translates to:
  /// **'Iftar countdown, duas and a 30-day tracker'**
  String get featRamadanSub;

  /// No description provided for @featFriday.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah'**
  String get featFriday;

  /// No description provided for @featFridaySub.
  ///
  /// In en, this message translates to:
  /// **'Al-Kahf, salawat and the last hour'**
  String get featFridaySub;

  /// No description provided for @dailyAyahTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayah of the day'**
  String get dailyAyahTitle;

  /// No description provided for @kahfReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Friday · Surah Al-Kahf'**
  String get kahfReminderTitle;

  /// No description provided for @kahfReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Read Surah Al-Kahf today — a light between two Fridays.'**
  String get kahfReminderBody;

  /// No description provided for @fridayHourTitle.
  ///
  /// In en, this message translates to:
  /// **'The last hour of Friday'**
  String get fridayHourTitle;

  /// No description provided for @fridayHourBody.
  ///
  /// In en, this message translates to:
  /// **'Last hour before Maghrib — make du\'a.\n\nرَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n\nOur Lord, give us good in this world and the Hereafter, and protect us from the Fire.'**
  String get fridayHourBody;

  /// No description provided for @fridayHourRange.
  ///
  /// In en, this message translates to:
  /// **'From {from} until Maghrib at {to}'**
  String fridayHourRange(String from, String to);

  /// No description provided for @suhoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Suhoor'**
  String get suhoorTitle;

  /// No description provided for @suhoorBody.
  ///
  /// In en, this message translates to:
  /// **'Fajr is in {n} minutes — time for suhoor.'**
  String suhoorBody(String n);

  /// No description provided for @dailyAyahReminder.
  ///
  /// In en, this message translates to:
  /// **'Ayah of the day'**
  String get dailyAyahReminder;

  /// No description provided for @kahfReminder.
  ///
  /// In en, this message translates to:
  /// **'Surah Al-Kahf on Friday'**
  String get kahfReminder;

  /// No description provided for @kahfReminderSub.
  ///
  /// In en, this message translates to:
  /// **'Friday at 10:00 AM'**
  String get kahfReminderSub;

  /// No description provided for @fridayHourReminder.
  ///
  /// In en, this message translates to:
  /// **'Last hour of Friday'**
  String get fridayHourReminder;

  /// No description provided for @fridayHourReminderSub.
  ///
  /// In en, this message translates to:
  /// **'An hour before Maghrib'**
  String get fridayHourReminderSub;

  /// No description provided for @suhoorReminder.
  ///
  /// In en, this message translates to:
  /// **'Suhoor in Ramadan'**
  String get suhoorReminder;

  /// No description provided for @suhoorReminderSub.
  ///
  /// In en, this message translates to:
  /// **'45 minutes before Fajr'**
  String get suhoorReminderSub;

  /// No description provided for @moreReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily & weekly reminders'**
  String get moreReminders;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @jumuahMubarak.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah Mubarak'**
  String get jumuahMubarak;

  /// No description provided for @fridayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Friday is tomorrow'**
  String get fridayTomorrow;

  /// No description provided for @fridayIn.
  ///
  /// In en, this message translates to:
  /// **'Friday in {n} days'**
  String fridayIn(String n);

  /// No description provided for @fridayIntro.
  ///
  /// In en, this message translates to:
  /// **'The best day the sun rises on.'**
  String get fridayIntro;

  /// No description provided for @fridayHomeSub.
  ///
  /// In en, this message translates to:
  /// **'Al-Kahf, salawat and the last hour'**
  String get fridayHomeSub;

  /// No description provided for @fridaySunnahs.
  ///
  /// In en, this message translates to:
  /// **'Sunnahs of Friday'**
  String get fridaySunnahs;

  /// No description provided for @sunnahGhusl.
  ///
  /// In en, this message translates to:
  /// **'Take a ghusl (full bath) before the prayer.'**
  String get sunnahGhusl;

  /// No description provided for @sunnahClothes.
  ///
  /// In en, this message translates to:
  /// **'Wear your best clothes and use perfume.'**
  String get sunnahClothes;

  /// No description provided for @sunnahEarly.
  ///
  /// In en, this message translates to:
  /// **'Go early to the mosque, walking if you can.'**
  String get sunnahEarly;

  /// No description provided for @sunnahKhutbah.
  ///
  /// In en, this message translates to:
  /// **'Listen to the khutbah in silence.'**
  String get sunnahKhutbah;

  /// No description provided for @sunnahKahf.
  ///
  /// In en, this message translates to:
  /// **'Read Surah Al-Kahf.'**
  String get sunnahKahf;

  /// No description provided for @sunnahSalawat.
  ///
  /// In en, this message translates to:
  /// **'Send plenty of salawat on the Prophet ﷺ.'**
  String get sunnahSalawat;

  /// No description provided for @sunnahDua.
  ///
  /// In en, this message translates to:
  /// **'Make du\'a, especially in the last hour before Maghrib.'**
  String get sunnahDua;

  /// No description provided for @readKahf.
  ///
  /// In en, this message translates to:
  /// **'Read Surah Al-Kahf'**
  String get readKahf;

  /// No description provided for @kahfHint.
  ///
  /// In en, this message translates to:
  /// **'Tick it once you\'ve read it today.'**
  String get kahfHint;

  /// No description provided for @kahfDone.
  ///
  /// In en, this message translates to:
  /// **'Read today — may Allah accept it.'**
  String get kahfDone;

  /// No description provided for @salawatCounter.
  ///
  /// In en, this message translates to:
  /// **'Salawat on the Prophet ﷺ'**
  String get salawatCounter;

  /// No description provided for @salawatHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the circle with each one.'**
  String get salawatHint;

  /// No description provided for @iftarDua.
  ///
  /// In en, this message translates to:
  /// **'Dua when breaking the fast'**
  String get iftarDua;

  /// No description provided for @iftarDuaMeaning.
  ///
  /// In en, this message translates to:
  /// **'The thirst has gone, the veins are moistened, and the reward is certain, if Allah wills.'**
  String get iftarDuaMeaning;

  /// No description provided for @iftarDuaSource.
  ///
  /// In en, this message translates to:
  /// **'Abu Dawud'**
  String get iftarDuaSource;

  /// No description provided for @qadrDua.
  ///
  /// In en, this message translates to:
  /// **'Dua for Laylat al-Qadr'**
  String get qadrDua;

  /// No description provided for @qadrDuaMeaning.
  ///
  /// In en, this message translates to:
  /// **'O Allah, You are Pardoning and love to pardon, so pardon me.'**
  String get qadrDuaMeaning;

  /// No description provided for @qadrDuaSource.
  ///
  /// In en, this message translates to:
  /// **'At-Tirmidhi'**
  String get qadrDuaSource;

  /// No description provided for @ramadanTracker.
  ///
  /// In en, this message translates to:
  /// **'Ramadan {year}'**
  String ramadanTracker(String year);

  /// No description provided for @ramadanDay.
  ///
  /// In en, this message translates to:
  /// **'Day {n} of Ramadan'**
  String ramadanDay(String n);

  /// No description provided for @iftarIn.
  ///
  /// In en, this message translates to:
  /// **'Iftar in'**
  String get iftarIn;

  /// No description provided for @suhoorEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends in'**
  String get suhoorEndsIn;

  /// No description provided for @ramadanIn.
  ///
  /// In en, this message translates to:
  /// **'Ramadan in {n} days'**
  String ramadanIn(String n);

  /// No description provided for @deedFast.
  ///
  /// In en, this message translates to:
  /// **'Fasted'**
  String get deedFast;

  /// No description provided for @deedTaraweeh.
  ///
  /// In en, this message translates to:
  /// **'Taraweeh'**
  String get deedTaraweeh;

  /// No description provided for @deedJuz.
  ///
  /// In en, this message translates to:
  /// **'A juz read'**
  String get deedJuz;

  /// No description provided for @ramadanTrackerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to tick its fast, taraweeh and juz.'**
  String get ramadanTrackerHint;

  /// No description provided for @shareAyah.
  ///
  /// In en, this message translates to:
  /// **'Share ayah'**
  String get shareAyah;

  /// No description provided for @shareHadith.
  ///
  /// In en, this message translates to:
  /// **'Share hadith'**
  String get shareHadith;

  /// No description provided for @shareName.
  ///
  /// In en, this message translates to:
  /// **'Share name'**
  String get shareName;

  /// No description provided for @shareDua.
  ///
  /// In en, this message translates to:
  /// **'Share dua'**
  String get shareDua;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share as image'**
  String get shareImage;

  /// No description provided for @includeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Include translation'**
  String get includeTranslation;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @hadithTitle.
  ///
  /// In en, this message translates to:
  /// **'Hadith of the day'**
  String get hadithTitle;

  /// No description provided for @liveActivity.
  ///
  /// In en, this message translates to:
  /// **'Lock screen countdown'**
  String get liveActivity;

  /// No description provided for @liveActivitySub.
  ///
  /// In en, this message translates to:
  /// **'A Live Activity counting down to the next prayer'**
  String get liveActivitySub;

  /// No description provided for @liveNow.
  ///
  /// In en, this message translates to:
  /// **'It\'s time'**
  String get liveNow;

  /// No description provided for @fridayPriorities.
  ///
  /// In en, this message translates to:
  /// **'Today\'s deeds, by priority'**
  String get fridayPriorities;

  /// No description provided for @deedJumuah.
  ///
  /// In en, this message translates to:
  /// **'Pray Jumu\'ah and listen to the khutbah.'**
  String get deedJumuah;

  /// No description provided for @tagFard.
  ///
  /// In en, this message translates to:
  /// **'Obligatory'**
  String get tagFard;

  /// No description provided for @tagMuakkad.
  ///
  /// In en, this message translates to:
  /// **'Emphasized sunnah'**
  String get tagMuakkad;

  /// No description provided for @tagSunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get tagSunnah;

  /// No description provided for @kahfOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get kahfOpen;

  /// No description provided for @hifzPlayAyah.
  ///
  /// In en, this message translates to:
  /// **'Play this ayah'**
  String get hifzPlayAyah;

  /// No description provided for @hifzPageHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an ayah to reveal it · tap its number to play or mark it learnt'**
  String get hifzPageHint;

  /// No description provided for @reciteCheck.
  ///
  /// In en, this message translates to:
  /// **'Recite & check'**
  String get reciteCheck;

  /// No description provided for @reciteHint.
  ///
  /// In en, this message translates to:
  /// **'Recite the range from memory. It\'s checked on your device.'**
  String get reciteHint;

  /// No description provided for @reciteModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Download the recitation model?'**
  String get reciteModelTitle;

  /// No description provided for @reciteModelBody.
  ///
  /// In en, this message translates to:
  /// **'A {size} Quran speech model (Tarteel AI) is downloaded once. Your recordings never leave your phone.'**
  String reciteModelBody(String size);

  /// No description provided for @reciteDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get reciteDownload;

  /// No description provided for @reciteDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading model… {percent}'**
  String reciteDownloading(String percent);

  /// No description provided for @reciteListening.
  ///
  /// In en, this message translates to:
  /// **'Listening… tap to finish'**
  String get reciteListening;

  /// No description provided for @reciteChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your recitation…'**
  String get reciteChecking;

  /// No description provided for @reciteResult.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} words matched'**
  String reciteResult(String correct, String total);

  /// No description provided for @reciteMistakes.
  ///
  /// In en, this message translates to:
  /// **'{count} possible mistakes'**
  String reciteMistakes(String count);

  /// No description provided for @reciteMissed.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped'**
  String reciteMissed(String count);

  /// No description provided for @reciteLegend.
  ///
  /// In en, this message translates to:
  /// **'Green: matched · red: possible mistake · underlined: skipped. Automatic check, it can be wrong.'**
  String get reciteLegend;

  /// No description provided for @reciteHeard.
  ///
  /// In en, this message translates to:
  /// **'What was heard'**
  String get reciteHeard;

  /// No description provided for @reciteClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get reciteClear;

  /// No description provided for @reciteNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to check your recitation.'**
  String get reciteNoPermission;

  /// No description provided for @reciteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check the recitation. Try again.'**
  String get reciteFailed;

  /// No description provided for @reciteNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing was heard. Recite a little louder.'**
  String get reciteNothing;

  /// No description provided for @reciteDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection.'**
  String get reciteDownloadFailed;

  /// No description provided for @reciteRevealLive.
  ///
  /// In en, this message translates to:
  /// **'Show the words as I recite'**
  String get reciteRevealLive;

  /// No description provided for @reciteRevealLiveHint.
  ///
  /// In en, this message translates to:
  /// **'The page stays covered and each word appears once it\'s heard.'**
  String get reciteRevealLiveHint;

  /// No description provided for @reciteProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} words'**
  String reciteProgress(String done, String total);

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Your recitation'**
  String get feedbackTitle;

  /// No description provided for @gradeExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent, mashaAllah'**
  String get gradeExcellent;

  /// No description provided for @gradeVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get gradeVeryGood;

  /// No description provided for @gradeGood.
  ///
  /// In en, this message translates to:
  /// **'Good, review the marked words'**
  String get gradeGood;

  /// No description provided for @gradeReview.
  ///
  /// In en, this message translates to:
  /// **'Needs more review'**
  String get gradeReview;

  /// No description provided for @feedbackMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get feedbackMatched;

  /// No description provided for @feedbackMistakes.
  ///
  /// In en, this message translates to:
  /// **'Possible mistakes'**
  String get feedbackMistakes;

  /// No description provided for @feedbackSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get feedbackSkipped;

  /// No description provided for @feedbackReview.
  ///
  /// In en, this message translates to:
  /// **'Words to review'**
  String get feedbackReview;

  /// No description provided for @feedbackHeardAs.
  ///
  /// In en, this message translates to:
  /// **'heard: {word}'**
  String feedbackHeardAs(String word);

  /// No description provided for @feedbackSkippedWord.
  ///
  /// In en, this message translates to:
  /// **'skipped'**
  String get feedbackSkippedWord;

  /// No description provided for @feedbackPerfect.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs recited without mistakes'**
  String feedbackPerfect(String count);

  /// No description provided for @feedbackMarkLearnt.
  ///
  /// In en, this message translates to:
  /// **'Mark as learnt'**
  String get feedbackMarkLearnt;

  /// No description provided for @feedbackUnreached.
  ///
  /// In en, this message translates to:
  /// **'Stopped before the end: {count} words not recited.'**
  String feedbackUnreached(String count);

  /// No description provided for @feedbackOpen.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackOpen;

  /// No description provided for @feedbackDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get feedbackDone;

  /// No description provided for @featHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get featHadith;

  /// No description provided for @featHadithSub.
  ///
  /// In en, this message translates to:
  /// **'Nawawi\'s Forty, Qudsi, Riyad as-Salihin'**
  String get featHadithSub;

  /// No description provided for @hadithSearch.
  ///
  /// In en, this message translates to:
  /// **'Search hadith in Arabic or English'**
  String get hadithSearch;

  /// No description provided for @hadithCount.
  ///
  /// In en, this message translates to:
  /// **'{count} hadith'**
  String hadithCount(String count);

  /// No description provided for @hadithNumber.
  ///
  /// In en, this message translates to:
  /// **'Hadith {number}'**
  String hadithNumber(String number);

  /// No description provided for @hadithSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved hadith'**
  String get hadithSaved;

  /// No description provided for @hadithSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get hadithSave;

  /// No description provided for @hadithUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get hadithUnsave;

  /// No description provided for @hadithNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No hadith matches “{query}”'**
  String hadithNoMatch(String query);

  /// No description provided for @hadithChapters.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get hadithChapters;

  /// No description provided for @hadithSource.
  ///
  /// In en, this message translates to:
  /// **'Arabic text and English translation from Sunnah.com, via the open hadith-json project.'**
  String get hadithSource;

  /// No description provided for @wirdReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Quran wird'**
  String get wirdReminder;

  /// No description provided for @wirdReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily wird'**
  String get wirdReminderTitle;

  /// No description provided for @wirdReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Read today\'s portion of the Quran and keep your streak.'**
  String get wirdReminderBody;

  /// No description provided for @wirdPortion.
  ///
  /// In en, this message translates to:
  /// **'Today: pages {first}–{last}'**
  String wirdPortion(String first, String last);

  /// No description provided for @wirdPortionOne.
  ///
  /// In en, this message translates to:
  /// **'Today: page {page}'**
  String wirdPortionOne(String page);

  /// No description provided for @wirdMarkDone.
  ///
  /// In en, this message translates to:
  /// **'I read today\'s portion'**
  String get wirdMarkDone;

  /// No description provided for @sadaqahReminder.
  ///
  /// In en, this message translates to:
  /// **'Friday sadaqah reminder'**
  String get sadaqahReminder;

  /// No description provided for @sadaqahReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Sadaqah'**
  String get sadaqahReminderTitle;

  /// No description provided for @sadaqahReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Charity does not decrease wealth. Give something today, even a little.'**
  String get sadaqahReminderBody;

  /// No description provided for @sadaqahRemindAt.
  ///
  /// In en, this message translates to:
  /// **'Fridays at {time}'**
  String sadaqahRemindAt(String time);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @featSadaqah.
  ///
  /// In en, this message translates to:
  /// **'Sadaqah'**
  String get featSadaqah;

  /// No description provided for @featSadaqahSub.
  ///
  /// In en, this message translates to:
  /// **'Private log, monthly goal, Friday reminder'**
  String get featSadaqahSub;

  /// No description provided for @sadaqahAdd.
  ///
  /// In en, this message translates to:
  /// **'Log sadaqah'**
  String get sadaqahAdd;

  /// No description provided for @sadaqahMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get sadaqahMoney;

  /// No description provided for @sadaqahFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get sadaqahFood;

  /// No description provided for @sadaqahHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get sadaqahHelp;

  /// No description provided for @sadaqahOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sadaqahOther;

  /// No description provided for @sadaqahAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (optional)'**
  String get sadaqahAmount;

  /// No description provided for @sadaqahNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get sadaqahNote;

  /// No description provided for @sadaqahPrivate.
  ///
  /// In en, this message translates to:
  /// **'Stays on your phone only.'**
  String get sadaqahPrivate;

  /// No description provided for @sadaqahCount.
  ///
  /// In en, this message translates to:
  /// **'{count} this month'**
  String sadaqahCount(String count);

  /// No description provided for @sadaqahSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly goal'**
  String get sadaqahSetGoal;

  /// No description provided for @sadaqahGoalOf.
  ///
  /// In en, this message translates to:
  /// **'Goal: {amount} {currency}'**
  String sadaqahGoalOf(String amount, String currency);

  /// No description provided for @sadaqahGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly goal'**
  String get sadaqahGoalTitle;

  /// No description provided for @sadaqahNoGoal.
  ///
  /// In en, this message translates to:
  /// **'No goal'**
  String get sadaqahNoGoal;

  /// No description provided for @sadaqahStreak.
  ///
  /// In en, this message translates to:
  /// **'Weeks in a row'**
  String get sadaqahStreak;

  /// No description provided for @sadaqahWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks'**
  String sadaqahWeeks(String count);

  /// No description provided for @sadaqahHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get sadaqahHistory;

  /// No description provided for @sadaqahEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Even a smile is charity.'**
  String get sadaqahEmpty;

  /// No description provided for @sadaqahHadith.
  ///
  /// In en, this message translates to:
  /// **'“Charity does not decrease wealth.” — Sahih Muslim'**
  String get sadaqahHadith;

  /// No description provided for @featQada.
  ///
  /// In en, this message translates to:
  /// **'Missed fasts'**
  String get featQada;

  /// No description provided for @featQadaSub.
  ///
  /// In en, this message translates to:
  /// **'Qada, fidyah and kaffarah tracker'**
  String get featQadaSub;

  /// No description provided for @qadaRemaining.
  ///
  /// In en, this message translates to:
  /// **'Fasts left to make up'**
  String get qadaRemaining;

  /// No description provided for @qadaMadeOf.
  ///
  /// In en, this message translates to:
  /// **'{made} of {owed} made up'**
  String qadaMadeOf(String made, String owed);

  /// No description provided for @qadaLess.
  ///
  /// In en, this message translates to:
  /// **'One less'**
  String get qadaLess;

  /// No description provided for @qadaMore.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get qadaMore;

  /// No description provided for @qadaMarkToday.
  ///
  /// In en, this message translates to:
  /// **'I\'m fasting today'**
  String get qadaMarkToday;

  /// No description provided for @qadaFastedToday.
  ///
  /// In en, this message translates to:
  /// **'Fasting today'**
  String get qadaFastedToday;

  /// No description provided for @qadaAllDone.
  ///
  /// In en, this message translates to:
  /// **'All made up. May Allah accept it.'**
  String get qadaAllDone;

  /// No description provided for @qadaTip.
  ///
  /// In en, this message translates to:
  /// **'Mondays, Thursdays and the white days (13–15) are good days to make up fasts.'**
  String get qadaTip;

  /// No description provided for @qadaIntro.
  ///
  /// In en, this message translates to:
  /// **'Missed days of Ramadan for illness, travel, pregnancy or menstruation? Add them with + and tick each day you make one up.'**
  String get qadaIntro;

  /// No description provided for @qadaFromRamadan.
  ///
  /// In en, this message translates to:
  /// **'Your Ramadan {year} tracker has {count} days not marked as fasted.'**
  String qadaFromRamadan(String year, String count);

  /// No description provided for @qadaFidyah.
  ///
  /// In en, this message translates to:
  /// **'Fidyah'**
  String get qadaFidyah;

  /// No description provided for @qadaFidyahInfo.
  ///
  /// In en, this message translates to:
  /// **'For anyone who can never fast, like the very old or chronically ill: feed one poor person for each day missed.'**
  String get qadaFidyahInfo;

  /// No description provided for @qadaFidyahMeals.
  ///
  /// In en, this message translates to:
  /// **'{count} meals'**
  String qadaFidyahMeals(String count);

  /// No description provided for @qadaFidyahTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} meals ≈ {total}'**
  String qadaFidyahTotal(String count, String total);

  /// No description provided for @qadaMealCost.
  ///
  /// In en, this message translates to:
  /// **'Cost of one meal'**
  String get qadaMealCost;

  /// No description provided for @qadaKaffarah.
  ///
  /// In en, this message translates to:
  /// **'Kaffarah'**
  String get qadaKaffarah;

  /// No description provided for @qadaKaffarahInfo.
  ///
  /// In en, this message translates to:
  /// **'Breaking a Ramadan fast by intercourse needs kaffarah: fasting 60 days in a row, or feeding 60 poor people if unable.'**
  String get qadaKaffarahInfo;

  /// No description provided for @qadaKaffarahStart.
  ///
  /// In en, this message translates to:
  /// **'Start 60 days'**
  String get qadaKaffarahStart;

  /// No description provided for @qadaKaffarahProgress.
  ///
  /// In en, this message translates to:
  /// **'{days} of {total} days in a row'**
  String qadaKaffarahProgress(String days, String total);

  /// No description provided for @qadaKaffarahBroken.
  ///
  /// In en, this message translates to:
  /// **'A day was missed, so the count must start again (unless the break was for illness or menstruation).'**
  String get qadaKaffarahBroken;

  /// No description provided for @qadaKaffarahRestart.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get qadaKaffarahRestart;

  /// No description provided for @qadaKaffarahDone.
  ///
  /// In en, this message translates to:
  /// **'Kaffarah complete. May Allah accept it.'**
  String get qadaKaffarahDone;

  /// No description provided for @qadaDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Rulings differ between scholars; ask a scholar about your own case.'**
  String get qadaDisclaimer;

  /// No description provided for @featSleep.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get featSleep;

  /// No description provided for @featSleepSub.
  ///
  /// In en, this message translates to:
  /// **'Sleep adhkar, al-Mulk and a sleep timer'**
  String get featSleepSub;

  /// No description provided for @sleepIntro.
  ///
  /// In en, this message translates to:
  /// **'End your day with remembrance. Recitations fade out gently when the timer ends.'**
  String get sleepIntro;

  /// No description provided for @sleepAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Adhkar before sleeping'**
  String get sleepAdhkar;

  /// No description provided for @sleepAdhkarSub.
  ///
  /// In en, this message translates to:
  /// **'{count} adhkar from Hisn al-Muslim'**
  String sleepAdhkarSub(String count);

  /// No description provided for @sleepRecite.
  ///
  /// In en, this message translates to:
  /// **'Recite before sleeping'**
  String get sleepRecite;

  /// No description provided for @sleepListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get sleepListen;

  /// No description provided for @sleepMulk.
  ///
  /// In en, this message translates to:
  /// **'Surah al-Mulk'**
  String get sleepMulk;

  /// No description provided for @sleepMulkWhy.
  ///
  /// In en, this message translates to:
  /// **'It intercedes for its reader until he is forgiven. — Tirmidhi'**
  String get sleepMulkWhy;

  /// No description provided for @sleepSajdah.
  ///
  /// In en, this message translates to:
  /// **'Surah as-Sajdah'**
  String get sleepSajdah;

  /// No description provided for @sleepSajdahWhy.
  ///
  /// In en, this message translates to:
  /// **'The Prophet ﷺ would not sleep until he recited as-Sajdah and al-Mulk. — Tirmidhi'**
  String get sleepSajdahWhy;

  /// No description provided for @sleepKursi.
  ///
  /// In en, this message translates to:
  /// **'Ayat al-Kursi'**
  String get sleepKursi;

  /// No description provided for @sleepKursiWhy.
  ///
  /// In en, this message translates to:
  /// **'A guardian from Allah stays with you until morning. — Bukhari'**
  String get sleepKursiWhy;

  /// No description provided for @sleepBaqarah.
  ///
  /// In en, this message translates to:
  /// **'Last two ayahs of al-Baqarah'**
  String get sleepBaqarah;

  /// No description provided for @sleepBaqarahWhy.
  ///
  /// In en, this message translates to:
  /// **'Whoever recites them at night, they suffice him. — Bukhari, Muslim'**
  String get sleepBaqarahWhy;

  /// No description provided for @sleepQuls.
  ///
  /// In en, this message translates to:
  /// **'Al-Ikhlas, al-Falaq, an-Nas'**
  String get sleepQuls;

  /// No description provided for @sleepQulsWhy.
  ///
  /// In en, this message translates to:
  /// **'Blow into your palms, recite them and wipe over your body, three times. — Bukhari'**
  String get sleepQulsWhy;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @sleepMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sleepMinutes(String minutes);

  /// No description provided for @sleepEndOfSurah.
  ///
  /// In en, this message translates to:
  /// **'End of surah'**
  String get sleepEndOfSurah;

  /// No description provided for @sleepOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepOff;

  /// No description provided for @sleepTimerHint.
  ///
  /// In en, this message translates to:
  /// **'Also in the player: tap the moon icon.'**
  String get sleepTimerHint;

  /// No description provided for @featTravel.
  ///
  /// In en, this message translates to:
  /// **'Traveller'**
  String get featTravel;

  /// No description provided for @featTravelSub.
  ///
  /// In en, this message translates to:
  /// **'Shortening and combining prayers on a journey'**
  String get featTravelSub;

  /// No description provided for @travelOn.
  ///
  /// In en, this message translates to:
  /// **'You\'re travelling'**
  String get travelOn;

  /// No description provided for @travelOff.
  ///
  /// In en, this message translates to:
  /// **'You\'re at home'**
  String get travelOff;

  /// No description provided for @travelFromHome.
  ///
  /// In en, this message translates to:
  /// **'{km} km from home'**
  String travelFromHome(String km);

  /// No description provided for @travelDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of your trip'**
  String travelDay(String day);

  /// No description provided for @travelAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get travelAuto;

  /// No description provided for @travelModeOn.
  ///
  /// In en, this message translates to:
  /// **'Travelling'**
  String get travelModeOn;

  /// No description provided for @travelModeOff.
  ///
  /// In en, this message translates to:
  /// **'At home'**
  String get travelModeOff;

  /// No description provided for @travelAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Auto turns on when your prayer location is over 80 km from home.'**
  String get travelAutoHint;

  /// No description provided for @travelSetHome.
  ///
  /// In en, this message translates to:
  /// **'Make this home'**
  String get travelSetHome;

  /// No description provided for @travelToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayers'**
  String get travelToday;

  /// No description provided for @travelRakahs.
  ///
  /// In en, this message translates to:
  /// **'{count} rak\'ahs'**
  String travelRakahs(String count);

  /// No description provided for @travelCombine.
  ///
  /// In en, this message translates to:
  /// **'Combining (jam\')'**
  String get travelCombine;

  /// No description provided for @travelCombineDay.
  ///
  /// In en, this message translates to:
  /// **'{first} + {second}: in either one\'s time, from {from} until {to}.'**
  String travelCombineDay(String first, String second, String from, String to);

  /// No description provided for @travelCombineNight.
  ///
  /// In en, this message translates to:
  /// **'{first} + {second}: in either one\'s time, from {from} until {to}.'**
  String travelCombineNight(
    String first,
    String second,
    String from,
    String to,
  );

  /// No description provided for @travelCombineHint.
  ///
  /// In en, this message translates to:
  /// **'Fajr is never combined, and Maghrib stays 3 rak\'ahs.'**
  String get travelCombineHint;

  /// No description provided for @travelRules.
  ///
  /// In en, this message translates to:
  /// **'Key rulings'**
  String get travelRules;

  /// No description provided for @travelRuleDistance.
  ///
  /// In en, this message translates to:
  /// **'A journey of about 80 km (48 miles) or more allows shortening, once you leave your town\'s buildings.'**
  String get travelRuleDistance;

  /// No description provided for @travelRuleQasr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr, Asr and Isha are prayed as 2 rak\'ahs instead of 4.'**
  String get travelRuleQasr;

  /// No description provided for @travelRuleJam.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr with Asr, and Maghrib with Isha, may be joined in the time of either.'**
  String get travelRuleJam;

  /// No description provided for @travelRuleStay.
  ///
  /// In en, this message translates to:
  /// **'Intending to stay more than 4 days makes you a resident for most scholars (15 days for the Hanafi school).'**
  String get travelRuleStay;

  /// No description provided for @travelRuleSunnah.
  ///
  /// In en, this message translates to:
  /// **'The regular sunnahs may be left, except the sunnah of Fajr and witr.'**
  String get travelRuleSunnah;

  /// No description provided for @travelRuleImam.
  ///
  /// In en, this message translates to:
  /// **'Praying behind a resident imam, pray the full 4 with him.'**
  String get travelRuleImam;

  /// No description provided for @travelRuleFast.
  ///
  /// In en, this message translates to:
  /// **'You may break the Ramadan fast on a journey and make it up later.'**
  String get travelRuleFast;

  /// No description provided for @travelDuas.
  ///
  /// In en, this message translates to:
  /// **'Duas for the journey'**
  String get travelDuas;

  /// No description provided for @travelDuaSetOff.
  ///
  /// In en, this message translates to:
  /// **'Setting off'**
  String get travelDuaSetOff;

  /// No description provided for @travelDuaSetOffMeaning.
  ///
  /// In en, this message translates to:
  /// **'Allah is the Greatest (×3). Glory to Him who has subjected this to us, and we could not have done it ourselves, and to our Lord we will surely return. O Allah, we ask You on this journey for goodness, piety and deeds that please You. O Allah, make this journey easy and shorten its distance for us. O Allah, You are the Companion on the journey and the Guardian of the family. — Muslim'**
  String get travelDuaSetOffMeaning;

  /// No description provided for @travelDuaTown.
  ///
  /// In en, this message translates to:
  /// **'Entering a town'**
  String get travelDuaTown;

  /// No description provided for @travelDuaTownMeaning.
  ///
  /// In en, this message translates to:
  /// **'O Allah, Lord of the seven heavens and all they shade, Lord of the seven earths and all they carry, I ask You for the good of this town and the good of its people, and seek refuge in You from its evil and the evil of its people. — Nasa\'i'**
  String get travelDuaTownMeaning;

  /// No description provided for @travelDuaStop.
  ///
  /// In en, this message translates to:
  /// **'Stopping somewhere'**
  String get travelDuaStop;

  /// No description provided for @travelDuaStopMeaning.
  ///
  /// In en, this message translates to:
  /// **'I seek refuge in the perfect words of Allah from the evil of what He has created. Nothing will harm you until you leave that place. — Muslim'**
  String get travelDuaStopMeaning;

  /// No description provided for @travelBanner.
  ///
  /// In en, this message translates to:
  /// **'You seem to be travelling ({km} km from home). See how to shorten and combine prayers.'**
  String travelBanner(String km);

  /// No description provided for @featLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn to pray'**
  String get featLearn;

  /// No description provided for @featLearnSub.
  ///
  /// In en, this message translates to:
  /// **'Wudu and salah, step by step'**
  String get featLearnSub;

  /// No description provided for @lessonSteps.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String lessonSteps(String count);

  /// No description provided for @lessonQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String lessonQuestions(String count);

  /// No description provided for @lessonStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {number} of {total}'**
  String lessonStepOf(String number, String total);

  /// No description provided for @lessonQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String lessonQuestionOf(String number, String total);

  /// No description provided for @lessonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get lessonBack;

  /// No description provided for @lessonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get lessonNext;

  /// No description provided for @lessonStartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get lessonStartQuiz;

  /// No description provided for @lessonRight.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get lessonRight;

  /// No description provided for @lessonWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite.'**
  String get lessonWrong;

  /// No description provided for @lessonDone.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete'**
  String get lessonDone;

  /// No description provided for @lessonScore.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String lessonScore(String correct, String total);

  /// No description provided for @lessonRetryQuiz.
  ///
  /// In en, this message translates to:
  /// **'Try the quiz again'**
  String get lessonRetryQuiz;

  /// No description provided for @featTajweed.
  ///
  /// In en, this message translates to:
  /// **'Tajweed'**
  String get featTajweed;

  /// No description provided for @featTajweedSub.
  ///
  /// In en, this message translates to:
  /// **'Rules with examples and quizzes'**
  String get featTajweedSub;

  /// No description provided for @featKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get featKids;

  /// No description provided for @featKidsSub.
  ///
  /// In en, this message translates to:
  /// **'Letters, short surahs and duas, with stars'**
  String get featKidsSub;

  /// No description provided for @kidsStars.
  ///
  /// In en, this message translates to:
  /// **'{count} stars'**
  String kidsStars(String count);

  /// No description provided for @kidsStarsHint.
  ///
  /// In en, this message translates to:
  /// **'Finish lessons and learn surahs to earn more.'**
  String get kidsStarsHint;

  /// No description provided for @kidsLetters.
  ///
  /// In en, this message translates to:
  /// **'Arabic letters'**
  String get kidsLetters;

  /// No description provided for @kidsLettersSub.
  ///
  /// In en, this message translates to:
  /// **'Tap a letter to see its name and a word.'**
  String get kidsLettersSub;

  /// No description provided for @kidsSurahs.
  ///
  /// In en, this message translates to:
  /// **'Short surahs'**
  String get kidsSurahs;

  /// No description provided for @kidsListen.
  ///
  /// In en, this message translates to:
  /// **'Listen and repeat'**
  String get kidsListen;

  /// No description provided for @kidsAyahs.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs'**
  String kidsAyahs(String count);

  /// No description provided for @kidsLearnt.
  ///
  /// In en, this message translates to:
  /// **'I learnt it'**
  String get kidsLearnt;

  /// No description provided for @kidsDuas.
  ///
  /// In en, this message translates to:
  /// **'Duas and prayer'**
  String get kidsDuas;

  /// No description provided for @widgetHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get widgetHadith;

  /// No description provided for @widgetHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri date'**
  String get widgetHijri;

  /// No description provided for @widgetSubhanallah.
  ///
  /// In en, this message translates to:
  /// **'SubhanAllah'**
  String get widgetSubhanallah;

  /// No description provided for @widgetAlhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get widgetAlhamdulillah;

  /// No description provided for @widgetAllahuAkbar.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get widgetAllahuAkbar;

  /// No description provided for @widgetReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get widgetReset;

  /// No description provided for @widgetEventIn.
  ///
  /// In en, this message translates to:
  /// **'{event} in {days} days'**
  String widgetEventIn(String event, String days);

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @azkarSleepSub.
  ///
  /// In en, this message translates to:
  /// **'Recite them as you lie down to sleep'**
  String get azkarSleepSub;

  /// No description provided for @compassHold.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone flat and turn until the Kaaba points up'**
  String get compassHold;

  /// No description provided for @compassCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Low accuracy — move your phone in a figure 8 and keep it away from metal'**
  String get compassCalibrate;

  /// No description provided for @qiblaAr.
  ///
  /// In en, this message translates to:
  /// **'AR Qibla'**
  String get qiblaAr;

  /// No description provided for @qiblaArHint.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone upright and turn until the prayer mat faces the Kaaba'**
  String get qiblaArHint;

  /// No description provided for @qiblaArNoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Allow camera access to see the Qibla around you.'**
  String get qiblaArNoCamera;

  /// No description provided for @kaaba.
  ///
  /// In en, this message translates to:
  /// **'Kaaba'**
  String get kaaba;

  /// No description provided for @qiblaArPray.
  ///
  /// In en, this message translates to:
  /// **'You can start your prayer'**
  String get qiblaArPray;

  /// No description provided for @featHajj.
  ///
  /// In en, this message translates to:
  /// **'Hajj & Umrah'**
  String get featHajj;

  /// No description provided for @featHajjSub.
  ///
  /// In en, this message translates to:
  /// **'Rites step by step, with pictures'**
  String get featHajjSub;

  /// No description provided for @salawatReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Friday · Salawat'**
  String get salawatReminderTitle;

  /// No description provided for @salawatReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Send salawat on the Prophet ﷺ today.\n\nاللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ'**
  String get salawatReminderBody;

  /// No description provided for @salawatReminder.
  ///
  /// In en, this message translates to:
  /// **'Salawat on Friday'**
  String get salawatReminder;

  /// No description provided for @salawatReminderSub.
  ///
  /// In en, this message translates to:
  /// **'Friday at 11:00 AM'**
  String get salawatReminderSub;

  /// No description provided for @featTawashih.
  ///
  /// In en, this message translates to:
  /// **'Tawashih'**
  String get featTawashih;

  /// No description provided for @featTawashihSub.
  ///
  /// In en, this message translates to:
  /// **'Munshids and prophetic praise'**
  String get featTawashihSub;

  /// No description provided for @featRadio.
  ///
  /// In en, this message translates to:
  /// **'Quran Radio'**
  String get featRadio;

  /// No description provided for @featRadioSub.
  ///
  /// In en, this message translates to:
  /// **'Live recitation from Cairo'**
  String get featRadioSub;

  /// No description provided for @radioLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get radioLive;

  /// No description provided for @radioCity.
  ///
  /// In en, this message translates to:
  /// **'Cairo'**
  String get radioCity;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNew;

  /// No description provided for @tawashihIntro.
  ///
  /// In en, this message translates to:
  /// **'Prophetic praise by classic munshids. Pick a voice, then a track.'**
  String get tawashihIntro;

  /// No description provided for @rawatibTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunnah rawatib'**
  String get rawatibTitle;

  /// No description provided for @rawatibBefore.
  ///
  /// In en, this message translates to:
  /// **'{n} rak\'ahs before'**
  String rawatibBefore(String n);

  /// No description provided for @rawatibAfter.
  ///
  /// In en, this message translates to:
  /// **'{n} rak\'ahs after'**
  String rawatibAfter(String n);

  /// No description provided for @rawatibNone.
  ///
  /// In en, this message translates to:
  /// **'No confirmed rawatib for this prayer.'**
  String get rawatibNone;

  /// No description provided for @rawatibHint.
  ///
  /// In en, this message translates to:
  /// **'After the fard, pray the sunnah rawatib.'**
  String get rawatibHint;

  /// No description provided for @tahajjudReminder.
  ///
  /// In en, this message translates to:
  /// **'Tahajjud'**
  String get tahajjudReminder;

  /// No description provided for @tahajjudReminderSub.
  ///
  /// In en, this message translates to:
  /// **'Start of the last third of the night'**
  String get tahajjudReminderSub;

  /// No description provided for @tahajjudTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for tahajjud'**
  String get tahajjudTitle;

  /// No description provided for @tahajjudBody.
  ///
  /// In en, this message translates to:
  /// **'The last third of the night has begun — a blessed time to stand in prayer.'**
  String get tahajjudBody;

  /// No description provided for @duhaReminder.
  ///
  /// In en, this message translates to:
  /// **'Duha'**
  String get duhaReminder;

  /// No description provided for @duhaReminderSub.
  ///
  /// In en, this message translates to:
  /// **'About 20 minutes after sunrise'**
  String get duhaReminderSub;

  /// No description provided for @duhaTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for Duha'**
  String get duhaTitle;

  /// No description provided for @duhaBody.
  ///
  /// In en, this message translates to:
  /// **'Sunrise has passed — pray Duha before Dhuhr.'**
  String get duhaBody;

  /// No description provided for @iqamaTitle.
  ///
  /// In en, this message translates to:
  /// **'Iqama countdown'**
  String get iqamaTitle;

  /// No description provided for @iqamaIntro.
  ///
  /// In en, this message translates to:
  /// **'Set how long until iqama. When it ends, the family stands for prayer together.'**
  String get iqamaIntro;

  /// No description provided for @iqamaMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String iqamaMinutes(String n);

  /// No description provided for @iqamaStart.
  ///
  /// In en, this message translates to:
  /// **'Start countdown'**
  String get iqamaStart;

  /// No description provided for @iqamaCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get iqamaCancel;

  /// No description provided for @iqamaUntil.
  ///
  /// In en, this message translates to:
  /// **'until iqama'**
  String get iqamaUntil;

  /// No description provided for @iqamaStanding.
  ///
  /// In en, this message translates to:
  /// **'Stand for prayer'**
  String get iqamaStanding;

  /// No description provided for @iqamaAgain.
  ///
  /// In en, this message translates to:
  /// **'Set again'**
  String get iqamaAgain;

  /// No description provided for @iqamaOpen.
  ///
  /// In en, this message translates to:
  /// **'Iqama for the family'**
  String get iqamaOpen;

  /// No description provided for @comfortReading.
  ///
  /// In en, this message translates to:
  /// **'Comfortable reading'**
  String get comfortReading;

  /// No description provided for @comfortReadingSub.
  ///
  /// In en, this message translates to:
  /// **'Large Arabic text for easy reading'**
  String get comfortReadingSub;

  /// No description provided for @trackCount.
  ///
  /// In en, this message translates to:
  /// **'{n} tracks'**
  String trackCount(String n);

  /// No description provided for @allMunshids.
  ///
  /// In en, this message translates to:
  /// **'All munshids'**
  String get allMunshids;

  /// No description provided for @popularMunshids.
  ///
  /// In en, this message translates to:
  /// **'Popular munshids'**
  String get popularMunshids;

  /// No description provided for @prayerIn.
  ///
  /// In en, this message translates to:
  /// **'{name} in'**
  String prayerIn(String name);

  /// No description provided for @midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnight;

  /// No description provided for @lastThird.
  ///
  /// In en, this message translates to:
  /// **'Last third'**
  String get lastThird;

  /// No description provided for @sleepAzkarReminder.
  ///
  /// In en, this message translates to:
  /// **'Sleep adhkar'**
  String get sleepAzkarReminder;

  /// No description provided for @sleepAzkarReminderSub.
  ///
  /// In en, this message translates to:
  /// **'About 45 minutes after Isha'**
  String get sleepAzkarReminderSub;

  /// No description provided for @sleepAzkarTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for sleep adhkar'**
  String get sleepAzkarTitle;

  /// No description provided for @sleepAzkarBody.
  ///
  /// In en, this message translates to:
  /// **'End your day with remembrance before you sleep.'**
  String get sleepAzkarBody;

  /// No description provided for @featBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get featBooks;

  /// No description provided for @featBooksSub.
  ///
  /// In en, this message translates to:
  /// **'Free Arabic Islamic library'**
  String get featBooksSub;

  /// No description provided for @booksIntro.
  ///
  /// In en, this message translates to:
  /// **'Classic Arabic Islamic books — read free inside the app.'**
  String get booksIntro;

  /// No description provided for @booksFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get booksFree;

  /// No description provided for @booksOpenFail.
  ///
  /// In en, this message translates to:
  /// **'Could not load the book.'**
  String get booksOpenFail;

  /// No description provided for @booksOpenExternal.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get booksOpenExternal;

  /// No description provided for @booksSource.
  ///
  /// In en, this message translates to:
  /// **'Source: IslamHouse — free for personal use.'**
  String get booksSource;

  /// No description provided for @booksCatAqidah.
  ///
  /// In en, this message translates to:
  /// **'Aqidah'**
  String get booksCatAqidah;

  /// No description provided for @booksCatTafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get booksCatTafsir;

  /// No description provided for @booksCatHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get booksCatHadith;

  /// No description provided for @booksCatSeerah.
  ///
  /// In en, this message translates to:
  /// **'Seerah'**
  String get booksCatSeerah;

  /// No description provided for @booksCatAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Adhkar'**
  String get booksCatAdhkar;

  /// No description provided for @booksCatFiqh.
  ///
  /// In en, this message translates to:
  /// **'Fiqh'**
  String get booksCatFiqh;
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
