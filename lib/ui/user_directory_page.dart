import 'package:flutter/material.dart';
import '../services/firestore_service.dart'; // <-- update path
import 'home_page.dart';

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

  void _addUserDialog() {
    final TextEditingController newUserController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: newUserController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter user name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newUser = newUserController.text.trim();
              if (newUser.isEmpty) return;

              if (users.any((u) => u.toLowerCase() == newUser.toLowerCase())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User "$newUser" already exists.')),
                );
                return;
              }

              setState(() {
                users.add(newUser);
                filteredUsers = List.from(users);
                searchController.clear();
              });

              Navigator.pop(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VoodooBoardHomePage(name: newUser),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
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
            onPressed: _addUserDialog,
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
