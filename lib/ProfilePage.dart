import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage
    extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      ProfilePageState();
}

class ProfilePageState
    extends State<ProfilePage> {
  static const platform = MethodChannel(
    'com.example.user/profile',
  );

  String name = '';
  String email = '';
  String imageUrl = '';
  String feedback = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

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

  void _showFeedbackDialog() {
    if (feedback.isEmpty) {
      // No feedback, don't show anything
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'User Feedback',
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (
                  context,
                  index,
                ) {
                  return ListTile(
                    title: Text(
                      feedback,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(
                          context,
                        ).pop(),
                child: const Text(
                  'Close',
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body:
          name.isEmpty
              ? const Center(
                child:
                    CircularProgressIndicator(),
              )
              : Padding(
                padding:
                    const EdgeInsets.all(
                      16.0,
                    ),
                child: Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(
                              imageUrl,
                            ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(email),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        feedback,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
