import 'package:flutter/material.dart';

/// Text in both app languages.
typedef Tr = ({String en, String ar});

extension TrOf on Tr {
  String of(String language) => language == 'ar' ? ar : en;
}

class LessonStep {
  const LessonStep({
    required this.icon,
    required this.title,
    required this.body,
    this.arabic,
    this.translit,
    this.meaning,
    this.image,
  });

  final IconData icon;

  /// Illustration under assets/lessons/, shown instead of [icon].
  final String? image;
  final Tr title;
  final Tr body;

  /// What to say, in Arabic.
  final String? arabic;
  final String? translit;

  /// English meaning of [arabic].
  final String? meaning;
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    this.arabic,
    this.explain,
  });

  final Tr question;

  /// An example to judge, in Arabic.
  final String? arabic;
  final List<Tr> options;

  /// Index into [options].
  final int answer;
  final Tr? explain;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.steps,
    this.quiz = const [],
  });

  final String id;
  final IconData icon;
  final Tr title;
  final Tr subtitle;
  final List<LessonStep> steps;
  final List<QuizQuestion> quiz;
}

const wuduLesson = Lesson(
  id: 'wudu',
  icon: Icons.water_drop_outlined,
  title: (en: 'Wudu', ar: 'الوضوء'),
  subtitle: (en: 'Ablution, step by step', ar: 'الوضوء خطوة بخطوة'),
  steps: [
    LessonStep(
      icon: Icons.favorite_border_rounded,
      image: 'assets/lessons/wudu_intention.jpg',
      title: (en: 'Intention', ar: 'النية'),
      body: (
        en:
            'Intend in your heart to make wudu for Allah; no need to say it '
            'aloud. Then say Bismillah.',
        ar: 'انوِ بقلبك الوضوء لله، ولا يُشرع التلفظ بها. ثم قل: بسم الله.',
      ),
      arabic: 'بِسْمِ اللَّهِ',
      translit: 'Bismillah',
      meaning: 'In the name of Allah',
    ),
    LessonStep(
      icon: Icons.back_hand_outlined,
      image: 'assets/lessons/wudu_hands.jpg',
      title: (en: 'Hands', ar: 'الكفّان'),
      body: (
        en: 'Wash both hands up to the wrists three times, between the fingers.',
        ar: 'اغسل كفيك إلى الرسغين ثلاثًا، وخلّل بين الأصابع.',
      ),
    ),
    LessonStep(
      icon: Icons.water_rounded,
      image: 'assets/lessons/wudu_mouth.jpg',
      title: (en: 'Mouth and nose', ar: 'المضمضة والاستنشاق'),
      body: (
        en:
            'Take water in your right hand: rinse your mouth and draw water '
            'into your nose, then blow it out with your left hand. Three times.',
        ar: 'خذ الماء بيمينك فتمضمض واستنشق، ثم استنثر بيسارك. ثلاث مرات.',
      ),
    ),
    LessonStep(
      icon: Icons.face_outlined,
      image: 'assets/lessons/wudu_face.jpg',
      title: (en: 'Face', ar: 'الوجه'),
      body: (
        en:
            'Wash your whole face three times: from the hairline to under the '
            'chin, and from ear to ear.',
        ar:
            'اغسل وجهك ثلاثًا: من منابت شعر الرأس إلى أسفل اللحية، ومن الأذن '
            'إلى الأذن.',
      ),
    ),
    LessonStep(
      icon: Icons.front_hand_outlined,
      image: 'assets/lessons/wudu_arms.jpg',
      title: (en: 'Arms', ar: 'اليدان'),
      body: (
        en:
            'Wash the right arm from fingertips up to and including the elbow, '
            'three times, then the left.',
        ar: 'اغسل يدك اليمنى من أطراف الأصابع إلى المرفق مع المرفق ثلاثًا، ثم اليسرى.',
      ),
    ),
    LessonStep(
      icon: Icons.person_outline_rounded,
      image: 'assets/lessons/wudu_head.jpg',
      title: (en: 'Head', ar: 'مسح الرأس'),
      body: (
        en:
            'With wet hands, wipe your head once: from the front to the back '
            'of the neck, and back to the front.',
        ar: 'امسح رأسك مرة واحدة بيديك المبلولتين: من مقدمه إلى قفاه ثم ردّهما.',
      ),
    ),
    LessonStep(
      icon: Icons.hearing_outlined,
      image: 'assets/lessons/wudu_ears.jpg',
      title: (en: 'Ears', ar: 'الأذنان'),
      body: (
        en:
            'Wipe the ears once: index fingers inside, thumbs behind, with the '
            'water left from wiping the head.',
        ar: 'امسح أذنيك مرة: السبابتان في داخلهما والإبهامان خلفهما.',
      ),
    ),
    LessonStep(
      icon: Icons.directions_walk_rounded,
      image: 'assets/lessons/wudu_feet.jpg',
      title: (en: 'Feet', ar: 'القدمان'),
      body: (
        en:
            'Wash the right foot up to and including the ankle three times, '
            'between the toes, then the left.',
        ar: 'اغسل رجلك اليمنى إلى الكعبين مع الكعبين ثلاثًا، وخلّل الأصابع، ثم اليسرى.',
      ),
    ),
    LessonStep(
      icon: Icons.auto_awesome_outlined,
      image: 'assets/lessons/wudu_after.jpg',
      title: (en: 'After wudu', ar: 'بعد الوضوء'),
      body: (
        en:
            'Say the testimony. The eight gates of Paradise are opened for '
            'whoever says it. — Muslim',
        ar: 'قل الشهادتين؛ من قالها فُتحت له أبواب الجنة الثمانية. — مسلم',
      ),
      arabic:
          'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، '
          'وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
      translit:
          'Ashhadu an la ilaha illallahu wahdahu la sharika lah, wa ashhadu '
          'anna Muhammadan abduhu wa rasuluh',
      meaning:
          'I bear witness that there is no god but Allah alone, with no '
          'partner, and that Muhammad is His servant and messenger.',
    ),
    LessonStep(
      icon: Icons.do_not_disturb_on_outlined,
      title: (en: 'What breaks wudu', ar: 'نواقض الوضوء'),
      body: (
        en:
            'Using the toilet, passing wind, deep sleep, losing consciousness, '
            'and eating camel meat. Then make wudu again before praying.',
        ar:
            'الخارج من السبيلين، والنوم المستغرق، وزوال العقل، وأكل لحم الإبل. '
            'فتوضأ من جديد قبل الصلاة.',
      ),
    ),
  ],
  quiz: [
    QuizQuestion(
      question: (en: 'What do you wash first?', ar: 'ماذا تغسل أولًا؟'),
      options: [
        (en: 'Face', ar: 'الوجه'),
        (en: 'Hands', ar: 'الكفّين'),
        (en: 'Feet', ar: 'القدمين'),
      ],
      answer: 1,
    ),
    QuizQuestion(
      question: (
        en: 'How many times is the head wiped?',
        ar: 'كم مرة يُمسح الرأس؟',
      ),
      options: [
        (en: 'Once', ar: 'مرة'),
        (en: 'Twice', ar: 'مرتين'),
        (en: 'Three times', ar: 'ثلاث مرات'),
      ],
      answer: 0,
    ),
    QuizQuestion(
      question: (en: 'Arms are washed up to…', ar: 'تُغسل اليدان إلى…'),
      options: [
        (en: 'The wrists', ar: 'الرسغين'),
        (en: 'And including the elbows', ar: 'المرفقين مع المرفقين'),
        (en: 'The shoulders', ar: 'الكتفين'),
      ],
      answer: 1,
    ),
    QuizQuestion(
      question: (en: 'Which one breaks wudu?', ar: 'أيّها ينقض الوضوء؟'),
      options: [
        (en: 'Deep sleep', ar: 'النوم المستغرق'),
        (en: 'Drinking water', ar: 'شرب الماء'),
        (en: 'Reading Quran', ar: 'قراءة القرآن'),
      ],
      answer: 0,
    ),
  ],
);

const _fatiha =
    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ '
    'الرَّحْمَنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ '
    'نَسْتَعِينُ ۝ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝ صِرَاطَ الَّذِينَ أَنْعَمْتَ '
    'عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ';

const salahLesson = Lesson(
  id: 'salah',
  icon: Icons.mosque_outlined,
  title: (en: 'Salah', ar: 'الصلاة'),
  subtitle: (
    en: 'A two-rak\'ah prayer, start to end',
    ar: 'صلاة ركعتين من البداية للنهاية',
  ),
  steps: [
    LessonStep(
      icon: Icons.explore_outlined,
      image: 'assets/lessons/salah_qibla.jpg',
      title: (en: 'Face the qibla', ar: 'استقبال القبلة'),
      body: (
        en:
            'With wudu, stand facing the qibla and intend in your heart which '
            'prayer you are praying.',
        ar: 'وأنت على وضوء، قف مستقبلًا القبلة وانوِ بقلبك الصلاة التي تصليها.',
      ),
    ),
    LessonStep(
      icon: Icons.pan_tool_outlined,
      image: 'assets/lessons/salah_takbir.jpg',
      title: (en: 'Opening takbir', ar: 'تكبيرة الإحرام'),
      body: (
        en:
            'Raise your hands to your shoulders or ears and say Allahu akbar. '
            'Place your right hand over your left on your chest.',
        ar:
            'ارفع يديك حذو منكبيك أو أذنيك وقل: الله أكبر. ثم ضع يدك اليمنى على '
            'اليسرى على صدرك.',
      ),
      arabic: 'اللَّهُ أَكْبَرُ',
      translit: 'Allahu akbar',
      meaning: 'Allah is the Greatest',
    ),
    LessonStep(
      icon: Icons.menu_book_outlined,
      image: 'assets/lessons/salah_qiyam.jpg',
      title: (en: 'Opening dua', ar: 'دعاء الاستفتاح'),
      body: (
        en: 'Quietly, in the first rak\'ah only.',
        ar: 'سرًّا، في الركعة الأولى فقط.',
      ),
      arabic:
          'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى '
          'جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ',
      translit:
          'Subhanaka Allahumma wa bihamdik, wa tabarakasmuk, wa ta\'ala '
          'jadduk, wa la ilaha ghayruk',
      meaning:
          'Glory be to You, O Allah, and praise. Blessed is Your name, exalted '
          'is Your majesty, and there is no god but You.',
    ),
    LessonStep(
      icon: Icons.auto_stories_outlined,
      image: 'assets/lessons/salah_qiyam.jpg',
      title: (en: 'Al-Fatiha', ar: 'الفاتحة'),
      body: (
        en:
            'Seek refuge, then recite al-Fatiha, then any other surah, such '
            'as al-Ikhlas.',
        ar: 'استعذ بالله، ثم اقرأ الفاتحة، ثم ما تيسر من القرآن كسورة الإخلاص.',
      ),
      arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ ۝ $_fatiha',
      meaning:
          'In the name of Allah, the Most Merciful, the Most Kind. Praise be to '
          'Allah, Lord of the worlds… Guide us to the straight path.',
    ),
    LessonStep(
      icon: Icons.accessibility_new_rounded,
      image: 'assets/lessons/salah_ruku.jpg',
      title: (en: 'Bowing (ruku\')', ar: 'الركوع'),
      body: (
        en:
            'Say Allahu akbar and bow, hands on knees and back straight. Say '
            'three times:',
        ar: 'كبّر واركع، ويداك على ركبتيك وظهرك مستوٍ، وقل ثلاثًا:',
      ),
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translit: 'Subhana rabbiyal-\'azim',
      meaning: 'Glory be to my Lord, the Almighty',
    ),
    LessonStep(
      icon: Icons.accessibility_rounded,
      image: 'assets/lessons/salah_rising.jpg',
      title: (en: 'Rising', ar: 'الرفع من الركوع'),
      body: (
        en: 'Rise saying the first phrase; once standing, say the second.',
        ar: 'ارفع قائلًا الأولى، فإذا استويت قائمًا فقل الثانية.',
      ),
      arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ ۝ رَبَّنَا وَلَكَ الْحَمْدُ',
      translit: 'Sami\'allahu liman hamidah — Rabbana wa lakal-hamd',
      meaning: 'Allah hears whoever praises Him — Our Lord, to You is praise',
    ),
    LessonStep(
      icon: Icons.south_rounded,
      image: 'assets/lessons/salah_sujud.jpg',
      title: (en: 'Prostration (sujud)', ar: 'السجود'),
      body: (
        en:
            'Say Allahu akbar and prostrate on seven parts: forehead with nose, '
            'both palms, both knees and the toes of both feet. Say three times:',
        ar:
            'كبّر واسجد على سبعة أعضاء: الجبهة مع الأنف، والكفين، والركبتين، '
            'وأطراف القدمين، وقل ثلاثًا:',
      ),
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'Subhana rabbiyal-a\'la',
      meaning: 'Glory be to my Lord, the Most High',
    ),
    LessonStep(
      icon: Icons.airline_seat_legroom_normal_rounded,
      image: 'assets/lessons/salah_sitting.jpg',
      title: (en: 'Sitting', ar: 'الجلسة بين السجدتين'),
      body: (
        en:
            'Say Allahu akbar and sit up, then say the dua. Then make a second '
            'prostration like the first.',
        ar: 'كبّر واجلس وقل الدعاء، ثم اسجد السجدة الثانية كالأولى.',
      ),
      arabic: 'رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي',
      translit: 'Rabbighfir li, rabbighfir li',
      meaning: 'My Lord, forgive me',
    ),
    LessonStep(
      icon: Icons.replay_rounded,
      image: 'assets/lessons/salah_qiyam.jpg',
      title: (en: 'Second rak\'ah', ar: 'الركعة الثانية'),
      body: (
        en:
            'Stand saying Allahu akbar and repeat the same: al-Fatiha, a surah, '
            'ruku\', rising and two prostrations, without the opening dua.',
        ar:
            'قم مكبّرًا وكرر ما سبق: الفاتحة وسورة والركوع والرفع والسجدتين، '
            'دون دعاء الاستفتاح.',
      ),
    ),
    LessonStep(
      icon: Icons.chair_alt_outlined,
      image: 'assets/lessons/salah_tashahhud.jpg',
      title: (en: 'Tashahhud', ar: 'التشهد'),
      body: (
        en: 'After the second rak\'ah, sit and recite, pointing your right index finger:',
        ar: 'بعد الركعة الثانية اجلس واقرأ، مشيرًا بسبابتك اليمنى:',
      ),
      arabic:
          'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ '
          'أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا '
          'وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا '
          'اللَّهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
      meaning:
          'All greetings, prayers and good things are for Allah. Peace be on '
          'you, O Prophet, and Allah\'s mercy and blessings. Peace be on us and '
          'on the righteous servants of Allah. I bear witness that there is no '
          'god but Allah, and that Muhammad is His servant and messenger.',
    ),
    LessonStep(
      icon: Icons.star_outline_rounded,
      image: 'assets/lessons/salah_tashahhud.jpg',
      title: (en: 'Blessings on the Prophet ﷺ', ar: 'الصلاة الإبراهيمية'),
      body: (
        en: 'In the final sitting, continue with:',
        ar: 'في التشهد الأخير أكمل بـ:',
      ),
      arabic:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ '
          'عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، '
          'اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ '
          'عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      meaning:
          'O Allah, send prayers on Muhammad and his family as You sent prayers '
          'on Ibrahim and his family; You are Praised and Glorious. O Allah, '
          'bless Muhammad and his family as You blessed Ibrahim and his family.',
    ),
    LessonStep(
      icon: Icons.waving_hand_outlined,
      image: 'assets/lessons/salah_taslim.jpg',
      title: (en: 'Ending (taslim)', ar: 'التسليم'),
      body: (
        en: 'Turn your head to the right and say it, then to the left.',
        ar: 'التفت عن يمينك وقلها، ثم عن يسارك.',
      ),
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      translit: 'Assalamu \'alaykum wa rahmatullah',
      meaning: 'Peace and the mercy of Allah be upon you',
    ),
    LessonStep(
      icon: Icons.format_list_numbered_rounded,
      title: (en: 'Three and four rak\'ahs', ar: 'الثلاثية والرباعية'),
      body: (
        en:
            'Fajr 2, Dhuhr 4, Asr 4, Maghrib 3, Isha 4. In longer prayers, after '
            'the first tashahhud stand up with Allahu akbar, and in the '
            'remaining rak\'ahs recite al-Fatiha only. End with the full '
            'tashahhud and taslim.',
        ar:
            'الفجر ٢، الظهر ٤، العصر ٤، المغرب ٣، العشاء ٤. في الصلاة الأطول، '
            'بعد التشهد الأول قم مكبّرًا، واقرأ في الركعات الباقية الفاتحة فقط، '
            'ثم التشهد الأخير والتسليم.',
      ),
    ),
  ],
  quiz: [
    QuizQuestion(
      question: (en: 'What do you say in ruku\'?', ar: 'ماذا تقول في الركوع؟'),
      options: [
        (en: 'Subhana rabbiyal-a\'la', ar: 'سبحان ربي الأعلى'),
        (en: 'Subhana rabbiyal-\'azim', ar: 'سبحان ربي العظيم'),
        (en: 'Rabbighfir li', ar: 'رب اغفر لي'),
      ],
      answer: 1,
    ),
    QuizQuestion(
      question: (
        en: 'How many rak\'ahs is Maghrib?',
        ar: 'كم ركعة صلاة المغرب؟',
      ),
      options: [(en: '2', ar: '٢'), (en: '3', ar: '٣'), (en: '4', ar: '٤')],
      answer: 1,
    ),
    QuizQuestion(
      question: (
        en: 'How many parts touch the ground in sujud?',
        ar: 'على كم عضو يكون السجود؟',
      ),
      options: [(en: '5', ar: '٥'), (en: '7', ar: '٧'), (en: '9', ar: '٩')],
      answer: 1,
    ),
    QuizQuestion(
      question: (
        en: 'Which surah is recited in every rak\'ah?',
        ar: 'ما السورة التي تُقرأ في كل ركعة؟',
      ),
      options: [
        (en: 'Al-Ikhlas', ar: 'الإخلاص'),
        (en: 'Al-Fatiha', ar: 'الفاتحة'),
        (en: 'An-Nas', ar: 'الناس'),
      ],
      answer: 1,
    ),
    QuizQuestion(
      question: (en: 'How does the prayer end?', ar: 'بماذا تُختم الصلاة؟'),
      options: [
        (en: 'Takbir', ar: 'التكبير'),
        (en: 'Taslim to the right, then left', ar: 'التسليم يمينًا ثم يسارًا'),
        (en: 'Raising the hands', ar: 'رفع اليدين'),
      ],
      answer: 1,
    ),
  ],
);
