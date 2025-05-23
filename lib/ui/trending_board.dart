import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class TrendingBoardsPage extends StatefulWidget {
  /// Callback to tell shell which name board to show
  final void Function(String name)? onNameSelected;

  const TrendingBoardsPage({Key? key, this.onNameSelected}) : super(key: key);

  @override
  State<TrendingBoardsPage> createState() => _TrendingBoardsPageState();
}

class _TrendingBoardsPageState extends State<TrendingBoardsPage> {
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

  Widget _buildTrendingSection(String title, List<String> names, Icon icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 12),
        if (names.isEmpty) const Text('No entries.'),
        ...names.map(
          (name) => ListTile(
            leading: icon,
            title: Text(name),
            onTap: () {
              if (widget.onNameSelected != null) {
                widget.onNameSelected!(name);
              }
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // We remove Scaffold and AppBar because shell handles that
    return Padding(
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
          final data = snapshot.data ?? {};
          final mostActive = data['mostActive'] ?? [];
          final gainingEnergy = data['gainingEnergy'] ?? [];

          return ListView(
            children: [
              _buildTrendingSection(
                'Most Active Names Today',
                mostActive,
                const Icon(Icons.local_fire_department,
                    color: Colors.deepPurple),
              ),
              _buildTrendingSection(
                'Names Gaining Energy',
                gainingEnergy,
                const Icon(Icons.bolt, color: Colors.orange),
              ),
            ],
          );
        },
      ),
    );
  }
}
