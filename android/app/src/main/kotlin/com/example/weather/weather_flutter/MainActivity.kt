package com.example.weather.weather_flutter

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.user/profile"
    private String feedback = ""

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getUserProfile") {
                val userData = mapOf(
                    "name" to "Mohamed Ghonem Android",
                    "email" to "mohamady@gmail.com",
                    "imageUrl" to "https://via.placeholder.com/150",
                    "feedback" to feedback
                )
                result.success(userData)
            } else if (call.method == "getUserProfile") {
                val feedbackFromFlutter = call.argument<String>("feedback")
                if (feedbackFromFlutter != null) {
                    feedback = feedbackFromFlutter
                    result.success("Feedback received successfully")
                } else {
                    result.error("INVALID_ARGUMENT", "Feedback is null", null)
                }
            }else {
                result.notImplemented()
            }
        }
    }
}
