import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  bool isExpanded = false;

  void _showSearchOrAddNameDialog() {
    // TODO: Implement your dialog logic
  }

  void _openUserDirectory() {
    // TODO: Implement your directory logic
  }

  void _showVoodooDialog() {
    // TODO: Implement your summon dialog logic
  }

  void _handleLoginOrProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
    } else {
      Navigator.pushNamed(context, '/profile');
    }
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
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
            // Flexible lets it size with available space
            Flexible(
              child: ClipRect(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
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
                                // TODO: Implement create community logic
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
