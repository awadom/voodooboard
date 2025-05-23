// app.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voodoo_board/utils/theme.dart';
import './ui/trending_board.dart';
import './ui/home_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final GoRouter router = GoRouter(
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TrendingBoardsPage(),
    ),
    GoRoute(
      path: '/:memberId',
      builder: (context, state) {
        final memberId = state.pathParameters['memberId']!;
        return VoodooBoardHomePage(name: memberId);
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
