import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voodoo_board/utils/theme.dart';
import './/ui/trending_board.dart'; // your TrendingBoardPage
import './/ui//message_panel.dart'; // your MessagePanel widget

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

// Define your router with go_router
final GoRouter router = GoRouter(
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => TrendingBoardsPage(),
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

class VoodooBoardApp extends StatelessWidget {
  const VoodooBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Voodoo Board',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
