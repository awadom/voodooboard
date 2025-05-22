import 'package:flutter/material.dart';
import 'ui/trending_board.dart';
import 'ui/home_page.dart';
import 'ui/login.dart'; // <-- Add this line

class AppRoutes {
  static const String home = '/';
  static const String nameBoard = '/nameBoard';
  static const String login = '/login'; // <-- Add this line

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const TrendingBoardsPage(),
        );
      case nameBoard:
        final name = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VoodooBoardHomePage(name: name),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(), // <-- Navigate to LoginPage
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
