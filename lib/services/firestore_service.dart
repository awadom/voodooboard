import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<String>> getAllMemberNames() async {
    final snapshot = await _db.collection('members').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<Map<String, List<String>>> getTrendingNames({int topN = 10}) async {
    final membersCollection = _db.collection('members');
    final now = DateTime.now().toUtc();
    final oneDayAgo = Timestamp.fromDate(now.subtract(const Duration(days: 1)));
    final oneHourAgo =
        Timestamp.fromDate(now.subtract(const Duration(hours: 1)));

    try {
      final querySnapshot = await membersCollection.get();
      if (querySnapshot.docs.isEmpty) {
        return await _loadFallbackFromFirestore(topN: topN);
      }

      final List<_NameStats> statsList = [];

      for (final memberDoc in querySnapshot.docs) {
        final memberName = memberDoc.id.toLowerCase();
        final messagesCollection =
            membersCollection.doc(memberName).collection('messages');

        final dailyMessagesSnapshot = await messagesCollection
            .where('timestamp', isGreaterThanOrEqualTo: oneDayAgo)
            .get();

        final hourlyMessagesSnapshot = await messagesCollection
            .where('lastInteraction', isGreaterThanOrEqualTo: oneHourAgo)
            .get();

        int dailyCount = _countMessagesAndReactions(dailyMessagesSnapshot);
        int hourlyCount = _countMessagesAndReactions(hourlyMessagesSnapshot);

        if (dailyCount > 0 || hourlyCount > 0) {
          statsList.add(_NameStats(
              name: memberName, daily: dailyCount, hourly: hourlyCount));
        }
      }

      final mostActive = statsList.where((e) => e.daily > 0).toList()
        ..sort((a, b) => b.daily.compareTo(a.daily));
      final gainingEnergy = statsList.where((e) => e.hourly > 0).toList()
        ..sort((a, b) => b.hourly.compareTo(a.hourly));

      final mostActiveNames = mostActive.take(topN).map((e) => e.name).toList();
      final gainingEnergyNames =
          gainingEnergy.take(topN).map((e) => e.name).toList();

      final hasRecentDaily = mostActiveNames.isNotEmpty;
      final hasRecentHourly = gainingEnergyNames.isNotEmpty;

      if (hasRecentDaily || hasRecentHourly) {
        await _saveFallbackToFirestore(
          mostActive: hasRecentDaily ? mostActiveNames : null,
          gainingEnergy: hasRecentHourly ? gainingEnergyNames : null,
        );
      }

      if (!hasRecentDaily && !hasRecentHourly) {
        return await _loadFallbackFromFirestore(topN: topN);
      }

      return {
        'mostActive': hasRecentDaily ? mostActiveNames : [],
        'gainingEnergy': hasRecentHourly ? gainingEnergyNames : [],
      };
    } catch (e, stacktrace) {
      print('Error during getTrendingNames: $e');
      print(stacktrace);
      return await _loadFallbackFromFirestore(topN: topN);
    }
  }

  int _countMessagesAndReactions(QuerySnapshot snapshot) {
    int count = 0;
    for (final msgDoc in snapshot.docs) {
      count++;
      final data = msgDoc.data() as Map<String, dynamic>? ?? {};
      final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
      final reactionsCount = reactions.values.fold<int>(
        0,
        (prev, elem) => prev + (elem is int ? elem : 0),
      );
      count += reactionsCount;
    }
    return count;
  }

  Future<void> _saveFallbackToFirestore({
    List<String>? mostActive,
    List<String>? gainingEnergy,
  }) async {
    final fallbackDoc = _db.collection('metadata').doc('fallbackTrending');
    final dataToUpdate = <String, dynamic>{};
    if (mostActive != null) dataToUpdate['mostActive'] = mostActive;
    if (gainingEnergy != null) dataToUpdate['gainingEnergy'] = gainingEnergy;
    dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();
    await fallbackDoc.set(dataToUpdate, SetOptions(merge: true));
  }

  Future<Map<String, List<String>>> _loadFallbackFromFirestore(
      {int topN = 10}) async {
    try {
      final fallbackDoc =
          await _db.collection('metadata').doc('fallbackTrending').get();
      if (fallbackDoc.exists) {
        final data = fallbackDoc.data()!;
        final mostActive = List<String>.from(data['mostActive'] ?? []);
        final gainingEnergy = List<String>.from(data['gainingEnergy'] ?? []);
        return {
          'mostActive': mostActive,
          'gainingEnergy': gainingEnergy,
        };
      } else {
        // No fallback doc — generate fallback dynamically
        return await _generateFallbackFromAllTimeStats(topN: topN);
      }
    } catch (e) {
      print('Error loading fallback from Firestore: $e');
      return {'mostActive': [], 'gainingEnergy': []};
    }
  }

  Future<Map<String, List<String>>> _generateFallbackFromAllTimeStats(
      {int topN = 10}) async {
    final membersCollection = _db.collection('members');
    final querySnapshot = await membersCollection.get();

    final List<_NameStats> statsList = [];

    for (final memberDoc in querySnapshot.docs) {
      final memberName = memberDoc.id.toLowerCase();
      final messagesCollection =
          membersCollection.doc(memberName).collection('messages');

      final messagesSnapshot = await messagesCollection.get();

      int totalCount = _countMessagesAndReactions(messagesSnapshot);

      // Find most recent timestamp or lastInteraction for this member
      DateTime? mostRecent;
      for (final doc in messagesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final ts = data['lastInteraction'] ?? data['timestamp'];
        if (ts is Timestamp) {
          final current = ts.toDate();
          if (mostRecent == null || current.isAfter(mostRecent)) {
            mostRecent = current;
          }
        }
      }

      if (totalCount > 0) {
        statsList.add(_NameStats(
          name: memberName,
          daily: totalCount,
          hourly: mostRecent?.millisecondsSinceEpoch ?? 0,
        ));
      }
    }

    final mostActive = statsList..sort((a, b) => b.daily.compareTo(a.daily));
    final recentActive = List<_NameStats>.from(statsList)
      ..sort((a, b) => b.hourly.compareTo(a.hourly));

    return {
      'mostActive': mostActive.take(topN).map((e) => e.name).toList(),
      'gainingEnergy': recentActive.take(topN).map((e) => e.name).toList(),
    };
  }
}

class _NameStats {
  final String name;
  final int daily;
  final int hourly;

  _NameStats({
    required this.name,
    required this.daily,
    required this.hourly,
  });
}
