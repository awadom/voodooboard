import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class UserDirectoryPage extends StatefulWidget {
  final void Function(String userName)? onUserSelected;

  const UserDirectoryPage({super.key, this.onUserSelected});

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 400,
      child: Column(
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
                        onTap: () {
                          Navigator.of(context).pop(user);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
