import 'package:flutter/material.dart';

import 'lessons.dart';

/// The Arabic alphabet: letter, name in each language and a word starting
/// with it.
const arabicLetters = <(String, Tr, String)>[
  ('ا', (en: 'Alif', ar: 'ألف'), 'أَسَد'),
  ('ب', (en: 'Baa', ar: 'باء'), 'بَيْت'),
  ('ت', (en: 'Taa', ar: 'تاء'), 'تُفَّاح'),
  ('ث', (en: 'Thaa', ar: 'ثاء'), 'ثَعْلَب'),
  ('ج', (en: 'Jeem', ar: 'جيم'), 'جَمَل'),
  ('ح', (en: 'Haa', ar: 'حاء'), 'حِصَان'),
  ('خ', (en: 'Khaa', ar: 'خاء'), 'خُبْز'),
  ('د', (en: 'Daal', ar: 'دال'), 'دُبّ'),
  ('ذ', (en: 'Dhaal', ar: 'ذال'), 'ذَهَب'),
  ('ر', (en: 'Raa', ar: 'راء'), 'رُمَّان'),
  ('ز', (en: 'Zay', ar: 'زاي'), 'زَرَافَة'),
  ('س', (en: 'Seen', ar: 'سين'), 'سَمَكَة'),
  ('ش', (en: 'Sheen', ar: 'شين'), 'شَمْس'),
  ('ص', (en: 'Saad', ar: 'صاد'), 'صَقْر'),
  ('ض', (en: 'Daad', ar: 'ضاد'), 'ضِفْدَع'),
  ('ط', (en: 'Taa (heavy)', ar: 'طاء'), 'طَائِرَة'),
  ('ظ', (en: 'Dhaa (heavy)', ar: 'ظاء'), 'ظَرْف'),
  ('ع', (en: 'Ayn', ar: 'عين'), 'عِنَب'),
  ('غ', (en: 'Ghayn', ar: 'غين'), 'غَيْمَة'),
  ('ف', (en: 'Faa', ar: 'فاء'), 'فِيل'),
  ('ق', (en: 'Qaaf', ar: 'قاف'), 'قَمَر'),
  ('ك', (en: 'Kaaf', ar: 'كاف'), 'كِتَاب'),
  ('ل', (en: 'Laam', ar: 'لام'), 'لَيْمُون'),
  ('م', (en: 'Meem', ar: 'ميم'), 'مَسْجِد'),
  ('ن', (en: 'Noon', ar: 'نون'), 'نَجْمَة'),
  ('ه', (en: 'Haa (soft)', ar: 'هاء'), 'هِلَال'),
  ('و', (en: 'Waw', ar: 'واو'), 'وَرْدَة'),
  ('ي', (en: 'Yaa', ar: 'ياء'), 'يَد'),
];

/// Short surahs to memorise first, in teaching order.
const kidsSurahs = [1, 112, 113, 114, 108, 103, 110, 109, 111, 106, 105, 107];

const kidsDuas = Lesson(
  id: 'kids_duas',
  icon: Icons.child_care_rounded,
  title: (en: 'Little duas', ar: 'أدعية صغيرة'),
  subtitle: (en: 'Duas for every day', ar: 'أدعية كل يوم'),
  steps: [
    LessonStep(
      icon: Icons.restaurant_rounded,
      title: (en: 'Before eating', ar: 'قبل الطعام'),
      body: (
        en: 'Say Bismillah and eat with your right hand.',
        ar: 'قل: بسم الله، وكُل بيمينك.',
      ),
      arabic: 'بِسْمِ اللَّهِ',
      translit: 'Bismillah',
      meaning: 'In the name of Allah',
    ),
    LessonStep(
      icon: Icons.check_circle_outline_rounded,
      title: (en: 'After eating', ar: 'بعد الطعام'),
      body: (en: 'Thank Allah for the food.', ar: 'احمد الله على الطعام.'),
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      translit:
          'Alhamdu lillahil-ladhi at\'amani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah',
      meaning:
          'Praise be to Allah who fed me this and provided it for me without any power of my own.',
    ),
    LessonStep(
      icon: Icons.bedtime_outlined,
      title: (en: 'Going to sleep', ar: 'عند النوم'),
      body: (
        en: 'Lie on your right side and say:',
        ar: 'نم على جنبك الأيمن وقل:',
      ),
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      translit: 'Bismika Allahumma amutu wa ahya',
      meaning: 'In Your name, O Allah, I die and I live.',
    ),
    LessonStep(
      icon: Icons.wb_sunny_outlined,
      title: (en: 'Waking up', ar: 'عند الاستيقاظ'),
      body: (en: 'Start your day thanking Allah.', ar: 'ابدأ يومك بحمد الله.'),
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      translit:
          'Alhamdu lillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur',
      meaning:
          'Praise be to Allah who gave us life after He made us die, and to Him is the return.',
    ),
    LessonStep(
      icon: Icons.door_front_door_outlined,
      title: (en: 'Leaving home', ar: 'عند الخروج من البيت'),
      body: (
        en: 'Trust Allah when you go out.',
        ar: 'توكّل على الله عند خروجك.',
      ),
      arabic:
          'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      translit:
          'Bismillah, tawakkaltu \'alallah, wa la hawla wa la quwwata illa billah',
      meaning:
          'In the name of Allah, I trust in Allah, and there is no power or strength except with Allah.',
    ),
    LessonStep(
      icon: Icons.family_restroom_rounded,
      title: (en: 'For your parents', ar: 'للوالدين'),
      body: (
        en: 'Ask Allah to have mercy on them.',
        ar: 'ادعُ الله أن يرحمهما.',
      ),
      arabic: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      translit: 'Rabbir-hamhuma kama rabbayani saghira',
      meaning:
          'My Lord, have mercy on them as they raised me when I was small.',
    ),
    LessonStep(
      icon: Icons.sentiment_satisfied_alt_rounded,
      title: (en: 'When you sneeze', ar: 'عند العطاس'),
      body: (
        en: 'Say Alhamdulillah. Whoever hears you says Yarhamukallah.',
        ar: 'قل: الحمد لله، ويقول من سمعك: يرحمك الله.',
      ),
      arabic: 'الْحَمْدُ لِلَّهِ ۝ يَرْحَمُكَ اللَّهُ',
      translit: 'Alhamdulillah — Yarhamukallah',
      meaning: 'Praise be to Allah — May Allah have mercy on you',
    ),
  ],
  quiz: [
    QuizQuestion(
      question: (
        en: 'What do we say before eating?',
        ar: 'ماذا نقول قبل الطعام؟',
      ),
      options: [
        (en: 'Bismillah', ar: 'بسم الله'),
        (en: 'Assalamu alaykum', ar: 'السلام عليكم'),
        (en: 'Allahu akbar', ar: 'الله أكبر'),
      ],
      answer: 0,
    ),
    QuizQuestion(
      question: (en: 'Which side do we sleep on?', ar: 'على أي جنب ننام؟'),
      options: [(en: 'Right', ar: 'الأيمن'), (en: 'Left', ar: 'الأيسر')],
      answer: 0,
    ),
    QuizQuestion(
      question: (
        en: 'When someone sneezes and says Alhamdulillah, we say…',
        ar: 'إذا عطس أحد وحمد الله نقول…',
      ),
      options: [
        (en: 'Bismillah', ar: 'بسم الله'),
        (en: 'Yarhamukallah', ar: 'يرحمك الله'),
        (en: 'Subhanallah', ar: 'سبحان الله'),
      ],
      answer: 1,
    ),
  ],
);

/// A quiz on the letters, built from [arabicLetters].
Lesson lettersLesson() {
  const picks = [1, 4, 7, 11, 17, 20, 23, 24];
  return Lesson(
    id: 'kids_letters',
    icon: Icons.abc_rounded,
    title: (en: 'Letters quiz', ar: 'اختبار الحروف'),
    subtitle: (en: 'Name the letter', ar: 'ما اسم الحرف؟'),
    steps: const [
      LessonStep(
        icon: Icons.abc_rounded,
        title: (en: 'Ready?', ar: 'هل أنت مستعد؟'),
        body: (
          en: 'Look at each letter and pick its name.',
          ar: 'انظر إلى كل حرف واختر اسمه.',
        ),
      ),
    ],
    quiz: [
      for (final (n, i) in picks.indexed)
        QuizQuestion(
          question: (en: 'Which letter is this?', ar: 'ما هذا الحرف؟'),
          arabic: arabicLetters[i].$1,
          options: [
            for (final j in [i, (i + 3 + n) % 28, (i + 9 + n) % 28]..sort())
              arabicLetters[j].$2,
          ],
          answer: ([i, (i + 3 + n) % 28, (i + 9 + n) % 28]..sort()).indexOf(i),
        ),
    ],
  );
}
