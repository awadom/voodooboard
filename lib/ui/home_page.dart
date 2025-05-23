import 'package:flutter/material.dart';
import 'message_panel.dart';
import '../ui/custom_nav_bar.dart';

class VoodooBoardHomePage extends StatefulWidget {
  final String name;
  const VoodooBoardHomePage({super.key, required this.name});

  @override
  State<VoodooBoardHomePage> createState() => _VoodooBoardHomePageState();
}

class _VoodooBoardHomePageState extends State<VoodooBoardHomePage> {
  late String selectedMember;
  final List<String> members = [];

  @override
  void initState() {
    super.initState();
    selectedMember = widget.name.toLowerCase();
    members.add(selectedMember);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔮 $selectedMember'),
        centerTitle: true,
      ),
      body: MessagePanel(memberId: selectedMember),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
