# weather_flutter

A weather appliocation written in Flutter with native code implementations

## Project structure

The project is seperated into three parts.
The first Section is the main.dart which contains the bottom sheet code

The Second Section is for the Home/Dashboard Section which send an API to fetch the weather in cairo and show it
the code for the API is :

```dart
Future<WeatherInfo>
  fetchWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=Cairo&APPID=10c282d58ffba0b3020e6a2d52ef85e8',
    );

    final response = await http.get(
      url,
    );

    if (response.statusCode == 200) {
      final data = json.decode(
        response.body,
      );
      return WeatherInfo.fromJson(data);
    } else {
      throw Exception(
        'Failed to load weather data',
      );
    }
  }
  ```

it also has a section which asks the user for his feedback then sends it to the native part and it notifies the user of the success of that action in the bottom using a SnackBar as follows: 

```dart
Future<void> sendFeedbackToNative(
    String feedback,
  ) async {
    try {
      await platform.invokeMethod(
        'sendFeedback',
        {'feedback': feedback},
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Feedback sent successfully!',
          ),
        ),
      );
    } on PlatformException catch (e) {
      debugPrint(
        'Failed to send feedback: ${e.message}',
      );
    }
  }
```

the third Section is the Profile Section which shows the user hardcoded data that is fetched from the native code as well as the feedback using methodchannel as follows:

```dart
Future<void>
  fetchUserProfile() async {
    try {
      final Map<dynamic, dynamic>
      result = await platform
          .invokeMethod(
            'getUserProfile',
          );
      setState(() {
        name = result['name'];
        email = result['email'];
        imageUrl = result['imageUrl'];
        feedback = result['feedback'];
        _showFeedbackDialog();
      });
    } on PlatformException catch (e) {
      debugPrint(
        "Failed to get user profile: '${e.message}'.",
      );
    }
  }
  ```

## IOS Section

Here is the code to pass the ios data from native to Flutter.

  ```swift
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
```


## Android Section

Here is the code to pass the android data from native to Flutter.
 


```kotlin
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
```
