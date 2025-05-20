import 'package:flutter/material.dart';
import 'package:voodoo_board/utils/theme.dart'; // Import your theme file
import 'routes.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class VoodooBoardApp extends StatelessWidget {
  const VoodooBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voodoo Board',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // Use your custom light theme
      darkTheme: AppTheme.dark, // Use your custom dark theme
      themeMode: ThemeMode.system, // Auto-switch based on system settings
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [routeObserver],
    );
  }
}
