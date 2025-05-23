import 'package:flutter/material.dart';
import 'message_panel.dart';

class VoodooBoardHomePage extends StatelessWidget {
  final String name;

  const VoodooBoardHomePage({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final selectedMember = name.toLowerCase();

    return Column(
      children: [
        Material(
          elevation: 4,
          child: AppBar(
            title: Text('🔮 $selectedMember'),
            centerTitle: true,
            automaticallyImplyLeading: false, // Avoids back button
          ),
        ),
        Expanded(
          child: MessagePanel(memberId: selectedMember),
        ),
      ],
    );
  }
}
