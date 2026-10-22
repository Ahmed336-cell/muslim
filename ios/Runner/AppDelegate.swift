import ActivityKit
import CoreLocation
import CoreMotion
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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "Links") {
      FlutterMethodChannel(name: "muslim/links", binaryMessenger: registrar.messenger())
        .setMethodCallHandler(LinksChannel.handle)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "Heading") {
      FlutterEventChannel(name: "sabeelak/heading", binaryMessenger: registrar.messenger())
        .setStreamHandler(HeadingStream.shared)
      FlutterEventChannel(
        name: "sabeelak/camera_heading", binaryMessenger: registrar.messenger()
      )
      .setStreamHandler(CameraHeadingStream())
    }
  }
}

/// Opens https links in Safari — reliable when url_launcher's pigeon channel is down.
enum LinksChannel {
  static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "open":
      guard let raw = call.arguments as? String, let url = URL(string: raw) else {
        result(false)
        return
      }
      UIApplication.shared.open(url, options: [:]) { result($0) }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

/// Where the back camera points, as [degrees from north, accuracy], for the
/// AR Qibla view. CLHeading follows the top edge, which is meaningless when the
/// phone is held upright, so this reads the device attitude instead.
final class CameraHeadingStream: NSObject, FlutterStreamHandler {
  private let motion = CMMotionManager()

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    guard motion.isDeviceMotionAvailable else {
      events(nil)
      return nil
    }
    let frames = CMMotionManager.availableAttitudeReferenceFrames()
    let status = CLLocationManager().authorizationStatus
    let located = status == .authorizedWhenInUse || status == .authorizedAlways
    let frame: CMAttitudeReferenceFrame =
      located && frames.contains(.xTrueNorthZVertical)
      ? .xTrueNorthZVertical : .xMagneticNorthZVertical
    motion.deviceMotionUpdateInterval = 1.0 / 30
    motion.startDeviceMotionUpdates(using: frame, to: .main) { data, _ in
      guard let data else { return }
      // Rows are the device axes in the reference frame (X north, Y west,
      // Z up); the camera looks along the device's -Z.
      let m = data.attitude.rotationMatrix
      var degrees = atan2(m.m32, -m.m31) * 180 / .pi
      degrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
      let accuracy: Double =
        switch data.magneticField.accuracy {
        case .high: 10
        case .medium: 20
        case .low: 40
        default: -1
        }
      events([degrees, accuracy])
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motion.stopDeviceMotionUpdates()
    return nil
  }
}

/// Compass heading for lib/screens/qibla_screen.dart as [degrees, accuracy].
/// True north needs location updates on the same manager; without location
/// access it falls back to magnetic north instead of reporting -1.
final class HeadingStream: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
  static let shared = HeadingStream()

  private let manager = CLLocationManager()
  private var sink: FlutterEventSink?

  override init() {
    super.init()
    manager.delegate = self
    manager.headingFilter = 0.5
    manager.desiredAccuracy = kCLLocationAccuracyKilometer
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    guard CLLocationManager.headingAvailable() else {
      events(nil)
      return nil
    }
    startLocationIfAllowed()
    manager.startUpdatingHeading()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    manager.stopUpdatingHeading()
    manager.stopUpdatingLocation()
    sink = nil
    return nil
  }

  private func startLocationIfAllowed() {
    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways: manager.startUpdatingLocation()
    default: break
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if sink != nil { startLocationIfAllowed() }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
    guard heading.headingAccuracy >= 0 else { return }
    var degrees = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    switch scene?.interfaceOrientation {
    case .landscapeLeft: degrees -= 90
    case .landscapeRight: degrees += 90
    case .portraitUpsideDown: degrees += 180
    default: break
    }
    sink?([(degrees + 360).truncatingRemainder(dividingBy: 360), heading.headingAccuracy])
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
