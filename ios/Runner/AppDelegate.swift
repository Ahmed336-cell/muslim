import ActivityKit
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets prayer reminders show while the app is in the foreground.
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LiveActivity") {
      let channel = FlutterMethodChannel(
        name: "muslim/live_activity", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler(LiveActivityChannel.handle)
    }
  }
}

// Must match the copy in MuslimWidgets/MuslimWidgets.swift field for field.
struct PrayerActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var name: String
    var clock: String
    var at: Date
    var since: Date
  }

  var label: String
  var now: String
  var city: String
  var rtl: Bool
}

/// Starts, updates and ends the next-prayer Live Activity for
/// lib/services/live_activity.dart.
enum LiveActivityChannel {
  static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      result(false)
      return
    }
    switch call.method {
    case "show":
      guard let a = call.arguments as? [String: Any],
        let name = a["name"] as? String,
        let clock = a["clock"] as? String,
        let at = a["at"] as? Double,
        let since = a["since"] as? Double
      else {
        result(false)
        return
      }
      let attributes = PrayerActivityAttributes(
        label: a["label"] as? String ?? "",
        now: a["now"] as? String ?? "",
        city: a["city"] as? String ?? "",
        rtl: a["rtl"] as? Bool ?? false)
      let end = Date(timeIntervalSince1970: at / 1000)
      let state = PrayerActivityAttributes.ContentState(
        name: name, clock: clock, at: end,
        since: Date(timeIntervalSince1970: since / 1000))
      Task {
        result(await show(attributes, state, staleAt: end))
      }
    case "end":
      Task {
        await endAll()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  @available(iOS 16.2, *)
  private static func show(
    _ attributes: PrayerActivityAttributes,
    _ state: PrayerActivityAttributes.ContentState,
    staleAt: Date
  ) async -> Bool {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
    let content = ActivityContent(state: state, staleDate: staleAt)
    let running = Activity<PrayerActivityAttributes>.activities
    if let current = running.first,
      current.attributes.label == attributes.label,
      current.attributes.city == attributes.city,
      current.attributes.rtl == attributes.rtl
    {
      await current.update(content)
      return true
    }
    await endAll()
    do {
      _ = try Activity.request(attributes: attributes, content: content)
      return true
    } catch {
      return false
    }
  }

  @available(iOS 16.2, *)
  private static func endAll() async {
    for activity in Activity<PrayerActivityAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
  }
}
