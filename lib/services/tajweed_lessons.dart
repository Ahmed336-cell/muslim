import 'package:flutter/material.dart';

import 'lessons.dart';

const _izhar = (en: 'Izhar (clear)', ar: 'الإظهار');
const _idgham = (en: 'Idgham (merging)', ar: 'الإدغام');
const _iqlab = (en: 'Iqlab (turning to m)', ar: 'الإقلاب');
const _ikhfa = (en: 'Ikhfa (hiding)', ar: 'الإخفاء');

const tajweedLessons = [
  Lesson(
    id: 'tajweed_noon',
    icon: Icons.looks_one_outlined,
    title: (en: 'Noon sakinah & tanween', ar: 'أحكام النون الساكنة والتنوين'),
    subtitle: (
      en: 'Izhar, idgham, iqlab, ikhfa',
      ar: 'الإظهار والإدغام والإقلاب والإخفاء',
    ),
    steps: [
      LessonStep(
        icon: Icons.info_outline_rounded,
        title: (en: 'What is it?', ar: 'ما هي؟'),
        body: (
          en:
              'A noon with sukun (نْ) or tanween (ـً ـٍ ـٌ) is read in one of four '
              'ways, decided by the letter that comes after it.',
          ar:
              'النون الساكنة (نْ) والتنوين (ـً ـٍ ـٌ) لهما أربعة أحكام، بحسب الحرف '
              'الذي يأتي بعدهما.',
        ),
      ),
      LessonStep(
        icon: Icons.visibility_outlined,
        title: _izhar,
        body: (
          en:
              'Before the six throat letters ء ه ع ح غ خ, say the noon clearly, '
              'with no nasal sound.',
          ar: 'إذا جاء بعدها أحد حروف الحلق الستة: ء ه ع ح غ خ، تُنطق النون واضحة بلا غنة.',
        ),
        arabic: 'مَنْ آمَنَ ۝ مِنْ خَوْفٍ ۝ عَذَابٌ أَلِيمٌ',
      ),
      LessonStep(
        icon: Icons.merge_rounded,
        title: _idgham,
        body: (
          en:
              'Before the letters of يرملون the noon merges into the next letter: '
              'with ghunnah before ي ن م و, without it before ل ر.',
          ar:
              'إذا جاء بعدها أحد حروف «يرملون» أُدغمت النون فيه: بغنة مع (ي ن م و)، '
              'وبلا غنة مع (ل ر).',
        ),
        arabic: 'مَن يَقُولُ ۝ مِن وَلِيٍّ ۝ مِن رَّبِّهِمْ',
      ),
      LessonStep(
        icon: Icons.swap_horiz_rounded,
        title: _iqlab,
        body: (
          en:
              'Before ب, the noon turns into a hidden meem with ghunnah. The '
              'mushaf marks it with a small م.',
          ar: 'إذا جاء بعدها الباء قُلبت النون ميمًا مخفاة بغنة، وتُعلَّم بميم صغيرة.',
        ),
        arabic: 'مِنۢ بَعْدِ ۝ سَمِيعٌۢ بَصِيرٌ',
      ),
      LessonStep(
        icon: Icons.blur_on_rounded,
        title: _ikhfa,
        body: (
          en:
              'Before the remaining 15 letters, the noon is half-hidden: between '
              'clear and merged, with ghunnah of two counts.',
          ar: 'مع باقي الحروف الخمسة عشر تُخفى النون بين الإظهار والإدغام مع غنة بمقدار حركتين.',
        ),
        arabic: 'مِن قَبْلِ ۝ أَنتُمْ ۝ عَن صَلَاتِهِمْ',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: (en: 'Which rule is here?', ar: 'ما الحكم هنا؟'),
        arabic: 'مِنْ بَعْدِ',
        options: [_izhar, _idgham, _iqlab, _ikhfa],
        answer: 2,
        explain: (
          en: 'Noon sakinah before ب is iqlab.',
          ar: 'النون الساكنة قبل الباء إقلاب.',
        ),
      ),
      QuizQuestion(
        question: (en: 'Which rule is here?', ar: 'ما الحكم هنا؟'),
        arabic: 'مَنْ آمَنَ',
        options: [_izhar, _idgham, _iqlab, _ikhfa],
        answer: 0,
        explain: (
          en: 'Hamza is a throat letter: izhar.',
          ar: 'الهمزة من حروف الحلق: إظهار.',
        ),
      ),
      QuizQuestion(
        question: (en: 'Which rule is here?', ar: 'ما الحكم هنا؟'),
        arabic: 'مَن يَعْمَلْ',
        options: [_izhar, _idgham, _iqlab, _ikhfa],
        answer: 1,
        explain: (
          en: 'ي is one of يرملون: idgham with ghunnah.',
          ar: 'الياء من «يرملون»: إدغام بغنة.',
        ),
      ),
      QuizQuestion(
        question: (en: 'Which rule is here?', ar: 'ما الحكم هنا؟'),
        arabic: 'أَنفُسَكُمْ',
        options: [_izhar, _idgham, _iqlab, _ikhfa],
        answer: 3,
        explain: (
          en: 'ف is one of the 15 ikhfa letters.',
          ar: 'الفاء من حروف الإخفاء.',
        ),
      ),
      QuizQuestion(
        question: (
          en: 'Idgham without ghunnah happens before…',
          ar: 'الإدغام بلا غنة يكون مع…',
        ),
        options: [
          (en: 'ل and ر', ar: 'اللام والراء'),
          (en: 'ي and و', ar: 'الياء والواو'),
          (en: 'م and ن', ar: 'الميم والنون'),
        ],
        answer: 0,
      ),
    ],
  ),
  Lesson(
    id: 'tajweed_meem',
    icon: Icons.looks_two_outlined,
    title: (en: 'Meem sakinah', ar: 'أحكام الميم الساكنة'),
    subtitle: (en: 'Three rules for مْ', ar: 'ثلاثة أحكام للميم الساكنة'),
    steps: [
      LessonStep(
        icon: Icons.blur_on_rounded,
        title: (en: 'Ikhfa shafawi', ar: 'الإخفاء الشفوي'),
        body: (
          en: 'Meem sakinah before ب: hide the meem with ghunnah, lips lightly closed.',
          ar: 'الميم الساكنة قبل الباء: تُخفى مع الغنة وانطباق خفيف للشفتين.',
        ),
        arabic: 'تَرْمِيهِم بِحِجَارَةٍ',
      ),
      LessonStep(
        icon: Icons.merge_rounded,
        title: (en: 'Idgham shafawi', ar: 'الإدغام الشفوي'),
        body: (
          en: 'Meem sakinah before another م: merge them into one meem with ghunnah.',
          ar: 'الميم الساكنة قبل ميم: تُدغمان في ميم واحدة مشددة بغنة.',
        ),
        arabic: 'كَم مِّن فِئَةٍ ۝ لَهُم مَّا يَشَاءُونَ',
      ),
      LessonStep(
        icon: Icons.visibility_outlined,
        title: (en: 'Izhar shafawi', ar: 'الإظهار الشفوي'),
        body: (
          en: 'Before every other letter, say the meem clearly — take extra care before و and ف.',
          ar: 'مع باقي الحروف تُظهر الميم، ويُعتنى بإظهارها أكثر عند الواو والفاء.',
        ),
        arabic: 'أَلَمْ تَرَ ۝ هُمْ فِيهَا',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: (en: 'Which rule is here?', ar: 'ما الحكم هنا؟'),
        arabic: 'تَرْمِيهِم بِحِجَارَةٍ',
        options: [
          (en: 'Ikhfa shafawi', ar: 'إخفاء شفوي'),
          (en: 'Idgham shafawi', ar: 'إدغام شفوي'),
          (en: 'Izhar shafawi', ar: 'إظهار شفوي'),
        ],
        answer: 0,
      ),
      QuizQuestion(
        question: (en: 'Which rule is here?', ar: 'ما الحكم هنا؟'),
        arabic: 'أَلَمْ تَرَ',
        options: [
          (en: 'Ikhfa shafawi', ar: 'إخفاء شفوي'),
          (en: 'Idgham shafawi', ar: 'إدغام شفوي'),
          (en: 'Izhar shafawi', ar: 'إظهار شفوي'),
        ],
        answer: 2,
      ),
      QuizQuestion(
        question: (en: 'Which rule is here?', ar: 'ما الحكم هنا؟'),
        arabic: 'كَم مِّن',
        options: [
          (en: 'Ikhfa shafawi', ar: 'إخفاء شفوي'),
          (en: 'Idgham shafawi', ar: 'إدغام شفوي'),
          (en: 'Izhar shafawi', ar: 'إظهار شفوي'),
        ],
        answer: 1,
      ),
    ],
  ),
  Lesson(
    id: 'tajweed_madd',
    icon: Icons.straighten_rounded,
    title: (en: 'Madd (lengthening)', ar: 'أحكام المد'),
    subtitle: (en: 'How long to hold a vowel', ar: 'مقدار مدّ الحروف'),
    steps: [
      LessonStep(
        icon: Icons.info_outline_rounded,
        title: (en: 'Madd letters', ar: 'حروف المد'),
        body: (
          en:
              'Alif after fatha, waw sakinah after damma and yaa sakinah after kasra '
              'are held. One count is about the time to bend a finger.',
          ar:
              'الألف بعد فتح، والواو الساكنة بعد ضم، والياء الساكنة بعد كسر. '
              'والحركة مقدار قبض الإصبع أو بسطه.',
        ),
        arabic: 'قَالَ ۝ يَقُولُ ۝ قِيلَ',
      ),
      LessonStep(
        icon: Icons.looks_two_outlined,
        title: (en: 'Natural madd — 2 counts', ar: 'المد الطبيعي — حركتان'),
        body: (
          en: 'A madd letter with no hamza or sukun after it.',
          ar: 'حرف مد ليس بعده همز ولا سكون.',
        ),
        arabic: 'نُوحِيهَا',
      ),
      LessonStep(
        icon: Icons.link_rounded,
        title: (en: 'Connected madd — 4 or 5', ar: 'المد المتصل — ٤ أو ٥'),
        body: (
          en: 'Hamza comes after the madd letter in the same word. It must be lengthened.',
          ar: 'يأتي الهمز بعد حرف المد في كلمة واحدة، ومدّه واجب.',
        ),
        arabic: 'جَاءَ ۝ السَّمَاءِ ۝ سُوءَ',
      ),
      LessonStep(
        icon: Icons.link_off_rounded,
        title: (
          en: 'Separated madd — 2, 4 or 5',
          ar: 'المد المنفصل — ٢ أو ٤ أو ٥',
        ),
        body: (
          en: 'The madd letter ends one word and the next word starts with hamza.',
          ar: 'حرف المد في آخر كلمة والهمز في أول الكلمة التالية.',
        ),
        arabic: 'يَا أَيُّهَا ۝ بِمَا أُنزِلَ',
      ),
      LessonStep(
        icon: Icons.looks_6_outlined,
        title: (en: 'Necessary madd — 6', ar: 'المد اللازم — ٦ حركات'),
        body: (
          en: 'A madd letter followed by a permanent sukun or shaddah.',
          ar: 'حرف مد بعده سكون أصلي أو شدة.',
        ),
        arabic: 'الضَّالِّينَ ۝ الۤمۤ',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: (
          en: 'How long is the madd in جَاءَ?',
          ar: 'كم يُمد في «جَاءَ»؟',
        ),
        arabic: 'جَاءَ',
        options: [
          (en: '2 counts', ar: 'حركتان'),
          (en: '4 or 5 counts', ar: '٤ أو ٥ حركات'),
          (en: '6 counts', ar: '٦ حركات'),
        ],
        answer: 1,
        explain: (
          en: 'Hamza in the same word: connected madd.',
          ar: 'الهمز في نفس الكلمة: مد متصل.',
        ),
      ),
      QuizQuestion(
        question: (
          en: 'How long is the madd in الضَّالِّينَ?',
          ar: 'كم يُمد في «الضَّالِّينَ»؟',
        ),
        arabic: 'الضَّالِّينَ',
        options: [
          (en: '2 counts', ar: 'حركتان'),
          (en: '4 or 5 counts', ar: '٤ أو ٥ حركات'),
          (en: '6 counts', ar: '٦ حركات'),
        ],
        answer: 2,
        explain: (
          en: 'Shaddah after the alif: necessary madd.',
          ar: 'شدة بعد الألف: مد لازم.',
        ),
      ),
      QuizQuestion(
        question: (
          en: 'Which madd is in يَا أَيُّهَا?',
          ar: 'ما نوع المد في «يَا أَيُّهَا»؟',
        ),
        arabic: 'يَا أَيُّهَا',
        options: [
          (en: 'Natural', ar: 'طبيعي'),
          (en: 'Connected', ar: 'متصل'),
          (en: 'Separated', ar: 'منفصل'),
        ],
        answer: 2,
      ),
    ],
  ),
  Lesson(
    id: 'tajweed_qalqalah',
    icon: Icons.graphic_eq_rounded,
    title: (en: 'Qalqalah & ghunnah', ar: 'القلقلة والغنة'),
    subtitle: (en: 'Echo and nasal sound', ar: 'الاهتزاز والصوت الأنفي'),
    steps: [
      LessonStep(
        icon: Icons.graphic_eq_rounded,
        title: (en: 'Qalqalah', ar: 'القلقلة'),
        body: (
          en:
              'The letters of قطب جد (ق ط ب ج د) bounce with a slight echo when '
              'they have sukun — strongest when you stop on them.',
          ar: 'حروف «قطب جد» إذا سكنت تُنطق باهتزاز ونبرة، وأقواها عند الوقف عليها.',
        ),
        arabic: 'الْفَلَقِ ۝ لَمْ يَلِدْ ۝ أَحَدٌ',
      ),
      LessonStep(
        icon: Icons.music_note_outlined,
        title: (en: 'Ghunnah', ar: 'الغنة'),
        body: (
          en: 'A noon or meem with shaddah is held with a nasal sound for two counts.',
          ar: 'النون والميم المشددتان تُنطقان بغنة مقدار حركتين.',
        ),
        arabic: 'إِنَّ ۝ ثُمَّ ۝ النَّاسِ',
      ),
      LessonStep(
        icon: Icons.light_mode_outlined,
        title: (en: 'Sun and moon letters', ar: 'اللام الشمسية والقمرية'),
        body: (
          en:
              'The lam of ال is silent before sun letters (الشَّمْس) and said before '
              'moon letters (الْقَمَر).',
          ar: 'لام «ال» تُدغم مع الحروف الشمسية (الشَّمْس) وتظهر مع القمرية (الْقَمَر).',
        ),
        arabic: 'وَالشَّمْسِ ۝ وَالْقَمَرِ',
      ),
      LessonStep(
        icon: Icons.fitness_center_rounded,
        title: (en: 'The lam in Allah', ar: 'لام لفظ الجلالة'),
        body: (
          en: 'Heavy after fatha or damma, light after kasra.',
          ar: 'تُفخَّم بعد الفتح والضم، وتُرقَّق بعد الكسر.',
        ),
        arabic: 'قَالَ اللَّهُ ۝ بِسْمِ اللَّهِ',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: (
          en: 'Which is a qalqalah letter?',
          ar: 'أيّها من حروف القلقلة؟',
        ),
        options: [(en: 'د', ar: 'د'), (en: 'س', ar: 'س'), (en: 'م', ar: 'م')],
        answer: 0,
      ),
      QuizQuestion(
        question: (
          en: 'Is the lam pronounced in الشَّمْس?',
          ar: 'هل تُنطق اللام في «الشَّمْس»؟',
        ),
        arabic: 'الشَّمْسِ',
        options: [
          (en: 'Yes — moon letter', ar: 'نعم — قمرية'),
          (en: 'No — sun letter', ar: 'لا — شمسية'),
        ],
        answer: 1,
      ),
      QuizQuestion(
        question: (
          en: 'The lam in بِسْمِ اللَّهِ is…',
          ar: 'اللام في «بِسْمِ اللَّهِ»…',
        ),
        arabic: 'بِسْمِ اللَّهِ',
        options: [(en: 'Heavy', ar: 'مفخمة'), (en: 'Light', ar: 'مرققة')],
        answer: 1,
        explain: (en: 'It comes after a kasra.', ar: 'لأنها بعد كسر.'),
      ),
      QuizQuestion(
        question: (
          en: 'How long is the ghunnah in إِنَّ?',
          ar: 'كم مقدار الغنة في «إِنَّ»؟',
        ),
        options: [
          (en: '2 counts', ar: 'حركتان'),
          (en: '4 counts', ar: '٤ حركات'),
          (en: '6 counts', ar: '٦ حركات'),
        ],
        answer: 0,
      ),
    ],
  ),
];
