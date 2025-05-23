import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import '../ui/message_panel.dart'; // Import your MessagePanel widget here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VoodooBoardApp());
}

class VoodooBoardApp extends StatelessWidget {
  const VoodooBoardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MessagePanel(memberId: null),
        ),
        GoRoute(
          path: '/:memberId',
          builder: (context, state) {
            final memberId = state.pathParameters['memberId']!;
            return MessagePanel(memberId: memberId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'VoodooBoard',
      routerConfig: router,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
      ),
    );
  }
}
