// ui/home_page.dart

import 'package:flutter/material.dart';
import 'message_panel.dart';
import 'main_shell.dart'; // for ShellPage enum

class VoodooBoardHomePage extends StatefulWidget {
  final String name;
  final void Function(ShellPage page, {String? name})? onNavigate;

  const VoodooBoardHomePage({
    super.key,
    required this.name,
    this.onNavigate,
  });

  @override
  State<VoodooBoardHomePage> createState() => _VoodooBoardHomePageState();
}

class _VoodooBoardHomePageState extends State<VoodooBoardHomePage> {
  late String selectedMember;

  @override
  void initState() {
    super.initState();
    selectedMember = widget.name.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔮 $selectedMember'),
        centerTitle: true,
      ),
      body: MessagePanel(memberId: selectedMember),
      // Remove this to avoid duplicate nav bars:
      // bottomNavigationBar: CustomNavBar(
      //   onNavigate: (page, {name}) {
      //     if (widget.onNavigate != null) {
      //       widget.onNavigate!(page, name: name);
      //     }
      //   },
      //   currentPage: ShellPage.nameBoard,
      // ),
    );
  }
}
