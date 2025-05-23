import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Handle the redirect result to complete sign-in
  if (kIsWeb) {
    try {
      final result = await FirebaseAuth.instance.getRedirectResult();
      if (result.user != null) {
        // User successfully signed in with redirect
        print('User signed in after redirect: ${result.user!.email}');
      }
    } catch (e) {
      print('Error during redirect sign-in: $e');
    }
  }

  runApp(const VoodooBoardApp());
}
