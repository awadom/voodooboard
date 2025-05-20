import 'package:flutter/material.dart';
import 'message_panel.dart';
import 'user_directory_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes.dart';
import 'package:flutter/services.dart';

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

  void _showVoodooDialog() async {
    const hexMessage =
        'You have been summoned! 👁️\n\nClick the link below or paste this message somewhere for someone to discover your name:\n\n'
        'https://voodooboard.netlify.app/';

    await Clipboard.setData(ClipboardData(text: hexMessage));

    final TextEditingController hexController =
        TextEditingController(text: hexMessage);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voodoo Summoning Ready!'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🔮 The summoning message has been copied to your clipboard!\n\n'
                'Go ahead and paste it somewhere — watch the magic happen as they come to their board page!\n\n'
                'Message:',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hexController,
                maxLines: null,
                readOnly: true,
                showCursor: true,
                enableInteractiveSelection: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: hexController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Hex message copied to clipboard!')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
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
            // Diagonal up-left for voodoo button
            Positioned(
              bottom: 35 + 72 + 10,
              right: 72 + 10,
              child: SizedBox(
                width: 72,
                height: 72,
                child: FloatingActionButton(
                  heroTag: 'voodooBtn',
                  onPressed: _showVoodooDialog,
                  tooltip: 'Summon',
                  backgroundColor: Theme.of(context)
                      .floatingActionButtonTheme
                      .backgroundColor,
                  child: const Text(
                    '🪄',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ),
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
