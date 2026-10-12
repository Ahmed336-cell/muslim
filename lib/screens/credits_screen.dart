import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/reciter_photos.dart';
import '../theme.dart';
import '../widgets/common.dart';

typedef _Credit = ({
  String titleEn,
  String titleAr,
  String bodyEn,
  String bodyAr,
  String? licence,
});

const _credits = <_Credit>[
  (
    titleEn: 'Quran text',
    titleAr: 'نص القرآن الكريم',
    bodyEn:
        'Tanzil Quran Text (Uthmani, Simple), tanzil.net. Used without '
        'changes; verified copies of the text are bundled in the app.',
    bodyAr:
        'نص التنزيل (عثماني ومبسّط) من tanzil.net، دون أي تعديل، مضمّن '
        'في التطبيق.',
    licence: 'CC BY 3.0',
  ),
  (
    titleEn: 'Tafsir and translations',
    titleAr: 'التفسير والترجمات',
    bodyEn: 'alquran.cloud and quran.com (Tafsir Ibn Kathir).',
    bodyAr: 'alquran.cloud وquran.com (تفسير ابن كثير).',
    licence: null,
  ),
  (
    titleEn: 'Recitations',
    titleAr: 'التلاوات',
    bodyEn:
        'Full surahs from mp3quran.net; verse-by-verse audio from '
        'cdn.islamic.network.',
    bodyAr:
        'السور كاملة من mp3quran.net، والتلاوة آيةً آيةً من cdn.islamic.network.',
    licence: null,
  ),
  (
    titleEn: 'Hisn al-Muslim',
    titleAr: 'حصن المسلم',
    bodyEn: "Sa'id ibn Wahf al-Qahtani, from hisnmuslim.com, with its audio.",
    bodyAr: 'سعيد بن وهف القحطاني، من hisnmuslim.com مع التسجيلات الصوتية.',
    licence: null,
  ),
  (
    titleEn: 'Duas, names of Allah, ruqyah, fasting and nisab',
    titleAr: 'الأدعية وأسماء الله والرقية والصيام والنصاب',
    bodyEn: 'islamicapi.com.',
    bodyAr: 'islamicapi.com.',
    licence: null,
  ),
  (
    titleEn: 'Prayer times',
    titleAr: 'مواقيت الصلاة',
    bodyEn:
        'Calculated on the device with the open-source Adhan library '
        '(batoulapps); Hijri dates follow the Umm al-Qura calendar.',
    bodyAr:
        'تُحسب على الجهاز بمكتبة Adhan مفتوحة المصدر، والتاريخ الهجري '
        'وفق تقويم أم القرى.',
    licence: 'MIT',
  ),
  (
    titleEn: 'Adhan recordings',
    titleAr: 'تسجيلات الأذان',
    bodyEn: 'aladhan.com and islamcan.com.',
    bodyAr: 'aladhan.com وislamcan.com.',
    licence: null,
  ),
  (
    titleEn: 'Background sounds',
    titleAr: 'الأصوات الخلفية',
    bodyEn: 'Google sound library.',
    bodyAr: 'مكتبة أصوات Google.',
    licence: 'CC BY 4.0',
  ),
];

/// Where the app's content comes from, with licences.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const CreditsScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final photos = reciterPhotoCredits.values.toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.credits)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          for (final c in _credits) ...[
            AppCard(
              child: _Entry(
                title: ar ? c.titleAr : c.titleEn,
                body: ar ? c.bodyAr : c.bodyEn,
                licence: c.licence,
              ),
            ),
            const SizedBox(height: 10),
          ],
          AppCard(
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: _Entry(title: l.creditsPhotos, body: l.creditsPhotosSub),
                children: [
                  for (final (author, licence) in photos)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(child: Text(author, style: Fonts.body(13))),
                          Text(
                            licence,
                            style: Fonts.body(12, color: Palette.inkSoft),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            onTap: () =>
                showLicensePage(context: context, applicationName: l.appName),
            child: Row(
              children: [
                Expanded(
                  child: Text(l.openSourceLicences, style: Fonts.body(15)),
                ),
                Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.title, required this.body, this.licence});

  final String title;
  final String body;
  final String? licence;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Fonts.body(15, weight: FontWeight.w600),
              ),
            ),
            if (licence case final licence?)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Palette.green.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  licence,
                  style: Fonts.body(11.5, color: Palette.green),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(body, style: Fonts.body(13.5, color: Palette.inkSoft)),
      ],
    );
  }
}

/// What the app stores and sends; shown in-app and suitable for the store
/// listing.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const PrivacyScreen());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final sections = [
      (l.privacyNoAccountTitle, l.privacyNoAccount),
      (l.privacyLocationTitle, l.privacyLocation),
      (l.privacyNetworkTitle, l.privacyNetwork),
      (l.privacyNotificationsTitle, l.privacyNotifications),
      (l.privacyContactTitle, l.privacyContact),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        children: [
          for (final (title, body) in sections) ...[
            AppCard(
              child: _Entry(title: title, body: body),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
