import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ui/custom_nav_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // After sign out, go back to the home page or login page as needed
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: user == null
              ? const Text('No user is signed in.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Logged in as:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? 'No email available',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      onPressed: () => _signOut(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
