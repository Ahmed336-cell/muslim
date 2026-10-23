package dev.flutter.plugins.integration_test;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Release builds drop the integration_test Android library (dev dependency)
 * but GeneratedPluginRegistrant still constructs this class. Debug and profile
 * use the real plugin; this source set is release-only.
 */
public final class IntegrationTestPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {}

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
