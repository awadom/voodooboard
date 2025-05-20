// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<String>> getAllMemberNames() async {
    final snapshot = await _db.collection('members').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Get trending names by counting messages and reactions within daily/hourly windows
  Future<Map<String, List<String>>> getTrendingNames({
    int topN = 10,
  }) async {
    final membersCollection = _db.collection('members');
    final now = DateTime.now().toUtc();

    // Add a 10-minute buffer to the daily cutoff to avoid edge cases
    final oneDayAgo = Timestamp.fromDate(
      now.subtract(const Duration(days: 1, minutes: 10)),
    );
    final oneHourAgo =
        Timestamp.fromDate(now.subtract(const Duration(hours: 1)));

    print('Now (UTC): $now');
    print('One day ago with buffer (UTC): ${oneDayAgo.toDate().toUtc()}');
    print('One hour ago (UTC): ${oneHourAgo.toDate().toUtc()}');

    try {
      print('Fetching members collection...');
      final querySnapshot = await membersCollection.get();
      print(
          'Members collection fetched, total docs: ${querySnapshot.docs.length}');
      if (querySnapshot.docs.isEmpty) {
        print('No members found in collection!');
        return {'mostActive': [], 'gainingEnergy': []};
      }

      final List<_NameStats> statsList = [];

      for (final memberDoc in querySnapshot.docs) {
        final memberName = memberDoc.id;
        print('---');
        print('Checking member: $memberName');

        final messagesCollection =
            membersCollection.doc(memberName).collection('messages');

        // Query messages from last day
        final dailyMessagesSnapshot = await messagesCollection
            .where('timestamp', isGreaterThanOrEqualTo: oneDayAgo)
            .get();

        print(
            'Member $memberName daily messages count: ${dailyMessagesSnapshot.docs.length}');

        if (dailyMessagesSnapshot.docs.isEmpty) {
          print('Skipping $memberName due to no daily messages');
          continue;
        }

        // Query messages from last hour
        final hourlyMessagesSnapshot = await messagesCollection
            .where('timestamp', isGreaterThanOrEqualTo: oneHourAgo)
            .get();

        print(
            'Member $memberName hourly messages count: ${hourlyMessagesSnapshot.docs.length}');

        int dailyCount = 0;
        for (final msgDoc in dailyMessagesSnapshot.docs) {
          dailyCount++; // count the message itself

          final ts = msgDoc.get('timestamp');
          if (ts is Timestamp) {
            print(
                'Daily msg timestamp: ${ts.toDate().toUtc()} for member $memberName');
          } else {
            print('Daily msg timestamp missing or invalid for $memberName');
          }

          final reactionsRaw = msgDoc.data()['reactions'];
          final reactions = (reactionsRaw is Map)
              ? Map<String, dynamic>.from(reactionsRaw)
              : <String, dynamic>{};

          final reactionsCount = reactions.values.fold<int>(
            0,
            (prev, elem) => prev + (elem is int ? elem : 0),
          );

          dailyCount += reactionsCount;
        }

        int hourlyCount = 0;
        for (final msgDoc in hourlyMessagesSnapshot.docs) {
          hourlyCount++; // message itself
          final reactionsRaw = msgDoc.data()['reactions'];
          final reactions = (reactionsRaw is Map)
              ? Map<String, dynamic>.from(reactionsRaw)
              : <String, dynamic>{};

          final reactionsCount = reactions.values.fold<int>(
            0,
            (prev, elem) => prev + (elem is int ? elem : 0),
          );
          hourlyCount += reactionsCount;
        }

        print('Member $memberName daily interactions: $dailyCount');
        print('Member $memberName hourly interactions: $hourlyCount');

        statsList.add(_NameStats(
            name: memberName, daily: dailyCount, hourly: hourlyCount));
      }

      // Sort descending by daily for most active
      statsList.sort((a, b) => b.daily.compareTo(a.daily));
      final mostActive = statsList.take(topN).map((e) => e.name).toList();

      // Sort descending by hourly for gaining energy
      statsList.sort((a, b) => b.hourly.compareTo(a.hourly));
      final gainingEnergy = statsList.take(topN).map((e) => e.name).toList();

      print('Most Active Names: $mostActive');
      print('Gaining Energy Names: $gainingEnergy');

      return {
        'mostActive': mostActive,
        'gainingEnergy': gainingEnergy,
      };
    } catch (e, stacktrace) {
      print('Error during getTrendingNames: $e');
      print(stacktrace);
      return {'mostActive': [], 'gainingEnergy': []};
    }
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
