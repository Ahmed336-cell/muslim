import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Mixpanel. No-op until [init] gets a token, so tests and local builds
/// without `MIXPANEL_TOKEN` stay quiet.
class Analytics {
  static Mixpanel? _mixpanel;

  static Future<void> init(String token) async {
    if (token.isEmpty) return;
    try {
      final info = await PackageInfo.fromPlatform().timeout(
        const Duration(seconds: 2),
      );
      _mixpanel = await Mixpanel.init(
        token,
        trackAutomaticEvents: true,
        superProperties: {
          'language': PlatformDispatcher.instance.locale.languageCode,
          'app_version': info.version,
          'build': kReleaseMode ? 'release' : 'debug',
        },
      ).timeout(const Duration(seconds: 3));
      unawaited(_mixpanel?.track('App Opened'));
    } catch (error, stack) {
      debugPrint('Mixpanel init failed: $error\n$stack');
    }
  }

  /// `Feature Opened` with a stable [name] from [Feature].
  static void feature(String name) {
    final mixpanel = _mixpanel;
    if (mixpanel == null || name.isEmpty) return;
    unawaited(mixpanel.track('Feature Opened', properties: {'feature': name}));
  }
}
