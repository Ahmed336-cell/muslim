import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an https URL in the system browser.
///
/// Prefers the native `muslim/links` channel (always registered with our
/// implicit engine), then falls back to [url_launcher].
Future<bool> openExternalUrl(String url) async {
  const channel = MethodChannel('muslim/links');
  try {
    final ok = await channel.invokeMethod<bool>('open', url);
    if (ok == true) return true;
  } on MissingPluginException {
    // Older binary without the channel — try url_launcher.
  } on PlatformException {
    // Fall through.
  }

  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  for (final mode in [
    LaunchMode.externalApplication,
    LaunchMode.platformDefault,
    LaunchMode.inAppBrowserView,
  ]) {
    try {
      if (await launchUrl(uri, mode: mode)) return true;
    } catch (_) {
      continue;
    }
  }
  return false;
}
