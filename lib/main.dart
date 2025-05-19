import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voodoo_board/app.dart';
import 'firebase_options.dart'; // From the Firebase CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VoodooBoardApp());
}
