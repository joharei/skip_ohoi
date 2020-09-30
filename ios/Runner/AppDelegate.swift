import UIKit
import Flutter
import flt_worker
import path_provider

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    FltWorkerPlugin.registerPlugins = { registry in
        if let registrar = registry?.registrar(forPlugin: "FLTPathProviderPlugin") {
            FLTPathProviderPlugin.register(with: registrar)
        }
        if let registrar = registry?.registrar(forPlugin: "FlutterLocalNotificationsPlugin") {
            FlutterLocalNotificationsPlugin.register(with: registrar)
        }
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
