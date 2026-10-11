// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class L10nAr extends L10n {
  L10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مسلم';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPrayer => 'الصلاة';

  @override
  String get navQibla => 'القبلة';

  @override
  String get navTasbih => 'التسبيح';

  @override
  String get navMore => 'المزيد';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get errMissingKey =>
      'مفتاح الخدمة غير موجود. شغّل التطبيق باستخدام ‎--dart-define-from-file=env.json';

  @override
  String get errNetwork => 'تعذّر الاتصال بالخادم. تحقّق من اتصالك بالإنترنت.';

  @override
  String get errGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get refreshFailed => 'تعذّر التحديث';

  @override
  String get copied => 'تم النسخ';

  @override
  String get copy => 'نسخ';

  @override
  String get listen => 'استماع';

  @override
  String get stop => 'إيقاف';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String noMatch(String query) {
    return 'لا توجد نتائج لـ «$query».';
  }

  @override
  String get am => 'ص';

  @override
  String get pm => 'م';

  @override
  String hoursMinutes(String h, String m) {
    return '$h س $m د';
  }

  @override
  String minutesOnly(String m) {
    return '$m د';
  }

  @override
  String get hijriSuffix => 'هـ';

  @override
  String get fajr => 'الفجر';

  @override
  String get sunrise => 'الشروق';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get jumuah => 'الجمعة';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get greeting => 'السلام عليكم';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String inDuration(String d) {
    return 'بعد $d';
  }

  @override
  String get explore => 'استكشف';

  @override
  String get todayPrayers => 'صلوات اليوم';

  @override
  String prayedCount(String n) {
    return 'صلّيت $n من ٥';
  }

  @override
  String get verseTitle => 'آية اليوم';

  @override
  String get verseTranslation => '';

  @override
  String get verseRef => 'سورة الشرح · ٥–٦';

  @override
  String get nameOfDay => 'اسم للتأمل';

  @override
  String get allNames => 'الأسماء الحسنى كاملة';

  @override
  String get duaOfDay => 'دعاء اليوم';

  @override
  String get allDuas => 'أدعية لكل مناسبة';

  @override
  String get featPrayer => 'مواقيت الصلاة';

  @override
  String get featPrayerSub => 'المواقيت والمتابعة والصيام';

  @override
  String get featQuran => 'القرآن';

  @override
  String get featQuranSub => 'فهرس السور المئة والأربع عشرة';

  @override
  String get featQibla => 'القبلة';

  @override
  String get featQiblaSub => 'اتجاه الكعبة المشرفة';

  @override
  String get featTasbih => 'المسبحة';

  @override
  String get featTasbihSub => 'أذكار ما بعد الصلاة';

  @override
  String get featDuas => 'الأدعية';

  @override
  String get featDuasSub => 'لكل مناسبة';

  @override
  String get featNames => 'الأسماء الحسنى';

  @override
  String get featNamesSub => 'المعاني والتلاوة';

  @override
  String get featZakat => 'الزكاة';

  @override
  String get featZakatSub => 'حاسبة بنصاب اليوم';

  @override
  String get featRuqyah => 'الرقية';

  @override
  String get featRuqyahSub => 'التحصين والشفاء';

  @override
  String get featFasting => 'الصيام';

  @override
  String get featFastingSub => 'السحور والإفطار والأيام البيض';

  @override
  String get prayerTitle => 'مواقيت الصلاة';

  @override
  String get changeCity => 'تغيير المدينة';

  @override
  String get trackerHint => 'اضغط على الدائرة بعد أداء الصلاة.';

  @override
  String get nextBadge => 'التالية';

  @override
  String get allPrayed => 'أدّيت الصلوات الخمس اليوم. تقبّل الله منك.';

  @override
  String get fastingTitle => 'الصيام';

  @override
  String get sahurEnds => 'نهاية السحور';

  @override
  String get iftar => 'الإفطار';

  @override
  String fastLength(String d) {
    return '$d من الفجر إلى المغرب';
  }

  @override
  String get sunnahMonday => 'غدًا الاثنين — يُسنّ صيامه.';

  @override
  String get sunnahThursday => 'غدًا الخميس — يُسنّ صيامه.';

  @override
  String get whiteDays => 'الأيام البيض';

  @override
  String get whiteDaysHint =>
      'الثالث عشر والرابع عشر والخامس عشر من كل شهر هجري.';

  @override
  String get approx => 'تقريبًا';

  @override
  String get qiblaTitle => 'القبلة';

  @override
  String get kmToKaaba => 'كم إلى الكعبة';

  @override
  String get facingQibla => 'أنت تتجه إلى القبلة';

  @override
  String turnRight(String deg) {
    return 'استدر يمينًا $deg°';
  }

  @override
  String turnLeft(String deg) {
    return 'استدر يسارًا $deg°';
  }

  @override
  String get dragHint => 'اسحب البوصلة لضبط الاتجاه';

  @override
  String get compassN => 'ش';

  @override
  String get compassE => 'ق';

  @override
  String get compassS => 'ج';

  @override
  String get compassW => 'غ';

  @override
  String get dirN => 'الشمال';

  @override
  String get dirNE => 'الشمال الشرقي';

  @override
  String get dirE => 'الشرق';

  @override
  String get dirSE => 'الجنوب الشرقي';

  @override
  String get dirS => 'الجنوب';

  @override
  String get dirSW => 'الجنوب الغربي';

  @override
  String get dirW => 'الغرب';

  @override
  String get dirNW => 'الشمال الغربي';

  @override
  String get tasbihTitle => 'التسبيح';

  @override
  String get reset => 'إعادة';

  @override
  String afterSalah(String i, String n) {
    return 'أذكار بعد الصلاة · $i من $n';
  }

  @override
  String get tapToCount => 'اضغط في أي مكان للعدّ';

  @override
  String todayTotal(String n) {
    return '$n اليوم';
  }

  @override
  String get setComplete => 'اكتملت الأذكار — تقبّل الله منك.';

  @override
  String get zakatTitle => 'الزكاة';

  @override
  String get currency => 'العملة';

  @override
  String get standardClassical => 'فقهي';

  @override
  String get standardCommon => 'شائع';

  @override
  String get nisabToday => 'نصاب اليوم — اختر ما تحسب على أساسه';

  @override
  String get gold => 'الذهب';

  @override
  String get silver => 'الفضة';

  @override
  String get goldLower => 'الذهب';

  @override
  String get silverLower => 'الفضة';

  @override
  String gramsTimes(String g, String price) {
    return '$g غ × $price';
  }

  @override
  String priceAsOf(String date) {
    return 'سعر السوق في $date';
  }

  @override
  String get whatYouOwn => 'ما تملكه';

  @override
  String get whatYouOwe => 'ما عليك';

  @override
  String get clear => 'مسح';

  @override
  String get fieldCash => 'النقد والحسابات البنكية';

  @override
  String get fieldGold => 'الذهب';

  @override
  String get fieldSilver => 'الفضة';

  @override
  String get fieldInvestments => 'الأسهم والاستثمارات';

  @override
  String get fieldReceivables => 'ديون لك عند الآخرين';

  @override
  String get fieldDebts => 'ديون مستحقة عليك الآن';

  @override
  String get gramsUnit => 'غ';

  @override
  String get zakatDue => 'الزكاة المستحقة';

  @override
  String get waitingNisab => 'جارٍ جلب نصاب اليوم…';

  @override
  String get addWhatYouOwn => 'أدخل ما تملكه';

  @override
  String get privacyNote => 'لا يغادر أي رقم تدخله هاتفك.';

  @override
  String get noZakat => 'لا زكاة عليك';

  @override
  String belowNisab(String net, String metal, String threshold) {
    return 'صافي مالك $net، وهو أقل من نصاب $metal البالغ $threshold.';
  }

  @override
  String aboveNisab(String net, String metal, String threshold) {
    return '٢٫٥٪ من $net — فوق نصاب $metal البالغ $threshold.';
  }

  @override
  String get zakatFootnote =>
      'تجب الزكاة إذا حال الحول الهجري الكامل والمال فوق النصاب. يُقوَّم الذهب والفضة بسعر الخالص (عيار ٢٤). وفي عروض التجارة والعقارات والحالات المركّبة استشر عالمًا تثق به.';

  @override
  String get curEGP => 'جنيه مصري';

  @override
  String get curSAR => 'ريال سعودي';

  @override
  String get curAED => 'درهم إماراتي';

  @override
  String get curKWD => 'دينار كويتي';

  @override
  String get curQAR => 'ريال قطري';

  @override
  String get curJOD => 'دينار أردني';

  @override
  String get curMAD => 'درهم مغربي';

  @override
  String get curTRY => 'ليرة تركية';

  @override
  String get curPKR => 'روبية باكستانية';

  @override
  String get curINR => 'روبية هندية';

  @override
  String get curBDT => 'تاكا بنغلاديشية';

  @override
  String get curIDR => 'روبية إندونيسية';

  @override
  String get curMYR => 'رينغيت ماليزي';

  @override
  String get curUSD => 'دولار أمريكي';

  @override
  String get curEUR => 'يورو';

  @override
  String get curGBP => 'جنيه إسترليني';

  @override
  String get curCAD => 'دولار كندي';

  @override
  String get curAUD => 'دولار أسترالي';

  @override
  String get quranTitle => 'القرآن الكريم';

  @override
  String get quranSearch => 'اسم السورة أو رقمها';

  @override
  String ayahCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n آية',
      many: '$n آية',
      few: '$n آيات',
      two: 'آيتان',
      one: 'آية واحدة',
      zero: 'لا آيات',
    );
    return '$_temp0';
  }

  @override
  String get meccan => 'مكية';

  @override
  String get medinan => 'مدنية';

  @override
  String get quranSummary => '١١٤ سورة · ٦٢٣٦ آية';

  @override
  String get lastRead => 'آخر قراءة';

  @override
  String get markLastRead => 'حفظ كآخر قراءة';

  @override
  String get markedLastRead => 'حُفظت كآخر قراءة';

  @override
  String get surahNumber => 'رقم السورة';

  @override
  String get revelation => 'النزول';

  @override
  String get ayahs => 'الآيات';

  @override
  String get namesTitle => 'أسماء الله الحسنى';

  @override
  String get namesSearch => 'ابحث عن اسم أو معنى';

  @override
  String get hearIt => 'استمع';

  @override
  String get duasTitle => 'الأدعية';

  @override
  String get duasSubtitle => 'أدعية من القرآن والسنة';

  @override
  String duasCount(String duas, String topics) {
    return '$duas دعاء في $topics موضوعًا';
  }

  @override
  String get duasSearch => 'السفر، المطر، الهم، النوم…';

  @override
  String get duasLoading => 'جارٍ تحميل نحو ألف دعاء…';

  @override
  String noDuaMatch(String query) {
    return 'لا يوجد دعاء يذكر «$query».';
  }

  @override
  String duaCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n دعاء',
      many: '$n دعاءً',
      few: '$n أدعية',
      two: 'دعاءان',
      one: 'دعاء واحد',
      zero: 'لا أدعية',
    );
    return '$_temp0';
  }

  @override
  String sectionCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n قسم',
      many: '$n قسمًا',
      few: '$n أقسام',
      two: 'قسمان',
      one: 'قسم واحد',
      zero: 'لا أقسام',
    );
    return '$_temp0';
  }

  @override
  String get ruqyahTitle => 'الرقية الشرعية';

  @override
  String get ruqyahSubtitle => 'الشفاء والتحصين بكلام الله وأدعية النبي ﷺ.';

  @override
  String get recite => 'التلاوة';

  @override
  String get learn => 'تعلّم';

  @override
  String get programBrief => 'قصيرة';

  @override
  String get programMedium => 'متوسطة';

  @override
  String get programLong => 'طويلة';

  @override
  String get listenFull => 'استمع إلى التلاوة كاملة';

  @override
  String get playing => 'جارٍ التشغيل…';

  @override
  String get fromQuran => 'من القرآن';

  @override
  String get fromSunnah => 'من السنة';

  @override
  String get showMeaning => 'إظهار المعنى';

  @override
  String get hideMeaning => 'إخفاء المعنى';

  @override
  String get moreTitle => 'المزيد';

  @override
  String get allFeatures => 'كل الأقسام';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get city => 'المدينة';

  @override
  String get chooseCity => 'اختر مدينتك';

  @override
  String get asrMethod => 'وقت العصر';

  @override
  String get asrStandard => 'الجمهور';

  @override
  String get asrHanafi => 'الحنفي';

  @override
  String get asrHint =>
      'يبدأ العصر عند الحنفية متأخرًا، حين يصير ظل الشيء مثليه.';

  @override
  String get about => 'حول التطبيق';

  @override
  String get aboutBody =>
      'المواقيت والصيام والنصاب والأدعية والأسماء والرقية مصدرها islamicapi.com. سجل صلواتك والتسبيح والإعدادات تبقى على هذا الجهاز.';
}
