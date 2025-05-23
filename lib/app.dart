import 'package:flutter/material.dart';
import 'package:voodoo_board/utils/theme.dart';
import 'routes.dart'; // Import your custom routes

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class VoodooBoardApp extends StatelessWidget {
  const VoodooBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voodoo Board',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      navigatorObservers: [routeObserver],
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
