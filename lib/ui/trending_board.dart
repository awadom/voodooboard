// lib/ui/trending_board.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/firestore_service.dart';
import '../app.dart'; // to access routeObserver

class TrendingBoardsPage extends StatefulWidget {
  const TrendingBoardsPage({super.key});

  @override
  State<TrendingBoardsPage> createState() => _TrendingBoardsPageState();
}

class _TrendingBoardsPageState extends State<TrendingBoardsPage>
    with RouteAware {
  late Future<Map<String, List<String>>> _trendingNamesFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchTrendingNames();
  }

  void _fetchTrendingNames() {
    setState(() {
      _trendingNamesFuture = _firestoreService.getTrendingNames(topN: 10);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the page is visible again
    _fetchTrendingNames();
  }

  void _navigateToBoard(BuildContext context, String name) {
    Navigator.pushNamed(
      context,
      AppRoutes.nameBoard,
      arguments: name,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Name Boards'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
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
            final gainingEnergyNames = snapshot.data!['gainingEnergy'] ?? [];

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
                ...mostActiveNames.map(
                  (name) => ListTile(
                    leading: const Icon(
                      Icons.local_fire_department,
                      color: Colors.deepPurple,
                    ),
                    title: Text(name),
                    onTap: () => _navigateToBoard(context, name),
                  ),
                ),
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
                ...gainingEnergyNames.map(
                  (name) => ListTile(
                    leading: const Icon(Icons.bolt, color: Colors.orange),
                    title: Text(name),
                    onTap: () => _navigateToBoard(context, name),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: _showSearchOrAddNameDialog,
          backgroundColor: const Color.fromARGB(255, 252, 235, 254),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Square with soft corners
          ),
          child: const Text(
            '🔮',
            style: TextStyle(fontSize: 40),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
