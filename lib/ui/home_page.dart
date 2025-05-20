import 'package:flutter/material.dart';
import 'message_panel.dart';
import 'user_directory_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes.dart';

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

  void _showSearchOrAddNameDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Enter a name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => _submitName(nameController),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitName(nameController),
            child: const Text('Go to Board'),
          ),
        ],
      ),
    );
  }

  void _submitName(TextEditingController controller) async {
    final name = controller.text.trim().toLowerCase(); // Force lowercase
    if (name.isNotEmpty) {
      try {
        final membersCollection =
            FirebaseFirestore.instance.collection('members');

        final existingMember = await membersCollection.doc(name).get();
        if (!existingMember.exists) {
          await membersCollection.doc(name).set({});
          print('Added $name to Firestore.');
        } else {
          print('$name already exists.');
        }

        Navigator.of(context).pop();
        _navigateToBoard(context, name);
      } catch (e) {
        print('Error adding $name: $e');
      }
    }
  }

  void _navigateToBoard(BuildContext context, String name) {
    Navigator.pushNamed(
      context,
      AppRoutes.nameBoard,
      arguments: name,
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

  Widget _buildMiniFab({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return SizedBox(
      width: 72,
      height: 72,
      child: FloatingActionButton(
        heroTag: heroTag,
        tooltip: tooltip,
        onPressed: onPressed,
        child: Icon(icon, size: 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🔮 $selectedMember'), centerTitle: true),
      body: MessagePanel(memberId: selectedMember),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (showFabMenu) ...[
            // Top of toggle
            Positioned(
              bottom: 35 + 72 + 10,
              right: 0,
              child: _buildMiniFab(
                icon: Icons.person_add,
                tooltip: 'Add User',
                onPressed: _showSearchOrAddNameDialog,
                heroTag: 'addUserBtn',
              ),
            ),
            // Left of toggle
            Positioned(
              bottom: 35,
              right: 72 + 10,
              child: _buildMiniFab(
                icon: Icons.search,
                tooltip: 'Search Users',
                onPressed: openUserDirectory,
                heroTag: 'searchUserBtn',
              ),
            ),
            // Diagonal up-left (example extra button)
            // Positioned(
            //   bottom: 35 + 72 + 10,
            //   right: 72 + 10,
            //   child: _buildMiniFab(
            //     icon: Icons.settings,
            //     tooltip: 'Settings',
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Settings clicked')),
            //       );
            //     },
            //     heroTag: 'settingsBtn',
            //   ),
            // ),
            // You can add more buttons in a grid pattern like this:
            // (e.g., 2nd row left, 2nd row above, diagonal, etc.)
          ],
          // Toggle FAB always present
          Positioned(
            bottom: 35,
            right: 0,
            child: _buildMiniFab(
              icon: showFabMenu ? Icons.close : Icons.menu,
              tooltip: 'Toggle Menu',
              onPressed: () => setState(() => showFabMenu = !showFabMenu),
              heroTag: 'toggleFab',
            ),
          ),
        ],
      ),
    );
  }
}
