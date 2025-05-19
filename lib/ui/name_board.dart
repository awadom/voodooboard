// lib/ui/name_board.dart

import 'package:flutter/material.dart';

class NameBoardPage extends StatelessWidget {
  final String name;

  const NameBoardPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$name\'s Board')),
      body: Center(
        child: Text(
          'Messages for $name will go here!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
