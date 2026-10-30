import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var engine: FlutterEngine?
  private var started = false

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    // The storyboard view loads before the implicit engine has a shell.
    // On a 120Hz phone that dies in VSyncClient. Run the engine first.
    if !started {
      started = true
      let engine = FlutterEngine(name: "sabeelak")
      self.engine = engine
      engine.run()
      AppDelegate.register(engine: engine)
    }
    if window == nil {
      let window = UIWindow(windowScene: windowScene)
      if let engine {
        window.rootViewController = FlutterViewController(
          engine: engine, nibName: nil, bundle: nil)
      }
      self.window = window
      window.makeKeyAndVisible()
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
}
