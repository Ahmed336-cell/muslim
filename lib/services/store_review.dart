import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'play_update.dart';

const _launchesKey = 'review_launches';
const _askedAtKey = 'review_asked_at';
const _minLaunches = 5;
const _cooldown = Duration(days: 120);

/// Play in-app review. The sheet is shown by Google, and only sometimes.
class StoreReview {
  static bool get supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Counts launches. After [_minLaunches], asks once, then again after
  /// [_cooldown] if Play allows the sheet.
  static Future<void> maybeAsk() async {
    if (!supported) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final launches = (prefs.getInt(_launchesKey) ?? 0) + 1;
      await prefs.setInt(_launchesKey, launches);

      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;

      final asked = prefs.getInt(_askedAtKey);
      final cooled =
          asked == null ||
          DateTime.now().difference(
                DateTime.fromMillisecondsSinceEpoch(asked),
              ) >
              _cooldown;
      if (launches < _minLaunches || !cooled) return;

      await prefs.setInt(_askedAtKey, DateTime.now().millisecondsSinceEpoch);
      await review.requestReview();
    } catch (_) {}
  }

  /// Always opens the store listing. Use this for the button in More.
  static Future<void> openListing() async {
    if (!supported) return;
    try {
      if (Platform.isAndroid) {
        await openPlayListing();
        return;
      }
      await InAppReview.instance.openStoreListing();
    } catch (_) {}
  }
}
