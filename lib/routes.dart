// lib/routes.dart

import 'package:flutter/material.dart';
import 'ui/trending_board.dart';
import 'ui/home_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String nameBoard = '/nameBoard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        // No arguments needed now, TrendingBoardsPage fetches data internally
        return MaterialPageRoute(
          builder: (_) => const TrendingBoardsPage(),
        );
      case nameBoard:
        final name = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VoodooBoardHomePage(name: name),
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
