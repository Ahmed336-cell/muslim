import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Adhan recordings for prayer notifications. Android plays the full adhan
/// from res/raw; iOS caps notification sounds at 30 s, so it gets a clip
/// from assets/adhan copied into Library/Sounds.
enum AdhanVoice {
  makkah(
    'الحرم المكي',
    'Masjid al-Haram, Makkah',
    'https://www.islamcan.com/audio/adhan/azan1.mp3',
  ),
  madinah(
    'المسجد النبوي',
    'Masjid an-Nabawi, Madinah',
    'https://www.islamcan.com/audio/adhan/azan2.mp3',
  ),
  alafasy(
    'مشاري العفاسي',
    'Mishary Alafasy',
    'https://cdn.aladhan.com/audio/adhans/a9.mp3',
  ),
  nafees(
    'أحمد النفيس',
    'Ahmad al-Nafees',
    'https://cdn.aladhan.com/audio/adhans/a1.mp3',
  ),
  zahrani(
    'منصور الزهراني',
    'Mansour Al-Zahrani',
    'https://cdn.aladhan.com/audio/adhans/a11-mansour-al-zahrani.mp3',
  ),
  ozcan(
    'مصطفى أوزجان',
    'Mustafa Özcan, Türkiye',
    'https://cdn.aladhan.com/audio/adhans/a2.mp3',
  );

  const AdhanVoice(this.arabic, this.english, this.url);

  final String arabic;
  final String english;

  /// Full recording, streamed for previews.
  final String url;

  String label(String language) => language == 'ar' ? arabic : english;

  /// res/raw resource and iOS sound file name.
  String get sound => 'adhan_$name';

  /// Android channel sounds can't change, so each voice gets a channel.
  String get channel => 'adhan_$name';

  static AdhanVoice? byName(String? name) => values.asNameMap()[name];
}

/// Copies the iOS clip where notifications can find it; once per voice.
Future<void> installIosSound(AdhanVoice voice) async {
  if (!Platform.isIOS) return;
  final dir = Directory('${(await getLibraryDirectory()).path}/Sounds');
  final file = File('${dir.path}/${voice.sound}.caf');
  if (await file.exists()) return;
  await dir.create(recursive: true);
  final data = await rootBundle.load('assets/adhan/${voice.sound}.caf');
  await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
}
