import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';
import '../routes.dart';

class UserDirectoryPage extends StatefulWidget {
  const UserDirectoryPage({super.key});

  @override
  State<UserDirectoryPage> createState() => _UserDirectoryPageState();
}

class _UserDirectoryPageState extends State<UserDirectoryPage> {
  List<String> users = [];
  List<String> filteredUsers = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsersFromFirestore();

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredUsers =
            users.where((user) => user.toLowerCase().contains(query)).toList();
      });
    });
  }

  Future<void> _loadUsersFromFirestore() async {
    final firestoreService = FirestoreService();
    final fetchedUsers = await firestoreService.getAllMemberNames();
    setState(() {
      users = fetchedUsers;
      filteredUsers = List.from(fetchedUsers);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  void _openUserBoard(String userName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VoodooBoardHomePage(name: userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add User',
            onPressed: _showSearchOrAddNameDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        title: Text(user),
                        onTap: () => _openUserBoard(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
