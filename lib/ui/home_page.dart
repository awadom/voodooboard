import 'package:flutter/material.dart';
import 'message_panel.dart';
import 'user_directory_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    selectedMember = widget.name.toLowerCase();
    members.add(selectedMember);
  }

  Future<void> addUser() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add User'),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter name')),
        actions: [
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim().toLowerCase();

              if (newName.isEmpty) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name cannot be empty.')),
                );
                return;
              }

              if (members.contains(newName)) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name already exists.')),
                );
                return;
              }

              try {
                final membersCollection =
                    FirebaseFirestore.instance.collection('members');
                final existingMember =
                    await membersCollection.doc(newName).get();

                if (!existingMember.exists) {
                  await membersCollection.doc(newName).set({});
                  print('Added $newName to Firestore.');
                } else {
                  print('$newName already exists in Firestore.');
                }

                Navigator.of(context).pop();
                setState(() {
                  members.add(newName);
                  selectedMember = newName;
                });
              } catch (e) {
                print('Error adding $newName: $e');
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding user: $e')),
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
      MaterialPageRoute(builder: (_) => const UserDirectoryPage()),
    );
    if (selected != null) {
      print('Selected user: $selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🔮 $selectedMember'), centerTitle: true),
      body: MessagePanel(memberId: selectedMember),
      floatingActionButton: Stack(
        children: [
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
                  onPressed: () => setState(() => showFabMenu = !showFabMenu),
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
