import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../ui/profile.dart';
import '../ui/user_directory_page.dart';
import 'main_shell.dart'; // for ShellPage enum

class CustomNavBar extends StatefulWidget {
  final void Function(ShellPage page, {String? name}) onNavigate;
  final ShellPage currentPage;

  const CustomNavBar({
    super.key,
    required this.onNavigate,
    required this.currentPage,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  bool isExpanded = false;

  Future<void> _handleLoginOrProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Notify shell to show login page
      widget.onNavigate(ShellPage.login);
    } else {
      // Navigate to profile page in a full-screen route (not in shell)
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
      setState(() {}); // refresh nav bar after returning from profile
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out')),
      );
      setState(() {});
      widget.onNavigate(ShellPage.trending); // Go back to trending after logout
    }
  }

  void _showSearchOrAddNameDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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

  Future<void> _submitName(TextEditingController controller) async {
    final name = controller.text.trim().toLowerCase();
    if (name.isEmpty) return;

    try {
      final membersRef = FirebaseFirestore.instance.collection('members');
      final existing = await membersRef.doc(name).get();

      if (!existing.exists) {
        await membersRef.doc(name).set({});
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onNavigate(ShellPage.nameBoard, name: name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openUserDirectory() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: UserDirectoryPage(
            onUserSelected: (name) {
              Navigator.of(context).pop(name);
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      widget.onNavigate(ShellPage.nameBoard, name: selected);
    }
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
      builder: (_) => AlertDialog(
        title: const Text('Voodoo Summoning Ready!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔮 The summoning message has been copied to your clipboard!\n\n'
              'Go ahead and paste it somewhere — watch the magic happen as they come to their board page!\n\nMessage:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hexController,
              maxLines: null,
              readOnly: true,
              showCursor: true,
              enableInteractiveSelection: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
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
                  content: Text(
                      'Summoning copied to clipboard — send it to someone!'),
                ),
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
    final user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          setState(() {
            isExpanded = true;
          });
        } else if (details.primaryVelocity! > 0) {
          setState(() {
            isExpanded = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: isExpanded ? 140 : 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          boxShadow: const [BoxShadow(blurRadius: 4)],
        ),
        child: Column(
          children: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavButton(
                          icon: Icons.trending_up,
                          label: 'Trending',
                          onTap: () => widget.onNavigate(ShellPage.trending),
                        ),
                        _NavButton(
                            icon: Icons.person_add,
                            label: 'Add',
                            onTap: _showSearchOrAddNameDialog),
                        _NavButton(
                            icon: Icons.search,
                            label: 'Search',
                            onTap: _openUserDirectory),
                        _NavButton(
                            icon: Icons.send,
                            label: 'Summon',
                            onTap: _showVoodooDialog),
                        _NavButton(
                          icon: user == null ? Icons.login : Icons.person,
                          label: user == null ? 'Login' : 'Profile',
                          onTap: _handleLoginOrProfile,
                        ),
                        if (user != null)
                          _NavButton(
                              icon: Icons.logout,
                              label: 'Logout',
                              onTap: _handleLogout),
                      ],
                    ),
                    if (isExpanded && user != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _NavButton(
                            icon: Icons.group_add,
                            label: 'Community',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Coming soon: Community creation')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      minWidth: 50,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0), // 👈 Add top padding here
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
