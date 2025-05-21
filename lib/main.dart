import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voodoo_board/app.dart';
import 'firebase_options.dart'; // From the Firebase CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    FirebaseAuth.instance.getRedirectResult().then((result) {
      if (result.user != null) {
        // Do something if needed after redirect login
      }
    });
  }
  runApp(const VoodooBoardApp());
}
