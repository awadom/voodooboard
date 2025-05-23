
import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/firestore_service.dart';
import '../app.dart'; // for routeObserver
import '../ui/custom_nav_bar.dart';


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

  void _navigateToBoard(String name) {
    Navigator.pushNamed(context, AppRoutes.nameBoard, arguments: name);
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
            onTap: () => _navigateToBoard(name),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
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
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
