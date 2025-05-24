import UIKit
import Flutter
import FirebaseCore
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // First, let Google Sign-In try to handle the URL
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    // Then let Flutter handle it (this is important)
    return super.application(app, open: url, options: options)
  }
}
