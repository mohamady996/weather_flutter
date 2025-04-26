import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherInfo {
  final String city;
  final double temperature;
  final String condition;

  WeatherInfo({
    required this.city,
    required this.temperature,
    required this.condition,
  });

  factory WeatherInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final tempKelvin =
        json['main']['temp'] as num;
    final condition =
        json['weather'][0]['main'];
    final city = json['name'];

    return WeatherInfo(
      city: city,
      temperature:
          tempKelvin -
          273.15, // Convert from Kelvin to Celsius
      condition: condition,
    );
  }
}

class DashboardPage
    extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends State<DashboardPage> {
  static const platform = MethodChannel(
    'com.example.user/profile',
  );

  late Future<WeatherInfo>
  _weatherFuture;
  final TextEditingController
  _feedbackController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _weatherFuture = fetchWeather();
  }

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

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder<WeatherInfo>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot
                  .connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          } else if (snapshot
              .hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          } else if (snapshot.hasData) {
            final weather =
                snapshot.data!;
            return Padding(
              padding:
                  const EdgeInsets.all(
                    16.0,
                  ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    "City: ${weather.city}",
                    style:
                        const TextStyle(
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Temperature: ${weather.temperature}°C",
                    style:
                        const TextStyle(
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Condition: ${weather.condition}",
                    style:
                        const TextStyle(
                          fontSize: 22,
                        ),
                  ),
                  const Divider(
                    height: 32,
                  ),
                  TextField(
                    controller:
                        _feedbackController,
                    decoration: const InputDecoration(
                      labelText:
                          'Enter your feedback',
                      border:
                          OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final feedback =
                          _feedbackController
                              .text;
                      if (feedback
                          .isNotEmpty) {
                        sendFeedbackToNative(
                          feedback,
                        );
                      }
                    },
                    child: const Text(
                      'Send Feedback',
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text(
                "No data available",
              ),
            );
          }
        },
      ),
    );
  }
}
