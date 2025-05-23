import 'package:flutter/material.dart';
import 'package:voodoo_board/utils/theme.dart';
import '/ui/main_shell.dart';

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
      home: const MainShellPage(),
      // No more onGenerateRoute or initialRoute needed
    );
  }
}
