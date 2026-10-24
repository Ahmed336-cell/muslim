import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Play application id. Used when the in-app update sheet cannot open.
const playPackage = 'com.elmoahm.sabeelk';

/// Store-update switch.
///
/// [force] asks Google Play for an immediate update whenever a newer
/// version is published, and blocks the app if that sheet is dismissed.
/// Set it to false to turn the check off.
///
/// [minBuild] is the lowest Play `versionCode` allowed to run. Leave it
/// at 0 to follow Play only. Raise it in a Shorebird patch to push older
/// installs to the store before Play's update API sees the new release.
abstract final class UpdatePolicy {
  static const force = true;
  static const minBuild = 0;
}

bool installedBuildIsTooOld({
  required bool force,
  required int minBuild,
  required int installedBuild,
}) => force && minBuild > 0 && installedBuild < minBuild;

bool playUpdateIsRequired({
  required bool force,
  required UpdateAvailability availability,
}) =>
    force &&
    (availability == UpdateAvailability.updateAvailable ||
        availability == UpdateAvailability.developerTriggeredUpdateInProgress);

/// True when this Android install must update before it can be used.
Future<bool> isUpdateRequired() async {
  if (kIsWeb || !Platform.isAndroid || !UpdatePolicy.force) return false;
  if (UpdatePolicy.minBuild > 0) {
    final info = await PackageInfo.fromPlatform();
    final build = int.tryParse(info.buildNumber) ?? 0;
    if (installedBuildIsTooOld(
      force: UpdatePolicy.force,
      minBuild: UpdatePolicy.minBuild,
      installedBuild: build,
    )) {
      return true;
    }
  }
  try {
    final info = await InAppUpdate.checkForUpdate();
    return playUpdateIsRequired(
      force: UpdatePolicy.force,
      availability: info.updateAvailability,
    );
  } catch (_) {
    // Sideload, debug, or a build still in Play review: no update to offer.
    return false;
  }
}

/// Opens Play's full-screen update. True when the user accepts it.
Future<bool> startImmediateUpdate() async {
  if (kIsWeb || !Platform.isAndroid) return false;
  try {
    final info = await InAppUpdate.checkForUpdate();
    if (!playUpdateIsRequired(
      force: true,
      availability: info.updateAvailability,
    )) {
      return false;
    }
    if (!info.immediateUpdateAllowed) return false;
    final result = await InAppUpdate.performImmediateUpdate();
    return result == AppUpdateResult.success;
  } catch (_) {
    return false;
  }
}

Future<void> openPlayListing() async {
  try {
    await InAppReview.instance.openStoreListing();
    return;
  } catch (_) {}
  final uri = Uri.parse(
    'https://play.google.com/store/apps/details?id=$playPackage',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
