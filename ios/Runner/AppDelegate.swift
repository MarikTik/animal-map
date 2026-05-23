import Flutter
#if canImport(GoogleMaps)
import GoogleMaps
#endif
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard
      let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String,
      !apiKey.isEmpty
    else {
      fatalError("Missing GOOGLE_MAPS_API_KEY. Define it in ios/Flutter/MapsApiKey.xcconfig.")
    }

#if canImport(GoogleMaps)
    GMSServices.provideAPIKey(apiKey)
#else
    NSLog("GoogleMaps SDK not available at compile time. Skipping GMSServices.provideAPIKey(_:) call.")
#endif
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
