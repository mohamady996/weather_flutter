import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    var feedback: String = ""

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let channel = FlutterMethodChannel(
            name: "com.example.user/profile",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { call, result in
            if call.method == "getUserProfile" {
                let userData: [String: Any] = [
                    "name": "Mohamed Ghonem IOS",
                    "email": "Mohamady@gmail.com",
                    "imageUrl": "https://via.placeholder.com/150",
                    "feedback": self.feedback
                ]
                result(userData)
            } else if (call.method == "sendFeedback") {
                if let args = call.arguments as? [String: Any],
                   let feedbackFromFlutter = args["feedback"] as? String {
                    self.feedback = feedbackFromFlutter
                    result("Feedback received successfully")
                }else{
                    result(FlutterMethodNotImplemented)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
