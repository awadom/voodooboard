import 'package:flutter/material.dart';
import 'message_panel.dart';
import 'user_directory_page.dart';

class VoodooBoardHomePage extends StatefulWidget {
  final String name;

  const VoodooBoardHomePage({super.key, required this.name});

  @override
  State<VoodooBoardHomePage> createState() => _VoodooBoardHomePageState();
}

class _VoodooBoardHomePageState extends State<VoodooBoardHomePage> {
  final List<String> members = [];
  late String selectedMember;
  bool showFabMenu = false;

  @override
  void initState() {
    super.initState();
    selectedMember = widget.name;
    members.add(widget.name);
  }

  void pinMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pin message tapped')),
    );
  }

  Future<void> addUser() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add User'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && !members.contains(newName)) {
                Navigator.of(context).pop();
                setState(() {
                  members.add(newName);
                  selectedMember = newName;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(newName.isEmpty
                        ? 'Name cannot be empty.'
                        : 'Name already exists.'),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> openUserDirectory() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const UserDirectoryPage(),
      ),
    );

    if (selected != null) {
      // Handle the selected user (if you implement returning it from UserDirectoryPage)
      print('Selected user: $selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔮 $selectedMember'),
        centerTitle: true,
      ),
      body: MessagePanel(
        memberId: selectedMember,
      ),
      floatingActionButton: Stack(
        children: [
          // Pin Button
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                heroTag: 'pinBtn',
                onPressed: pinMessage,
                tooltip: 'Pin Message',
                child: const Icon(Icons.push_pin),
              ),
            ),
          ),

          // Expandable FAB
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showFabMenu) ...[
                  FloatingActionButton.extended(
                    heroTag: 'addUserBtn',
                    onPressed: addUser,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add User'),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.extended(
                    heroTag: 'searchUserBtn',
                    onPressed: openUserDirectory,
                    icon: const Icon(Icons.search),
                    label: const Text('Users'),
                  ),
                  const SizedBox(height: 10),
                ],
                FloatingActionButton(
                  heroTag: 'toggleFab',
                  onPressed: () {
                    setState(() => showFabMenu = !showFabMenu);
                  },
                  tooltip: 'More',
                  child: Icon(showFabMenu ? Icons.close : Icons.menu),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
