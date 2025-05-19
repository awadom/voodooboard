// lib/ui/trending_board.dart

import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/firestore_service.dart';

class TrendingBoardsPage extends StatefulWidget {
  const TrendingBoardsPage({super.key});

  @override
  State<TrendingBoardsPage> createState() => _TrendingBoardsPageState();
}

class _TrendingBoardsPageState extends State<TrendingBoardsPage> {
  late Future<Map<String, List<String>>> _trendingNamesFuture;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trendingNamesFuture = _firestoreService.getTrendingNames(topN: 10);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _navigateToBoard(BuildContext context, String name) {
    Navigator.pushNamed(
      context,
      AppRoutes.nameBoard,
      arguments: name,
    );
  }

  void _showSearchOrAddNameDialog() {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search or Add Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Enter a name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop();
                  _navigateToBoard(context, name);
                }
              },
              child: const Text('Go to Board'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Name Boards'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: FutureBuilder<Map<String, List<String>>>(
              future: _trendingNamesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No trending names found.'));
                }

                final mostActiveNames = snapshot.data!['mostActive'] ?? [];
                final gainingEnergyNames =
                    snapshot.data!['gainingEnergy'] ?? [];

                return ListView(
                  children: [
                    const Text(
                      'Most Active Names Today',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (mostActiveNames.isEmpty)
                      const Text('No active names found today.'),
                    ...mostActiveNames.map((name) => ListTile(
                          leading: const Icon(Icons.local_fire_department,
                              color: Colors.deepPurple),
                          title: Text(name),
                          onTap: () => _navigateToBoard(context, name),
                        )),
                    const SizedBox(height: 32),
                    const Text(
                      'Names Gaining Energy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (gainingEnergyNames.isEmpty)
                      const Text('No names gaining energy recently.'),
                    ...gainingEnergyNames.map((name) => ListTile(
                          leading: const Icon(Icons.bolt, color: Colors.orange),
                          title: Text(name),
                          onTap: () => _navigateToBoard(context, name),
                        )),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _showSearchOrAddNameDialog,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  '🔮 Search or Add Name',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
