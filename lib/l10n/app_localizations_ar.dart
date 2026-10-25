// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class L10nAr extends L10n {
  L10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سبيلك';

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
  String get featIdentify => 'تعرّف';

  @override
  String get featIdentifySub => 'القارئ والسورة والآية';

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
  String get sebhaCustomize => 'شكل المسبحة';

  @override
  String get sebhaCustomizeSub => 'اختر نوع الخرز واللون.';

  @override
  String get sebhaType => 'النوع';

  @override
  String get sebhaColor => 'اللون';

  @override
  String get sebhaStyleWood => 'خشب';

  @override
  String get sebhaStyleAmber => 'كهرمان';

  @override
  String get sebhaStyleStone => 'حجر';

  @override
  String get sebhaStylePearl => 'لؤلؤ';

  @override
  String get sebhaStyleDigital => 'رقمي';

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
  String get quranSearch => 'سورة أو رقم أو ٢:٢٥٥ أو كلمات من آية';

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
      'تُحسب مواقيت الصلاة والتاريخ الهجري على هذا الجهاز، ونص القرآن مضمّن في التطبيق، أما التلاوات والتفاسير وباقي المحتوى فتُحمَّل من المصادر المذكورة. سجل صلواتك والتسبيح والإعدادات تبقى على هذا الجهاز.';

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
  String get rateApp => 'قيّم التطبيق';

  @override
  String get rateAppSub => 'تقييمك على Google Play يساعد غيرك على إيجاد سبيلك.';

  @override
  String get forceUpdateTitle => 'التحديث مطلوب';

  @override
  String get forceUpdateBody =>
      'صدر إصدار جديد على متجر Play. حدّث التطبيق لمتابعة استخدام سبيلك.';

  @override
  String get forceUpdateAction => 'تحديث';

  @override
  String get featReciters => 'القرّاء';

  @override
  String get featRecitersSub =>
      'سور كاملة بأصوات أكثر من ٢٤٠ قارئًا، ودون اتصال أيضًا';

  @override
  String get recitersSearch => 'ابحث عن قارئ';

  @override
  String get identifyReciter => 'تعرّف على القارئ';

  @override
  String get identifyListen => 'استمع';

  @override
  String get identifyListening => 'جاري الاستماع...';

  @override
  String get identifyHold => 'قرّب الهاتف من التلاوة لنحو نصف دقيقة';

  @override
  String get identifyTap => 'اضغط للاستماع';

  @override
  String get identifyMatching => 'جاري تحديد الآية…';

  @override
  String get identifyOpen => 'افتح الآية';

  @override
  String get identifyOpenReciter => 'افتح القارئ';

  @override
  String identifyPlace(String surah, String ayah) {
    return 'سورة $surah، الآية $ayah';
  }

  @override
  String identifySpan(Object from, Object surah, Object to) {
    return 'سورة $surah، الآيات $from–$to';
  }

  @override
  String identifyCrossing(
    Object fromAyah,
    Object fromSurah,
    Object toAyah,
    Object toSurah,
  ) {
    return '$fromSurah $fromAyah – $toSurah $toAyah';
  }

  @override
  String get identifyDownloading => 'جاري تنزيل نموذج الصوت…';

  @override
  String get identifyUnknown => 'لم يتم التعرف على القارئ';

  @override
  String get identifyEmpty => 'بصمات القراء غير جاهزة بعد.';

  @override
  String get identifyNeedMic => 'يلزم السماح باستخدام الميكروفون.';

  @override
  String get identifyFailed => 'تعذر التعرف على هذه التلاوة.';

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
      'اضغط مطولًا على الشاشة الرئيسية أو شاشة القفل، ثم تعديل أو +، وابحث عن سبيلك.';

  @override
  String get calcMethod => 'طريقة الحساب';

  @override
  String calcCityDefault(String city) {
    return 'المقترحة لـ$city';
  }

  @override
  String get calcOffline => 'تُحسب المواقيت على جهازك، فتعمل دون إنترنت.';

  @override
  String get adjustTimes => 'ضبط المواقيت';

  @override
  String get adjustTimesSub => 'أضف أو أنقص دقائق لتوافق مسجدك.';

  @override
  String get adjustNone => 'بدون تعديل';

  @override
  String get adjustSome => 'تعديلات مخصصة';

  @override
  String get hijriAdjust => 'التاريخ الهجري';

  @override
  String get hijriAdjustSub =>
      'قدّم أو أخّر يومًا إن اختلفت رؤية الهلال في بلدك.';

  @override
  String get credits => 'المصادر والتراخيص';

  @override
  String get creditsSub => 'مصادر نص القرآن والصوتيات والبيانات';

  @override
  String get creditsPhotos => 'صور القرّاء';

  @override
  String get creditsPhotosSub =>
      'من ويكيميديا كومنز، ويظهر اسم المصوّر والترخيص تحت كل صورة.';

  @override
  String get openSourceLicences => 'تراخيص البرمجيات مفتوحة المصدر';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyPolicySub => 'بلا حساب ولا إعلانات';

  @override
  String get privacyNoAccountTitle => 'بلا حساب ولا إعلانات';

  @override
  String get privacyNoAccount =>
      'لا يوجد في التطبيق تسجيل دخول ولا إعلانات. سجل صلواتك وعدّاد التسبيح والعلامات وتقدّم الختمة والإعدادات محفوظة على هذا الجهاز فقط، وتُحذف بحذف التطبيق.';

  @override
  String get privacyCrashesTitle => 'تقارير الأعطال';

  @override
  String get privacyCrashes =>
      'إذا توقف التطبيق أو حدث خطأ، يُرسل تقرير إلى Sentry‏ (sentry.io): نص الخطأ، وتتبع المكدس، وإصدار التطبيق، ونوع الجهاز. لا يتضمن اسمك ولا موقعك ولا سجل صلواتك ولا ما تكتبه.';

  @override
  String get privacyLocationTitle => 'الموقع';

  @override
  String get privacyLocation =>
      'إذا اخترت «موقعي»، يُستخدم موقعك على الجهاز لحساب مواقيت الصلاة والقبلة. يُقرَّب إلى نحو ١٠٠ متر، ولا يُرسل إلا إلى islamicapi.com لجلب مواعيد الصيام، ولا نحفظه على أي خادم.';

  @override
  String get privacyNetworkTitle => 'المحتوى عبر الإنترنت';

  @override
  String get privacyNetwork =>
      'تُحمَّل التلاوات والتفاسير والأدعية وغيرها من المصادر المذكورة في صفحة المصادر، وترى هذه الخدمات عنوان IP كأي موقع. يُحفظ المحتوى المحمَّل على الجهاز ليعمل دون إنترنت.';

  @override
  String get privacyNotificationsTitle => 'التنبيهات والأدوات';

  @override
  String get privacyNotifications =>
      'تُجدول التنبيهات محليًا على الجهاز، وتقرأ الأدوات بيانات يحفظها التطبيق على الجهاز؛ لا يُرسل شيء إلى أي جهة.';

  @override
  String get privacyContactTitle => 'استفسارات';

  @override
  String get privacyContact =>
      'لأي سؤال عن الخصوصية، تواصل مع المطوّر عبر صفحة التطبيق في المتجر.';

  @override
  String ayahMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آية',
      few: '$count آيات',
      two: 'آيتان',
      one: 'آية واحدة',
    );
    return '$_temp0';
  }

  @override
  String ayahMatchesMore(String shown) {
    return 'تظهر أول $shown نتيجة. أضف كلمة لتضييق البحث.';
  }

  @override
  String goToAyah(String surah, String ayah) {
    return 'اذهب إلى $surah، الآية $ayah';
  }

  @override
  String get searchArabicHint => 'اكتب كلمات عربية للبحث داخل الآيات.';

  @override
  String get khatmah => 'الختمة';

  @override
  String get khatmahSub => 'خطة لختم القرآن كاملًا';

  @override
  String get khatmahIntro =>
      'اختر عدد الأيام التي تريد أن تختم فيها القرآن، وسنقسّمه إلى ورد يومي ونتابع الصفحات التي تقرؤها.';

  @override
  String get khatmahFinishIn => 'الختم خلال';

  @override
  String khatmahDays(String n) {
    return '$n يومًا';
  }

  @override
  String khatmahPerDay(String n) {
    return '≈ $n صفحة يوميًا';
  }

  @override
  String get khatmahStart => 'ابدأ الختمة';

  @override
  String get khatmahToday => 'ورد اليوم';

  @override
  String khatmahTodayGoal(String read, String target) {
    return '$read من $target صفحة';
  }

  @override
  String get khatmahTodayDone => 'أتممت ورد اليوم، بارك الله فيك!';

  @override
  String khatmahPages(String read, String total) {
    return '$read من $total صفحة';
  }

  @override
  String khatmahDayOf(String day, String days) {
    return 'اليوم $day من $days';
  }

  @override
  String get khatmahStreak => 'المواظبة';

  @override
  String khatmahStreakDays(String n) {
    return '$n يوم';
  }

  @override
  String get khatmahAhead => 'متقدّم على الخطة';

  @override
  String get khatmahOnTrack => 'على الخطة';

  @override
  String khatmahBehind(String n) {
    return 'متأخر $n صفحة';
  }

  @override
  String khatmahContinue(String page) {
    return 'تابع من الصفحة $page';
  }

  @override
  String get khatmahHint =>
      'تُحتسب الصفحة إذا قلّبتها إلى التالية أو بقيت مفتوحة ٢٠ ثانية.';

  @override
  String get khatmahDone => 'ختمت القرآن، تقبّل الله منك!';

  @override
  String khatmahCompleted(String n) {
    return 'الختمات المكتملة: $n';
  }

  @override
  String get khatmahNew => 'ابدأ ختمة جديدة';

  @override
  String get khatmahEnd => 'إنهاء الخطة';

  @override
  String get khatmahEndConfirm => 'إنهاء هذه الختمة؟ سيُمسح تقدّمها.';

  @override
  String get khatmahReadUpTo => 'قرأت جزءًا من قبل؟';

  @override
  String khatmahReadUpToSub(String page) {
    return 'اعتبر كل الصفحات حتى الصفحة $page مقروءة.';
  }

  @override
  String get khatmahMark => 'تحديد كمقروء';

  @override
  String get featCalendar => 'التقويم الهجري';

  @override
  String get featCalendarSub => 'الشهور والمناسبات الإسلامية';

  @override
  String get featKhatmah => 'الختمة';

  @override
  String get featKhatmahSub => 'ورد يومي لختم القرآن';

  @override
  String get calendarToday => 'اليوم';

  @override
  String get calendarUpcoming => 'القادم';

  @override
  String get calendarWhiteDays => 'الأيام البيض (١٣–١٥): يُستحب صيامها';

  @override
  String calendarInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'بعد $n يومًا',
      few: 'بعد $n أيام',
      two: 'بعد يومين',
      one: 'غدًا',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String get calendarNoEvents => 'لا مناسبات في هذا اليوم.';

  @override
  String get calendarShiftNote =>
      'التواريخ وفق تقويم أم القرى. يمكنك تعديلها يومًا من الإعدادات ← ضبط المواقيت إن اختلفت رؤية الهلال في بلدك.';

  @override
  String get evNewYear => 'رأس السنة الهجرية';

  @override
  String get evNewYearSub => '١ محرم';

  @override
  String get evAshura => 'يوم عاشوراء';

  @override
  String get evAshuraSub =>
      'صيامه يكفّر السنة الماضية، ويُستحب صيام التاسع معه.';

  @override
  String get evRamadan => 'بداية رمضان';

  @override
  String get evRamadanSub => 'شهر الصيام';

  @override
  String get evLastTen => 'العشر الأواخر';

  @override
  String get evLastTenSub => 'تحرَّوا ليلة القدر في الوتر منها.';

  @override
  String get evEidFitr => 'عيد الفطر';

  @override
  String get evEidFitrSub => 'ثم ست من شوال';

  @override
  String get evDhulHijjah => 'العشر الأوائل من ذي الحجة';

  @override
  String get evDhulHijjahSub => 'أفضل أيام السنة للعمل الصالح';

  @override
  String get evArafah => 'يوم عرفة';

  @override
  String get evArafahSub => 'صيامه يكفّر سنتين.';

  @override
  String get evEidAdha => 'عيد الأضحى';

  @override
  String get evEidAdhaSub => 'يوم النحر';

  @override
  String get evTashreeq => 'أيام التشريق';

  @override
  String get evTashreeqSub => '١١–١٣ ذو الحجة: أيام أكل وشرب وذكر لله';

  @override
  String get featHifz => 'الحفظ';

  @override
  String get featHifzSub => 'احفظ بالتكرار';

  @override
  String get hifzSurah => 'السورة';

  @override
  String hifzRange(String from, String to) {
    return 'الآيات $from–$to';
  }

  @override
  String get hifzAyahRepeat => 'تكرار كل آية';

  @override
  String get hifzRangeRepeat => 'تكرار المقطع كاملًا';

  @override
  String hifzTimes(String n) {
    return '$n×';
  }

  @override
  String get hifzPlay => 'ابدأ الاستماع';

  @override
  String get hifzStop => 'إيقاف';

  @override
  String get hifzShow => 'إظهار';

  @override
  String get hifzFirstWords => 'أول الكلمات';

  @override
  String get hifzHideAll => 'إخفاء';

  @override
  String get hifzTapReveal => 'اضغط للإظهار';

  @override
  String hifzMemorized(String n, String total) {
    return 'حفظت $n من $total آية في هذه السورة';
  }

  @override
  String get hifzMark => 'تحديد كمحفوظة';

  @override
  String get hifzUnmark => 'محفوظة';

  @override
  String get hifzTestHint =>
      'أخفِ النص، واقرأ من حفظك، ثم اضغط على الآية لتتأكد.';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get tracker => 'متابعة الصلاة';

  @override
  String get featTracker => 'متابعة الصلاة';

  @override
  String get featTrackerSub => 'الأيام المتتالية والسجل وقضاء الفوائت';

  @override
  String get trackerWeek => 'آخر ٧ أيام';

  @override
  String get trackerByPrayer => 'حسب الصلاة · ٣٠ يومًا';

  @override
  String get trackerStreak => 'أيام متتالية بالخمس';

  @override
  String get trackerLast7 => 'آخر ٧ أيام';

  @override
  String get trackerLast30 => 'آخر ٣٠ يومًا';

  @override
  String get trackerTapHint => 'اضغط على أي دائرة لتسجيل صلاة في يوم سابق.';

  @override
  String get trackerEmpty =>
      'سجّل صلواتك من الشاشة الرئيسية لتظهر الإحصاءات هنا.';

  @override
  String get qadaTitle => 'قضاء الفوائت';

  @override
  String get qadaNone => 'لا توجد صلوات فائتة';

  @override
  String qadaLeft(String n) {
    return 'متبقٍ $n صلاة للقضاء';
  }

  @override
  String get qadaHint => 'أضف الصلوات الفائتة، ثم اضغط − كلما قضيت واحدة.';

  @override
  String get qadaMadeUp => 'قضيت واحدة';

  @override
  String get qadaAdd => 'إضافة';

  @override
  String get featRamadan => 'رمضان';

  @override
  String get featRamadanSub => 'عدّاد الإفطار والأدعية ومتابعة ٣٠ يومًا';

  @override
  String get featFriday => 'الجمعة';

  @override
  String get featFridaySub => 'الكهف والصلاة على النبي وساعة الإجابة';

  @override
  String get dailyAyahTitle => 'آية اليوم';

  @override
  String get kahfReminderTitle => 'الجمعة · سورة الكهف';

  @override
  String get kahfReminderBody => 'اقرأ سورة الكهف اليوم — نور بين جمعتين.';

  @override
  String get fridayHourTitle => 'آخر ساعة من يوم الجمعة';

  @override
  String get fridayHourBody =>
      'آخر ساعة قبل المغرب — أكثر من الدعاء.\n\nرَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ';

  @override
  String fridayHourRange(String from, String to) {
    return 'من $from حتى المغرب $to';
  }

  @override
  String get suhoorTitle => 'السحور';

  @override
  String suhoorBody(String n) {
    return 'بقي $n دقيقة على الفجر — وقت السحور.';
  }

  @override
  String get dailyAyahReminder => 'آية اليوم';

  @override
  String get kahfReminder => 'سورة الكهف يوم الجمعة';

  @override
  String get kahfReminderSub => 'يوم الجمعة الساعة ١٠ صباحًا';

  @override
  String get fridayHourReminder => 'آخر ساعة يوم الجمعة';

  @override
  String get fridayHourReminderSub => 'قبل المغرب بساعة';

  @override
  String get suhoorReminder => 'السحور في رمضان';

  @override
  String get suhoorReminderSub => 'قبل الفجر بـ ٤٥ دقيقة';

  @override
  String get moreReminders => 'تنبيهات يومية وأسبوعية';

  @override
  String get reminders => 'التنبيهات';

  @override
  String get jumuahMubarak => 'جمعة مباركة';

  @override
  String get fridayTomorrow => 'الجمعة غدًا';

  @override
  String fridayIn(String n) {
    return 'الجمعة بعد $n أيام';
  }

  @override
  String get fridayIntro => 'خير يوم طلعت عليه الشمس.';

  @override
  String get fridayHomeSub => 'الكهف والصلاة على النبي وساعة الإجابة';

  @override
  String get fridaySunnahs => 'سنن يوم الجمعة';

  @override
  String get sunnahGhusl => 'الاغتسال قبل الصلاة.';

  @override
  String get sunnahClothes => 'لبس أحسن الثياب والتطيب.';

  @override
  String get sunnahEarly => 'التبكير إلى المسجد والمشي إليه إن تيسر.';

  @override
  String get sunnahKhutbah => 'الإنصات للخطبة.';

  @override
  String get sunnahKahf => 'قراءة سورة الكهف.';

  @override
  String get sunnahSalawat => 'الإكثار من الصلاة على النبي ﷺ.';

  @override
  String get sunnahDua => 'الإكثار من الدعاء، خاصة في آخر ساعة قبل المغرب.';

  @override
  String get readKahf => 'اقرأ سورة الكهف';

  @override
  String get kahfHint => 'ضع علامة بعد قراءتها اليوم.';

  @override
  String get kahfDone => 'قرأتها اليوم — تقبّل الله.';

  @override
  String get salawatCounter => 'الصلاة على النبي ﷺ';

  @override
  String get salawatHint => 'اضغط على الدائرة مع كل صلاة.';

  @override
  String get iftarDua => 'دعاء الإفطار';

  @override
  String get iftarDuaMeaning =>
      'ذهب الظمأ وابتلت العروق وثبت الأجر إن شاء الله.';

  @override
  String get iftarDuaSource => 'رواه أبو داود';

  @override
  String get qadrDua => 'دعاء ليلة القدر';

  @override
  String get qadrDuaMeaning => 'اللهم إنك عفو تحب العفو فاعف عني.';

  @override
  String get qadrDuaSource => 'رواه الترمذي';

  @override
  String ramadanTracker(String year) {
    return 'رمضان $year';
  }

  @override
  String ramadanDay(String n) {
    return 'اليوم $n من رمضان';
  }

  @override
  String get iftarIn => 'الإفطار بعد';

  @override
  String get suhoorEndsIn => 'ينتهي السحور بعد';

  @override
  String ramadanIn(String n) {
    return 'رمضان بعد $n يومًا';
  }

  @override
  String get deedFast => 'الصيام';

  @override
  String get deedTaraweeh => 'التراويح';

  @override
  String get deedJuz => 'جزء من القرآن';

  @override
  String get ramadanTrackerHint =>
      'اضغط على اليوم لتسجيل الصيام والتراويح والجزء.';

  @override
  String get shareAyah => 'مشاركة الآية';

  @override
  String get shareHadith => 'مشاركة الحديث';

  @override
  String get shareName => 'مشاركة الاسم';

  @override
  String get shareDua => 'مشاركة الدعاء';

  @override
  String get shareImage => 'مشاركة كصورة';

  @override
  String get includeTranslation => 'إضافة الترجمة';

  @override
  String get share => 'مشاركة';

  @override
  String get hadithTitle => 'حديث اليوم';

  @override
  String get liveActivity => 'العدّاد على شاشة القفل';

  @override
  String get liveActivitySub => 'نشاط مباشر يعدّ الوقت حتى الصلاة القادمة';

  @override
  String get liveNow => 'حان الوقت';

  @override
  String get fridayPriorities => 'أعمال اليوم حسب الأولوية';

  @override
  String get deedJumuah => 'صلاة الجمعة والإنصات للخطبة.';

  @override
  String get tagFard => 'فرض';

  @override
  String get tagMuakkad => 'سنة مؤكدة';

  @override
  String get tagSunnah => 'سنة';

  @override
  String get kahfOpen => 'افتح';

  @override
  String get hifzPlayAyah => 'تشغيل هذه الآية';

  @override
  String get hifzPageHint =>
      'اضغط على الآية لتسمعها. اضغط على رقمها لتعليمها كمحفوظة.';

  @override
  String get hifzHistory => 'التحليلات السابقة';

  @override
  String get hifzHistoryEmpty => 'سمّع مقطعًا، وتُحفظ المراجعة هنا.';

  @override
  String get hifzFrom => 'من';

  @override
  String get hifzTo => 'إلى';

  @override
  String get reciteCheck => 'سمّع واختبر';

  @override
  String get reciteHint => 'اقرأ المقطع من حفظك، ويُراجَع على جهازك.';

  @override
  String get reciteModelTitle => 'تنزيل نموذج التسميع؟';

  @override
  String reciteModelBody(String size) {
    return 'يُنزَّل نموذج للتعرّف على التلاوة ($size) من Tarteel AI مرة واحدة. تسجيلاتك لا تغادر جهازك.';
  }

  @override
  String get reciteDownload => 'تنزيل';

  @override
  String get reciteWorkDownload => 'جارٍ تنزيل نموذج الترتيل';

  @override
  String reciteDownloading(String percent) {
    return 'جارٍ تنزيل النموذج… $percent';
  }

  @override
  String get reciteListening => 'أستمع… اضغط للإنهاء';

  @override
  String get reciteChecking => 'جارٍ مراجعة التلاوة…';

  @override
  String reciteResult(String correct, String total) {
    return '$correct من $total كلمة مطابقة';
  }

  @override
  String reciteMistakes(String count) {
    return 'أخطاء محتملة: $count';
  }

  @override
  String reciteMissed(String count) {
    return 'متروك: $count';
  }

  @override
  String get reciteLegend =>
      'أخضر: مطابق · أحمر: خطأ محتمل · مسطّر: متروك. التدقيق آلي وقد يخطئ.';

  @override
  String get reciteHeard => 'ما سُمِع';

  @override
  String get reciteClear => 'مسح';

  @override
  String get reciteNoPermission => 'يلزم السماح بالميكروفون لتدقيق التلاوة.';

  @override
  String get reciteFailed => 'تعذّر التدقيق، حاول مرة أخرى.';

  @override
  String get reciteNothing => 'لم يُسمع شيء، ارفع صوتك قليلاً.';

  @override
  String get reciteDownloadFailed => 'فشل التنزيل، تحقق من الاتصال.';

  @override
  String get reciteRevealLive => 'أظهر الكلمات أثناء تلاوتي';

  @override
  String get reciteRevealLiveHint =>
      'تبقى الصفحة مغطاة وتظهر كل كلمة عند سماعها.';

  @override
  String reciteProgress(String done, String total) {
    return '$done من $total كلمة';
  }

  @override
  String get feedbackTitle => 'نتيجة التسميع';

  @override
  String get gradeExcellent => 'ممتاز، ما شاء الله';

  @override
  String get gradeVeryGood => 'جيد جدًا';

  @override
  String get gradeGood => 'جيد، راجع الكلمات المعلّمة';

  @override
  String get gradeReview => 'يحتاج إلى مراجعة';

  @override
  String get feedbackMatched => 'مطابق';

  @override
  String get feedbackMistakes => 'أخطاء محتملة';

  @override
  String get feedbackSkipped => 'متروك';

  @override
  String get feedbackReview => 'كلمات للمراجعة';

  @override
  String feedbackHeardAs(String word) {
    return 'سُمِع: $word';
  }

  @override
  String get feedbackSkippedWord => 'متروكة';

  @override
  String feedbackPerfect(String count) {
    return 'آيات بلا أخطاء: $count';
  }

  @override
  String get feedbackMarkLearnt => 'علّمها كمحفوظة';

  @override
  String feedbackUnreached(String count) {
    return 'توقفت قبل النهاية: $count كلمة لم تُقرأ.';
  }

  @override
  String get feedbackOpen => 'التقييم';

  @override
  String get feedbackDone => 'تم';

  @override
  String get featHadith => 'الحديث';

  @override
  String get featHadithSub => 'الأربعون النووية والقدسية ورياض الصالحين';

  @override
  String get hadithSearch => 'ابحث في الأحاديث';

  @override
  String hadithCount(String count) {
    return '$count حديث';
  }

  @override
  String hadithNumber(String number) {
    return 'الحديث $number';
  }

  @override
  String get hadithSaved => 'الأحاديث المحفوظة';

  @override
  String get hadithSave => 'حفظ';

  @override
  String get hadithUnsave => 'إزالة من المحفوظة';

  @override
  String hadithNoMatch(String query) {
    return 'لا توجد أحاديث تطابق «$query»';
  }

  @override
  String get hadithChapters => 'الكتب';

  @override
  String get hadithSource =>
      'النصوص العربية والترجمة الإنجليزية من موقع Sunnah.com عبر مشروع hadith-json المفتوح.';

  @override
  String get wirdReminder => 'تذكير الورد اليومي';

  @override
  String get wirdReminderTitle => 'وردك اليومي';

  @override
  String get wirdReminderBody =>
      'اقرأ وردك من القرآن اليوم وحافظ على استمرارك.';

  @override
  String wirdPortion(String first, String last) {
    return 'ورد اليوم: الصفحات $first–$last';
  }

  @override
  String wirdPortionOne(String page) {
    return 'ورد اليوم: الصفحة $page';
  }

  @override
  String get wirdMarkDone => 'قرأت ورد اليوم';

  @override
  String get sadaqahReminder => 'تذكير صدقة الجمعة';

  @override
  String get sadaqahReminderTitle => 'الصدقة';

  @override
  String get sadaqahReminderBody =>
      'ما نقصت صدقة من مال. تصدّق اليوم ولو بالقليل.';

  @override
  String sadaqahRemindAt(String time) {
    return 'كل جمعة الساعة $time';
  }

  @override
  String get save => 'حفظ';

  @override
  String get featSadaqah => 'الصدقة';

  @override
  String get featSadaqahSub => 'سجل خاص وهدف شهري وتذكير الجمعة';

  @override
  String get sadaqahAdd => 'سجّل صدقة';

  @override
  String get sadaqahMoney => 'مال';

  @override
  String get sadaqahFood => 'طعام';

  @override
  String get sadaqahHelp => 'مساعدة';

  @override
  String get sadaqahOther => 'أخرى';

  @override
  String get sadaqahAmount => 'المبلغ (اختياري)';

  @override
  String get sadaqahNote => 'ملاحظة (اختياري)';

  @override
  String get sadaqahPrivate => 'يبقى على هاتفك فقط.';

  @override
  String sadaqahCount(String count) {
    return '$count هذا الشهر';
  }

  @override
  String get sadaqahSetGoal => 'حدّد هدفًا شهريًا';

  @override
  String sadaqahGoalOf(String amount, String currency) {
    return 'الهدف: $amount $currency';
  }

  @override
  String get sadaqahGoalTitle => 'الهدف الشهري';

  @override
  String get sadaqahNoGoal => 'بلا هدف';

  @override
  String get sadaqahStreak => 'أسابيع متتالية';

  @override
  String sadaqahWeeks(String count) {
    return '$count أسابيع';
  }

  @override
  String get sadaqahHistory => 'السجل';

  @override
  String get sadaqahEmpty => 'لا شيء بعد. وتبسّمك في وجه أخيك صدقة.';

  @override
  String get sadaqahHadith => '«ما نقصت صدقة من مال» — رواه مسلم';

  @override
  String get featQada => 'قضاء الصيام';

  @override
  String get featQadaSub => 'متابعة القضاء والفدية والكفارة';

  @override
  String get qadaRemaining => 'أيام متبقية للقضاء';

  @override
  String qadaMadeOf(String made, String owed) {
    return 'قضيت $made من $owed';
  }

  @override
  String get qadaLess => 'إنقاص يوم';

  @override
  String get qadaMore => 'إضافة يوم';

  @override
  String get qadaMarkToday => 'أنا صائم اليوم';

  @override
  String get qadaFastedToday => 'صائم اليوم';

  @override
  String get qadaAllDone => 'أتممت القضاء، تقبّل الله منك.';

  @override
  String get qadaTip =>
      'الاثنين والخميس والأيام البيض (١٣–١٥) أيام طيبة للقضاء.';

  @override
  String get qadaIntro =>
      'فاتتك أيام من رمضان لمرض أو سفر أو حمل أو حيض؟ أضفها بزر + وعلّم كل يوم تقضيه.';

  @override
  String qadaFromRamadan(String year, String count) {
    return 'في متابعة رمضان $year $count أيام غير معلّمة كصيام.';
  }

  @override
  String get qadaFidyah => 'الفدية';

  @override
  String get qadaFidyahInfo =>
      'لمن لا يستطيع الصيام أبدًا كالكبير والمريض مرضًا مزمنًا: إطعام مسكين عن كل يوم.';

  @override
  String qadaFidyahMeals(String count) {
    return '$count وجبات';
  }

  @override
  String qadaFidyahTotal(String count, String total) {
    return '$count وجبات ≈ $total';
  }

  @override
  String get qadaMealCost => 'تكلفة الوجبة';

  @override
  String get qadaKaffarah => 'الكفارة';

  @override
  String get qadaKaffarahInfo =>
      'إفساد صوم رمضان بالجماع يوجب الكفارة: صيام شهرين متتابعين، فإن لم يستطع فإطعام ستين مسكينًا.';

  @override
  String get qadaKaffarahStart => 'ابدأ الستين يومًا';

  @override
  String qadaKaffarahProgress(String days, String total) {
    return '$days من $total يومًا متتابعة';
  }

  @override
  String get qadaKaffarahBroken =>
      'فات يوم فيجب البدء من جديد (إلا إن كان الفطر لمرض أو حيض).';

  @override
  String get qadaKaffarahRestart => 'ابدأ من جديد';

  @override
  String get qadaKaffarahDone => 'تمّت الكفارة، تقبّل الله منك.';

  @override
  String get qadaDisclaimer => 'تختلف أقوال العلماء؛ اسأل أهل العلم عن حالتك.';

  @override
  String get featSleep => 'قبل النوم';

  @override
  String get featSleepSub => 'أذكار النوم وسورة الملك ومؤقت النوم';

  @override
  String get sleepIntro =>
      'اختم يومك بذكر الله. تخفت التلاوة بهدوء عند انتهاء المؤقت.';

  @override
  String get sleepAdhkar => 'أذكار النوم';

  @override
  String sleepAdhkarSub(String count) {
    return '$count من حصن المسلم';
  }

  @override
  String get sleepRecite => 'ما يُقرأ قبل النوم';

  @override
  String get sleepListen => 'استمع';

  @override
  String get sleepMulk => 'سورة الملك';

  @override
  String get sleepMulkWhy => 'شفعت لصاحبها حتى غُفر له. — الترمذي';

  @override
  String get sleepSajdah => 'سورة السجدة';

  @override
  String get sleepSajdahWhy =>
      'كان ﷺ لا ينام حتى يقرأ السجدة وتبارك. — الترمذي';

  @override
  String get sleepKursi => 'آية الكرسي';

  @override
  String get sleepKursiWhy => 'لا يزال عليك من الله حافظ حتى تصبح. — البخاري';

  @override
  String get sleepBaqarah => 'خواتيم سورة البقرة';

  @override
  String get sleepBaqarahWhy => 'من قرأهما في ليلة كفتاه. — متفق عليه';

  @override
  String get sleepQuls => 'الإخلاص والفلق والناس';

  @override
  String get sleepQulsWhy =>
      'اجمع كفيك وانفث فيهما واقرأها وامسح بهما جسدك ثلاثًا. — البخاري';

  @override
  String get sleepTimer => 'مؤقت النوم';

  @override
  String sleepMinutes(String minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get sleepEndOfSurah => 'نهاية السورة';

  @override
  String get sleepOff => 'إيقاف';

  @override
  String get sleepTimerHint => 'متاح أيضًا في المشغل: اضغط أيقونة القمر.';

  @override
  String get featTravel => 'المسافر';

  @override
  String get featTravelSub => 'قصر الصلاة وجمعها في السفر';

  @override
  String get travelOn => 'أنت مسافر';

  @override
  String get travelOff => 'أنت مقيم';

  @override
  String travelFromHome(String km) {
    return 'على بعد $km كم من بلدك';
  }

  @override
  String travelDay(String day) {
    return 'اليوم $day من سفرك';
  }

  @override
  String get travelAuto => 'تلقائي';

  @override
  String get travelModeOn => 'مسافر';

  @override
  String get travelModeOff => 'مقيم';

  @override
  String get travelAutoHint =>
      'يعمل التلقائي عندما يبعد موقع الصلاة أكثر من ٨٠ كم عن بلدك.';

  @override
  String get travelSetHome => 'اجعل هذا بلدي';

  @override
  String get travelToday => 'صلوات اليوم';

  @override
  String travelRakahs(String count) {
    return '$count ركعات';
  }

  @override
  String get travelCombine => 'الجمع';

  @override
  String travelCombineDay(String first, String second, String from, String to) {
    return '$first مع $second: في وقت إحداهما، من $from حتى $to.';
  }

  @override
  String travelCombineNight(
    String first,
    String second,
    String from,
    String to,
  ) {
    return '$first مع $second: في وقت إحداهما، من $from حتى $to.';
  }

  @override
  String get travelCombineHint => 'لا تُجمع الفجر، وتبقى المغرب ثلاث ركعات.';

  @override
  String get travelRules => 'أهم الأحكام';

  @override
  String get travelRuleDistance =>
      'السفر نحو ٨٠ كم أو أكثر يبيح القصر، بعد مفارقة عمران البلد.';

  @override
  String get travelRuleQasr => 'تُصلى الظهر والعصر والعشاء ركعتين بدل أربع.';

  @override
  String get travelRuleJam =>
      'يجوز جمع الظهر مع العصر، والمغرب مع العشاء، في وقت إحداهما.';

  @override
  String get travelRuleStay =>
      'نية الإقامة أكثر من أربعة أيام تجعلك مقيمًا عند الجمهور (١٥ يومًا عند الحنفية).';

  @override
  String get travelRuleSunnah => 'تُترك السنن الرواتب إلا سنة الفجر والوتر.';

  @override
  String get travelRuleImam => 'إن صليت خلف إمام مقيم فأتمّ معه أربعًا.';

  @override
  String get travelRuleFast => 'يجوز الفطر في رمضان للمسافر ويقضي بعد ذلك.';

  @override
  String get travelDuas => 'أدعية السفر';

  @override
  String get travelDuaSetOff => 'دعاء السفر';

  @override
  String get travelDuaSetOffMeaning => '';

  @override
  String get travelDuaTown => 'عند دخول البلد';

  @override
  String get travelDuaTownMeaning => '';

  @override
  String get travelDuaStop => 'عند النزول في مكان';

  @override
  String get travelDuaStopMeaning => '';

  @override
  String travelBanner(String km) {
    return 'يبدو أنك مسافر ($km كم من بلدك). اطّلع على أحكام القصر والجمع.';
  }

  @override
  String get featLearn => 'تعلّم الصلاة';

  @override
  String get featLearnSub => 'الوضوء والصلاة خطوة بخطوة';

  @override
  String lessonSteps(String count) {
    return '$count خطوات';
  }

  @override
  String lessonQuestions(String count) {
    return '$count أسئلة';
  }

  @override
  String lessonStepOf(String number, String total) {
    return 'الخطوة $number من $total';
  }

  @override
  String lessonQuestionOf(String number, String total) {
    return 'السؤال $number من $total';
  }

  @override
  String get lessonBack => 'السابق';

  @override
  String get lessonNext => 'التالي';

  @override
  String get lessonStartQuiz => 'ابدأ الاختبار';

  @override
  String get lessonRight => 'إجابة صحيحة!';

  @override
  String get lessonWrong => 'ليست صحيحة.';

  @override
  String get lessonDone => 'أتممت الدرس';

  @override
  String lessonScore(String correct, String total) {
    return '$correct من $total صحيحة';
  }

  @override
  String get lessonRetryQuiz => 'أعد الاختبار';

  @override
  String get featTajweed => 'التجويد';

  @override
  String get featTajweedSub => 'الأحكام بالأمثلة والاختبارات';

  @override
  String get featKids => 'الأطفال';

  @override
  String get featKidsSub => 'الحروف وقصار السور والأدعية مع النجوم';

  @override
  String kidsStars(String count) {
    return '$count نجمة';
  }

  @override
  String get kidsStarsHint => 'أكمل الدروس واحفظ السور لتجمع المزيد.';

  @override
  String get kidsLetters => 'الحروف العربية';

  @override
  String get kidsLettersSub => 'اضغط على الحرف لترى اسمه وكلمة تبدأ به.';

  @override
  String get kidsSurahs => 'قصار السور';

  @override
  String get kidsListen => 'استمع وردّد';

  @override
  String kidsAyahs(String count) {
    return '$count آيات';
  }

  @override
  String get kidsLearnt => 'حفظتها';

  @override
  String get kidsDuas => 'الأدعية والصلاة';

  @override
  String get widgetHadith => 'حديث';

  @override
  String get widgetHijri => 'التاريخ الهجري';

  @override
  String get widgetSubhanallah => 'سبحان الله';

  @override
  String get widgetAlhamdulillah => 'الحمد لله';

  @override
  String get widgetAllahuAkbar => 'الله أكبر';

  @override
  String get widgetReset => 'تصفير';

  @override
  String widgetEventIn(String event, String days) {
    return '$event بعد $days يومًا';
  }

  @override
  String get showLess => 'عرض أقل';

  @override
  String get azkarSleepSub => 'اقرأها إذا أويت إلى فراشك';

  @override
  String get compassHold =>
      'أمسك الهاتف مستوياً ودُر حتى تشير الكعبة إلى الأعلى';

  @override
  String get compassCalibrate =>
      'الدقة منخفضة — حرّك الهاتف على شكل رقم 8 وأبعده عن المعادن';

  @override
  String get qiblaAr => 'القبلة بالواقع المعزز';

  @override
  String get qiblaArHint =>
      'أمسك الهاتف رأسياً ودُر حتى يتجه المصلّى نحو الكعبة';

  @override
  String get qiblaArNoCamera =>
      'الكاميرا غير متاحة. اسمح بالوصول إلى الكاميرا لترى القبلة من حولك.';

  @override
  String get kaaba => 'الكعبة';

  @override
  String get qiblaArPray => 'يمكنك البدء في الصلاة';

  @override
  String get featHajj => 'الحج والعمرة';

  @override
  String get featHajjSub => 'المناسك خطوة بخطوة بالصور';

  @override
  String get salawatReminderTitle => 'الجمعة · الصلاة على النبي';

  @override
  String get salawatReminderBody =>
      'أكثر اليوم من الصلاة على النبي ﷺ.\n\nاللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ';

  @override
  String get salawatReminder => 'الصلاة على النبي يوم الجمعة';

  @override
  String get salawatReminderSub => 'يوم الجمعة الساعة ١١ صباحًا';

  @override
  String get featTawashih => 'تواشيح';

  @override
  String get featTawashihSub => 'منشدون ومدائح نبوية';

  @override
  String get featRadio => 'إذاعة القرآن الكريم';

  @override
  String get featRadioSub => 'بث مباشر من القاهرة';

  @override
  String get radioLive => 'مباشر';

  @override
  String get radioCity => 'القاهرة';

  @override
  String get badgeNew => 'جديد';

  @override
  String get tawashihIntro =>
      'تواشيح ومدائح بصوت كبار المنشدين. اختر منشدًا ثم مقطعًا.';

  @override
  String get rawatibTitle => 'السنن الرواتب';

  @override
  String rawatibBefore(String n) {
    return '$n ركعات قبلها';
  }

  @override
  String rawatibAfter(String n) {
    return '$n ركعات بعدها';
  }

  @override
  String get rawatibNone => 'لا راتبة مؤكدة لهذه الصلاة.';

  @override
  String get rawatibHint => 'بعد الفرض صلِّ السنن الرواتب.';

  @override
  String get tahajjudReminder => 'التهجد';

  @override
  String get tahajjudReminderSub => 'بداية الثلث الأخير من الليل';

  @override
  String get tahajjudTitle => 'حان وقت التهجد';

  @override
  String get tahajjudBody => 'بدأ الثلث الأخير من الليل — وقت مبارك للقيام.';

  @override
  String get duhaReminder => 'الضحى';

  @override
  String get duhaReminderSub => 'بعد الشروق بنحو ٢٠ دقيقة';

  @override
  String get duhaTitle => 'حان وقت صلاة الضحى';

  @override
  String get duhaBody => 'مضى الشروق — صلِّ الضحى قبل الظهر.';

  @override
  String get iqamaTitle => 'عدّاد الإقامة';

  @override
  String get iqamaIntro =>
      'حدد المدة حتى الإقامة. عند انتهائها تقوم الأسرة للصلاة معًا.';

  @override
  String iqamaMinutes(String n) {
    return '$n د';
  }

  @override
  String get iqamaStart => 'بدء العدّ';

  @override
  String get iqamaCancel => 'إلغاء';

  @override
  String get iqamaUntil => 'حتى الإقامة';

  @override
  String get iqamaStanding => 'قوموا إلى الصلاة';

  @override
  String get iqamaAgain => 'إعادة';

  @override
  String get iqamaOpen => 'إقامة الأسرة';

  @override
  String get comfortReading => 'قراءة مريحة';

  @override
  String get comfortReadingSub => 'خط عربي كبير لراحة العين';

  @override
  String trackCount(String n) {
    return '$n مقطع';
  }

  @override
  String get allMunshids => 'كل المنشدين';

  @override
  String get popularMunshids => 'الأكثر استماعًا';

  @override
  String prayerIn(String name) {
    return '$name بعد';
  }

  @override
  String get midnight => 'منتصف الليل';

  @override
  String get lastThird => 'الثلث الأخير';

  @override
  String get sleepAzkarReminder => 'أذكار النوم';

  @override
  String get sleepAzkarReminderSub => 'بعد العشاء بنحو ٤٥ دقيقة';

  @override
  String get sleepAzkarTitle => 'حان وقت أذكار النوم';

  @override
  String get sleepAzkarBody => 'اختم يومك بذكر الله قبل أن تنام.';

  @override
  String get featBooks => 'كتب';

  @override
  String get featBooksSub => 'مكتبة إسلامية عربية مجانية';

  @override
  String get booksIntro =>
      'كتب إسلامية عربية كلاسيكية — اقرأها مجانًا داخل التطبيق.';

  @override
  String get booksFree => 'مجاني';

  @override
  String get booksOpenFail => 'تعذر تحميل الكتاب.';

  @override
  String get booksOpenExternal => 'فتح في المتصفح';

  @override
  String get booksSource => 'المصدر: إسلام هاوس — مجاني للاستخدام الشخصي.';

  @override
  String get booksCatAqidah => 'عقيدة';

  @override
  String get booksCatTafsir => 'تفسير';

  @override
  String get booksCatHadith => 'حديث';

  @override
  String get booksCatSeerah => 'سيرة';

  @override
  String get booksCatAdhkar => 'أذكار';

  @override
  String get booksCatFiqh => 'فقه';
}
