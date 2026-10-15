import 'package:flutter/material.dart';

import 'lessons.dart';

const _talbiyah =
    'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، '
    'إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ';
const _talbiyahTranslit =
    'Labbayk Allahumma labbayk, labbayka la sharika laka labbayk, innal-hamda '
    'wan-ni\'mata laka wal-mulk, la sharika lak';
const _talbiyahMeaning =
    'Here I am, O Allah, here I am. Here I am, You have no partner, here I '
    'am. All praise, blessings and dominion are Yours. You have no partner.';

const _ihram = 'assets/lessons/hajj_ihram.jpg';
const _tawaf = 'assets/lessons/hajj_tawaf.jpg';
const _sai = 'assets/lessons/hajj_sai.jpg';
const _halq = 'assets/lessons/hajj_halq.jpg';

const umrahLesson = Lesson(
  id: 'umrah',
  icon: Icons.mosque_rounded,
  title: (en: 'Umrah', ar: 'العمرة'),
  subtitle: (
    en: 'The lesser pilgrimage, step by step',
    ar: 'العمرة خطوة بخطوة',
  ),
  steps: [
    LessonStep(
      icon: Icons.checkroom_outlined,
      image: _ihram,
      title: (en: 'Ihram at the miqat', ar: 'الإحرام من الميقات'),
      body: (
        en:
            'Before the miqat, bathe, wear perfume on the body only, and put on '
            'two white unstitched sheets (women wear normal modest clothes '
            'without niqab or gloves). At the miqat, intend Umrah and say:',
        ar:
            'قبل الميقات اغتسل وتطيّب في بدنك، والبس إزارًا ورداءً أبيضين '
            '(وتلبس المرأة ثيابها الساترة بلا نقاب ولا قفازين). ومن الميقات انوِ '
            'العمرة وقل:',
      ),
      arabic: 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً',
      translit: 'Labbayk Allahumma \'umrah',
      meaning: 'Here I am, O Allah, for Umrah',
    ),
    LessonStep(
      icon: Icons.record_voice_over_outlined,
      image: _ihram,
      title: (en: 'Talbiyah', ar: 'التلبية'),
      body: (
        en:
            'Repeat the talbiyah often until you reach the Kaaba (men aloud, '
            'women quietly). Avoid what ihram forbids: cutting hair or nails, '
            'perfume, hunting and marital relations.',
        ar:
            'أكثر من التلبية حتى تصل إلى الكعبة (يجهر بها الرجال وتُسرّ بها '
            'النساء). واجتنب محظورات الإحرام: قص الشعر والأظافر، والطيب، والصيد، '
            'والجماع.',
      ),
      arabic: _talbiyah,
      translit: _talbiyahTranslit,
      meaning: _talbiyahMeaning,
    ),
    LessonStep(
      icon: Icons.sync_rounded,
      image: _tawaf,
      title: (en: 'Tawaf', ar: 'الطواف'),
      body: (
        en:
            'With wudu, start at the Black Stone: touch or point to it saying '
            'Bismillah, Allahu akbar. Circle the Kaaba seven times with it on '
            'your left. Men uncover the right shoulder and walk briskly in the '
            'first three rounds. Between the Yemeni corner and the Stone say:',
        ar:
            'وأنت على وضوء ابدأ من الحجر الأسود: استلمه أو أشر إليه قائلًا: بسم '
            'الله، الله أكبر. وطُف سبعة أشواط والكعبة عن يسارك. ويكشف الرجل كتفه '
            'الأيمن ويُسرع في الأشواط الثلاثة الأولى. وبين الركن اليماني والحجر '
            'قل:',
      ),
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً '
          'وَقِنَا عَذَابَ النَّارِ',
      translit:
          'Rabbana atina fid-dunya hasanah, wa fil-akhirati hasanah, wa qina '
          '\'adhaban-nar',
      meaning:
          'Our Lord, give us good in this world and good in the Hereafter, and '
          'save us from the punishment of the Fire.',
    ),
    LessonStep(
      icon: Icons.water_drop_outlined,
      image: 'assets/lessons/hajj_maqam.jpg',
      title: (en: 'Two rak\'ahs and Zamzam', ar: 'ركعتا الطواف وزمزم'),
      body: (
        en:
            'Cover your shoulder and pray two short rak\'ahs behind Maqam '
            'Ibrahim if you can, or anywhere in the mosque: al-Kafirun then '
            'al-Ikhlas. Then drink Zamzam water and make dua.',
        ar:
            'غطِّ كتفك وصلِّ ركعتين خفيفتين خلف مقام إبراهيم إن تيسّر وإلا ففي '
            'أي مكان من المسجد: بالكافرون ثم الإخلاص. ثم اشرب من ماء زمزم وادعُ.',
      ),
      arabic: 'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى',
      meaning: 'And take the station of Ibrahim as a place of prayer.',
    ),
    LessonStep(
      icon: Icons.swap_horiz_rounded,
      image: _sai,
      title: (en: 'Sa\'i', ar: 'السعي'),
      body: (
        en:
            'Climb Safa, face the Kaaba, praise Allah and make dua. Walk to '
            'Marwa (men hurry between the green lights) and do the same there. '
            'Safa to Marwa is one lap; finish seven laps at Marwa.',
        ar:
            'اصعد الصفا واستقبل الكعبة واحمد الله وادعُ، ثم امشِ إلى المروة '
            '(ويُسرع الرجل بين العلمين الأخضرين) وافعل عليها مثل ذلك. من الصفا إلى '
            'المروة شوط، وتنتهي الأشواط السبعة عند المروة.',
      ),
      arabic: 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ',
      meaning: 'Indeed, Safa and Marwa are among the symbols of Allah.',
    ),
    LessonStep(
      icon: Icons.content_cut_rounded,
      image: _halq,
      title: (en: 'Shave or trim', ar: 'الحلق أو التقصير'),
      body: (
        en:
            'Men shave the head (better) or trim it all over; women cut a '
            'fingertip\'s length from their hair. Your Umrah is complete and '
            'the ihram restrictions are lifted.',
        ar:
            'يحلق الرجل رأسه (وهو أفضل) أو يقصّر من جميعه، وتقصّر المرأة من '
            'شعرها قدر أنملة. وبهذا تمت عمرتك وحللت من إحرامك.',
      ),
    ),
  ],
  quiz: [
    QuizQuestion(
      question: (
        en: 'In tawaf, the Kaaba is on your…',
        ar: 'في الطواف تكون الكعبة عن…',
      ),
      options: [
        (en: 'Right', ar: 'يمينك'),
        (en: 'Left', ar: 'يسارك'),
        (en: 'Behind you', ar: 'خلفك'),
      ],
      answer: 1,
    ),
    QuizQuestion(
      question: (en: 'Where does sa\'i start?', ar: 'من أين يبدأ السعي؟'),
      options: [
        (en: 'Marwa', ar: 'المروة'),
        (en: 'Safa', ar: 'الصفا'),
        (en: 'The Black Stone', ar: 'الحجر الأسود'),
      ],
      answer: 1,
    ),
    QuizQuestion(
      question: (en: 'How many rounds of tawaf?', ar: 'كم شوطًا في الطواف؟'),
      options: [(en: '3', ar: '٣'), (en: '7', ar: '٧'), (en: '10', ar: '١٠')],
      answer: 1,
    ),
    QuizQuestion(
      question: (en: 'What ends the Umrah?', ar: 'بماذا تنتهي العمرة؟'),
      options: [
        (en: 'Drinking Zamzam', ar: 'شرب زمزم'),
        (en: 'Shaving or trimming the hair', ar: 'الحلق أو التقصير'),
        (en: 'The talbiyah', ar: 'التلبية'),
      ],
      answer: 1,
    ),
  ],
);

const hajjLesson = Lesson(
  id: 'hajj',
  icon: Icons.landscape_outlined,
  title: (en: 'Hajj', ar: 'الحج'),
  subtitle: (en: 'Hajj tamattu\', day by day', ar: 'حج التمتع يومًا بيوم'),
  steps: [
    LessonStep(
      icon: Icons.mosque_rounded,
      image: _tawaf,
      title: (en: 'Umrah first', ar: 'العمرة أولًا'),
      body: (
        en:
            'In the Hajj months, arrive and perform a full Umrah (see the Umrah '
            'lesson), then leave ihram and stay in Makkah until the 8th of '
            'Dhul-Hijjah.',
        ar:
            'في أشهر الحج أدِّ عمرة كاملة (راجع درس العمرة)، ثم تحلّل وابقَ في '
            'مكة حتى اليوم الثامن من ذي الحجة.',
      ),
    ),
    LessonStep(
      icon: Icons.holiday_village_outlined,
      image: 'assets/lessons/hajj_mina.jpg',
      title: (en: '8th: Mina', ar: 'الثامن: منى'),
      body: (
        en:
            'Day of Tarwiyah. Enter ihram for Hajj from where you are, go to '
            'Mina and pray Dhuhr, Asr, Maghrib, Isha and Fajr there, shortening '
            'the four-rak\'ah prayers without combining.',
        ar:
            'يوم التروية. أحرم بالحج من مكانك، واذهب إلى منى وصلِّ بها الظهر '
            'والعصر والمغرب والعشاء والفجر، قصرًا بلا جمع.',
      ),
      arabic: 'لَبَّيْكَ اللَّهُمَّ حَجًّا',
      translit: 'Labbayk Allahumma hajjan',
      meaning: 'Here I am, O Allah, for Hajj',
    ),
    LessonStep(
      icon: Icons.wb_sunny_outlined,
      image: 'assets/lessons/hajj_arafah.jpg',
      title: (en: '9th: Arafah', ar: 'التاسع: عرفة'),
      body: (
        en:
            'The greatest pillar of Hajj. After sunrise go to Arafah, pray '
            'Dhuhr and Asr shortened and combined, then spend the day in dua, '
            'facing the qibla, until sunset. The best dua is:',
        ar:
            'أعظم أركان الحج. بعد الشروق اذهب إلى عرفة، وصلِّ الظهر والعصر قصرًا '
            'وجمعًا، ثم تفرّغ للدعاء مستقبلًا القبلة حتى غروب الشمس. وخير الدعاء:',
      ),
      arabic:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ '
          'وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      translit:
          'La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamd, '
          'wa huwa \'ala kulli shay\'in qadir',
      meaning:
          'None has the right to be worshipped but Allah alone, without '
          'partner. His is the dominion and the praise, and He has power over '
          'all things.',
    ),
    LessonStep(
      icon: Icons.nights_stay_outlined,
      image: 'assets/lessons/hajj_muzdalifah.jpg',
      title: (en: 'Night at Muzdalifah', ar: 'المبيت بمزدلفة'),
      body: (
        en:
            'After sunset go calmly to Muzdalifah. Pray Maghrib and Isha '
            'combined, Isha shortened, and sleep there. Pray Fajr, remember '
            'Allah until it is bright, and pick up small pebbles.',
        ar:
            'بعد الغروب انصرف بسكينة إلى مزدلفة، وصلِّ المغرب والعشاء جمعًا مع '
            'قصر العشاء، وبِت بها. ثم صلِّ الفجر واذكر الله حتى الإسفار، والتقط '
            'حصيات صغيرة.',
      ),
    ),
    LessonStep(
      icon: Icons.scatter_plot_outlined,
      image: 'assets/lessons/hajj_jamarat.jpg',
      title: (en: '10th: Jamrat al-Aqabah', ar: 'العاشر: جمرة العقبة'),
      body: (
        en:
            'Eid day. Stop the talbiyah and throw seven pebbles, one by one, at '
            'the large Jamrah only, saying Allahu akbar with each.',
        ar:
            'يوم العيد. اقطع التلبية وارمِ جمرة العقبة الكبرى وحدها بسبع حصيات '
            'متعاقبات، تكبّر مع كل حصاة.',
      ),
      arabic: 'اللَّهُ أَكْبَرُ',
      translit: 'Allahu akbar',
      meaning: 'Allah is the Greatest',
    ),
    LessonStep(
      icon: Icons.volunteer_activism_outlined,
      image: 'assets/lessons/hajj_hady.jpg',
      title: (en: 'Sacrifice', ar: 'الهدي'),
      body: (
        en:
            'Pilgrims doing tamattu\' offer a sacrifice (usually through an '
            'official coupon), eat from it and give to the poor. Whoever '
            'can\'t, fasts three days in Hajj and seven at home.',
        ar:
            'يذبح المتمتع هديه (غالبًا عبر صكوك الهدي الرسمية)، ويأكل منه ويتصدق. '
            'ومن لم يجد صام ثلاثة أيام في الحج وسبعة إذا رجع.',
      ),
    ),
    LessonStep(
      icon: Icons.content_cut_rounded,
      image: _halq,
      title: (en: 'Shave or trim', ar: 'الحلق أو التقصير'),
      body: (
        en:
            'Shave or trim as in Umrah. Now everything ihram forbade is allowed '
            'again except marital relations. Wear normal clothes.',
        ar:
            'احلق أو قصّر كما في العمرة، فيحلّ لك كل ما حرم بالإحرام إلا الجماع. '
            'والبس ثيابك المعتادة.',
      ),
    ),
    LessonStep(
      icon: Icons.sync_rounded,
      image: _tawaf,
      title: (en: 'Tawaf al-Ifadah and sa\'i', ar: 'طواف الإفاضة والسعي'),
      body: (
        en:
            'Go to Makkah for Tawaf al-Ifadah, a pillar of Hajj, then the sa\'i '
            'of Hajj. After it, everything is allowed. It may be delayed to the '
            'days after Eid.',
        ar:
            'انزل إلى مكة لطواف الإفاضة وهو ركن، ثم سعي الحج. وبعده يحلّ لك كل '
            'شيء. ويجوز تأخيره إلى ما بعد يوم العيد.',
      ),
    ),
    LessonStep(
      icon: Icons.calendar_view_week_outlined,
      image: 'assets/lessons/hajj_jamarat.jpg',
      title: (en: '11th–13th: Days of Tashriq', ar: 'أيام التشريق'),
      body: (
        en:
            'Spend the nights in Mina. Each day after noon, stone all three '
            'Jamarat with seven pebbles each: the small, the middle, then the '
            'large, making dua after the first two. You may leave on the 12th '
            'before sunset.',
        ar:
            'بِت ليالي التشريق بمنى، وارمِ كل يوم بعد الزوال الجمرات الثلاث بسبع '
            'حصيات لكل منها: الصغرى ثم الوسطى ثم الكبرى، وادعُ بعد الأوليين. ولك '
            'أن تتعجّل في اليوم الثاني عشر قبل الغروب.',
      ),
    ),
    LessonStep(
      icon: Icons.flight_takeoff_rounded,
      image: 'assets/lessons/hajj_wada.jpg',
      title: (en: 'Farewell tawaf', ar: 'طواف الوداع'),
      body: (
        en:
            'Before leaving Makkah, make a final tawaf of seven rounds with no '
            'sa\'i. Women in menses are excused. May Allah accept your Hajj.',
        ar:
            'قبل مغادرة مكة طُف طواف الوداع سبعة أشواط بلا سعي، ويسقط عن الحائض. '
            'تقبّل الله حجك.',
      ),
    ),
  ],
  quiz: [
    QuizQuestion(
      question: (
        en: 'Which is the greatest pillar of Hajj?',
        ar: 'ما أعظم أركان الحج؟',
      ),
      options: [
        (en: 'Standing at Arafah', ar: 'الوقوف بعرفة'),
        (en: 'Night at Mina', ar: 'المبيت بمنى'),
        (en: 'Farewell tawaf', ar: 'طواف الوداع'),
      ],
      answer: 0,
    ),
    QuizQuestion(
      question: (
        en: 'Which Jamrah is stoned on Eid day?',
        ar: 'أي جمرة تُرمى يوم العيد؟',
      ),
      options: [
        (en: 'The small one', ar: 'الصغرى'),
        (en: 'All three', ar: 'الثلاث'),
        (en: 'Jamrat al-Aqabah only', ar: 'جمرة العقبة فقط'),
      ],
      answer: 2,
    ),
    QuizQuestion(
      question: (
        en: 'How many pebbles at each Jamrah?',
        ar: 'كم حصاة لكل جمرة؟',
      ),
      options: [(en: '5', ar: '٥'), (en: '7', ar: '٧'), (en: '9', ar: '٩')],
      answer: 1,
    ),
    QuizQuestion(
      question: (
        en: 'Where do pilgrims sleep after Arafah?',
        ar: 'أين يبيت الحاج بعد عرفة؟',
      ),
      options: [
        (en: 'Arafah', ar: 'عرفة'),
        (en: 'Muzdalifah', ar: 'مزدلفة'),
        (en: 'Makkah', ar: 'مكة'),
      ],
      answer: 1,
    ),
  ],
);
