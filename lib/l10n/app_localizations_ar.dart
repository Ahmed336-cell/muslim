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
      'مفتاح الخدمة غير موجود. أضفه إلى الملف ‎assets/env/env.json';

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
  String get featQuranSub => 'المصحف والتفسير';

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
  String get readSurah => 'اقرأ';

  @override
  String get tapAyahHint => 'اضغط على أي آية لقراءة تفسيرها';

  @override
  String ayahRef(String surah, String n) {
    return '$surah · الآية $n';
  }

  @override
  String ayahOf(String n, String total) {
    return 'الآية $n من $total';
  }

  @override
  String get viewSurahs => 'السور';

  @override
  String get viewJuz => 'الأجزاء';

  @override
  String get recentlyRead => 'قرأت مؤخرًا';

  @override
  String fromAyah(String n) {
    return 'من الآية $n';
  }

  @override
  String get myLocation => 'موقعي الحالي';

  @override
  String get useMyLocation => 'استخدم موقعي';

  @override
  String get useMyLocationSub => 'مواقيت الصلاة حيث أنت الآن';

  @override
  String get locating => 'جارٍ تحديد موقعك…';

  @override
  String nearCity(String city) {
    return 'طريقة الحساب والعملة حسب $city';
  }

  @override
  String get locDisabled => 'خدمات الموقع متوقفة.';

  @override
  String get locDenied => 'تم رفض إذن الموقع. اضغط للمحاولة مجددًا.';

  @override
  String get locBlocked => 'الوصول إلى الموقع محظور. اسمح به من الإعدادات.';

  @override
  String get locFailed => 'تعذر تحديد موقعك. حاول مجددًا.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String pageN(String n) {
    return 'صفحة $n';
  }

  @override
  String juzN(String n) {
    return 'الجزء $n';
  }

  @override
  String get sajdah => 'سجدة';

  @override
  String get nextSurah => 'السورة التالية';

  @override
  String get previousSurah => 'السورة السابقة';

  @override
  String get readingSettings => 'إعدادات القراءة';

  @override
  String get mushafType => 'نوع المصحف';

  @override
  String get mushafUthmani => 'الرسم العثماني';

  @override
  String get mushafUthmaniSub => 'رسم مصحف المدينة النبوية';

  @override
  String get mushafTajweed => 'مصحف التجويد الملوّن';

  @override
  String get mushafTajweedSub => 'الرسم العثماني مع تلوين الأحكام';

  @override
  String get mushafSimple => 'الرسم الإملائي';

  @override
  String get mushafSimpleSub => 'إملاء حديث مع التشكيل الكامل';

  @override
  String get mushafPlain => 'بدون تشكيل';

  @override
  String get mushafPlainSub => 'حروف مجردة لتسهيل البحث';

  @override
  String get textSize => 'حجم الخط';

  @override
  String get tajweedKey => 'دليل الألوان';

  @override
  String get tjSilent => 'لا يُنطق';

  @override
  String get tjMadd => 'المد';

  @override
  String get tjGhunnah => 'الغنة';

  @override
  String get tjIkhfa => 'الإخفاء';

  @override
  String get tjIdgham => 'الإدغام';

  @override
  String get tjIqlab => 'الإقلاب';

  @override
  String get tjQalqalah => 'القلقلة';

  @override
  String get tafsir => 'التفسير';

  @override
  String get tafsirMuyassar => 'الميسر';

  @override
  String get tafsirJalalayn => 'الجلالين';

  @override
  String get tafsirBaghawi => 'البغوي';

  @override
  String get tafsirQurtubi => 'القرطبي';

  @override
  String get tafsirWaseet => 'الوسيط';

  @override
  String get tafsirIbnKathir => 'ابن كثير (مختصر)';

  @override
  String get tafsirSaheeh => 'صحيح إنترناشونال';

  @override
  String get tafsirArabicNote => 'عربي';

  @override
  String get tafsirEnglishNote => 'إنجليزي';

  @override
  String get tafsirEmpty => 'لا يوجد تفسير لهذه الآية في هذا المصدر.';

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
      'المواقيت والصيام والنصاب والأدعية والأسماء والرقية مصدرها islamicapi.com، ونص القرآن والتفسير من alquran.cloud وquran.com. سجل صلواتك والتسبيح والإعدادات تبقى على هذا الجهاز.';

  @override
  String get obSkip => 'تخطي';

  @override
  String get obNext => 'التالي';

  @override
  String get obBack => 'رجوع';

  @override
  String get obStart => 'ابدأ';

  @override
  String get obWelcomeTitle => 'أهلًا بك';

  @override
  String get obWelcomeBody =>
      'رفيق هادئ للصلاة والقرآن والذكر. لنجهّزه لك في دقيقة واحدة.';

  @override
  String get obChooseLanguage => 'اختر لغتك';

  @override
  String get obLocationTitle => 'أين تصلي؟';

  @override
  String get obLocationBody =>
      'تعتمد مواقيت الصلاة واتجاه القبلة على موقعك. اسمح بالوصول إلى الموقع أو اختر مدينة.';

  @override
  String get obChooseCity => 'اختر مدينة بدلًا من ذلك';

  @override
  String get obNotifyTitle => 'لا تفوّتك صلاة';

  @override
  String get obNotifyBody =>
      'تذكير لطيف عند دخول وقت كل صلاة، للصلوات التي تختارها.';

  @override
  String get obAllowNotifications => 'السماح بالإشعارات';

  @override
  String get obMushafTitle => 'مصحفك';

  @override
  String get obMushafBody =>
      'اختر الرسم وحجم الخط والتفسير الأنسب لك. يمكنك تغييرها في أي وقت من شاشة القراءة.';

  @override
  String get obDoneTitle => 'كل شيء جاهز';

  @override
  String get obDoneBody => 'هذه اختياراتك. اضغط على أي منها لتعديله.';

  @override
  String get prayerReminders => 'تنبيهات الصلاة';

  @override
  String get prayerRemindersSub => 'إشعار عند دخول وقت كل صلاة';

  @override
  String get notificationsDenied =>
      'الإشعارات متوقفة لهذا التطبيق. فعّلها من الإعدادات.';

  @override
  String reminderTitle(String prayer) {
    return 'حان الآن وقت صلاة $prayer';
  }

  @override
  String get reminderBody => 'حيّ على الصلاة، حيّ على الفلاح';

  @override
  String get remindersOff => 'متوقفة';

  @override
  String remindersCount(String n, String total) {
    return '$n من $total صلوات';
  }

  @override
  String get defaultTafsir => 'التفسير الافتراضي';

  @override
  String get quranReading => 'قراءة القرآن';

  @override
  String get replayTour => 'عرض جولة الترحيب';

  @override
  String get featReciters => 'القرّاء';

  @override
  String get featRecitersSub =>
      'سور كاملة بأصوات أكثر من ٢٤٠ قارئًا، ودون اتصال أيضًا';

  @override
  String get recitersSearch => 'ابحث عن قارئ';

  @override
  String surahCount(String n) {
    return '$n سورة';
  }

  @override
  String get listenFromHere => 'استمع من هنا';

  @override
  String get listenPage => 'استمع إلى هذه الصفحة';

  @override
  String get ayahReciter => 'القارئ';

  @override
  String get ayahReciterSub => 'يتلو آية آية أثناء قراءتك';

  @override
  String get download => 'تنزيل';

  @override
  String get removeDownload => 'حذف التنزيل';

  @override
  String get downloadFailed => 'تعذّر التنزيل. تحقق من الاتصال.';

  @override
  String get savedOffline => 'محفوظة دون اتصال';

  @override
  String get playbackError => 'تعذّر التشغيل. اضغط لإعادة المحاولة.';

  @override
  String get playTip => 'تشغيل';

  @override
  String get pauseTip => 'إيقاف مؤقت';

  @override
  String get nextTip => 'التالي';

  @override
  String get previousTip => 'السابق';

  @override
  String get playAll => 'تشغيل الكل';

  @override
  String get recentlyPlayed => 'استمعت إليه مؤخرًا';

  @override
  String get popularReciters => 'الأكثر استماعًا';

  @override
  String get allReciters => 'كل القرّاء';

  @override
  String get nowPlaying => 'يُتلى الآن';

  @override
  String get fromMushaf => 'من المصحف';

  @override
  String get openInMushaf => 'افتح في المصحف';

  @override
  String get repeatTip => 'تكرار';

  @override
  String get searchTip => 'بحث';

  @override
  String get ambientTitle => 'أصوات الخلفية';

  @override
  String get ambientSub => 'امزج أصواتًا هادئة مع التلاوة';

  @override
  String get ambientRain => 'مطر';

  @override
  String get ambientStorm => 'رعد ومطر';

  @override
  String get ambientFire => 'نار المدفأة';

  @override
  String get ambientWaves => 'أمواج البحر';

  @override
  String get ambientBirds => 'طيور الغابة';

  @override
  String get ambientNight => 'ليل هادئ';

  @override
  String get ambientWind => 'رياح';

  @override
  String get ambientClear => 'مسح';

  @override
  String get adhanVoice => 'صوت الأذان';

  @override
  String get adhanPlainSound => 'صوت الإشعار فقط';

  @override
  String get adhanIosNote => 'يشغّل الآيفون أول ٣٠ ثانية من الأذان مع الإشعار.';

  @override
  String get previewTip => 'استماع';

  @override
  String get featHisn => 'حصن المسلم';

  @override
  String get featHisnSub => 'أذكار وأدعية من الكتاب والسنة لكل حال';

  @override
  String get featAzkar => 'الصباح والمساء';

  @override
  String get featAzkarSub => 'أذكار اليوم مع عدّاد';

  @override
  String get morningAzkar => 'أذكار الصباح';

  @override
  String get eveningAzkar => 'أذكار المساء';

  @override
  String azkarProgress(String done, String total) {
    return 'تم $done من $total';
  }

  @override
  String get azkarAllDone => 'أتممت أذكار اليوم، تقبّل الله.';

  @override
  String get azkarTapHint => 'اضغط على البطاقة للعدّ';

  @override
  String get azkarStart => 'ابدأ';

  @override
  String get azkarContinue => 'أكمل';

  @override
  String get azkarReset => 'البدء من جديد';

  @override
  String get azkarResetConfirm => 'مسح عدّ اليوم لهذه الأذكار؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String timesCount(String n) {
    return '$n مرات';
  }

  @override
  String get hisnSearch => 'ابحث في الأبواب أو الأذكار';

  @override
  String get hisnChapters => 'الأبواب';

  @override
  String hisnChapterCount(String n) {
    return '$n بابًا';
  }

  @override
  String noHisnMatch(String q) {
    return 'لا نتائج لـ «$q»';
  }

  @override
  String get hisnSource => 'من كتاب حصن المسلم لسعيد بن وهف القحطاني.';

  @override
  String get hisnLoadFailed => 'تعذّر فتح الكتاب.';

  @override
  String get azkarReminders => 'تذكير الأذكار';

  @override
  String get azkarRemindersSub => 'تنبيه يومي لأذكار الصباح والمساء';

  @override
  String get azkarReminderBody => 'خصّص دقائق لأذكارك.';

  @override
  String azkarRemindAt(String time) {
    return 'التذكير الساعة $time';
  }

  @override
  String get azkarOff => 'متوقف';

  @override
  String get listenTip => 'استماع';

  @override
  String get copyTip => 'نسخ';

  @override
  String get morning => 'الصباح';

  @override
  String get evening => 'المساء';

  @override
  String photoCredit(String author, String licence) {
    return 'الصورة: $author · $licence · ويكيميديا كومنز';
  }

  @override
  String get widgetVerse => 'آية';

  @override
  String get widgetDua => 'دعاء';

  @override
  String get widgetEmpty => 'افتح التطبيق للتحميل';

  @override
  String get widgetsTitle => 'ويدجت الشاشة الرئيسية والقفل';

  @override
  String get widgetPrayerSub => 'الوقت المتبقي على الصلاة القادمة';

  @override
  String get widgetAyahSub => 'آية جديدة كل نصف ساعة';

  @override
  String get widgetDuaSub => 'دعاء جديد كل نصف ساعة';

  @override
  String get widgetNameSub => 'اسم من أسماء الله كل نصف ساعة';

  @override
  String get widgetAdd => 'إضافة';

  @override
  String get widgetAddFailed =>
      'لا يدعم المشغل الإضافة من هنا. اضغط مطولًا على الشاشة الرئيسية واختر الأدوات.';

  @override
  String get widgetIosHint =>
      'اضغط مطولًا على الشاشة الرئيسية أو شاشة القفل، ثم تعديل أو +، وابحث عن Muslim.';
}
