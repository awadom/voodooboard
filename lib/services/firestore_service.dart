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

    final querySnapshot = await membersCollection.get();

    final List<_NameStats> statsList = [];

    for (final memberDoc in querySnapshot.docs) {
      final memberName = memberDoc.id;
      print('Checking member: $memberName');

      final messagesCollection =
          membersCollection.doc(memberName).collection('messages');

      // Query messages from last day
      final dailyMessagesSnapshot = await messagesCollection
          .where('timestamp', isGreaterThanOrEqualTo: oneDayAgo)
          .get();

      print(
          'Member $memberName daily messages count: ${dailyMessagesSnapshot.docs.length}');

      // Query messages from last hour
      final hourlyMessagesSnapshot = await messagesCollection
          .where('timestamp', isGreaterThanOrEqualTo: oneHourAgo)
          .get();

      print(
          'Member $memberName hourly messages count: ${hourlyMessagesSnapshot.docs.length}');

      // Count daily interactions = messages + sum of all reactions counts on those messages
      int dailyCount = 0;
      for (final msgDoc in dailyMessagesSnapshot.docs) {
        dailyCount++; // count the message itself

        // Print timestamp for debugging
        final ts = msgDoc.get('timestamp') as Timestamp;
        print(
            'Daily msg timestamp: ${ts.toDate().toUtc()} for member $memberName');

        final reactions =
            Map<String, dynamic>.from(msgDoc.get('reactions') ?? {});
        dailyCount += reactions.values.fold<int>(
          0,
          (previousValue, element) =>
              previousValue + (element is int ? element : 0),
        );
      }

      // Count hourly interactions similarly
      int hourlyCount = 0;
      for (final msgDoc in hourlyMessagesSnapshot.docs) {
        hourlyCount++; // message itself
        final reactions =
            Map<String, dynamic>.from(msgDoc.get('reactions') ?? {});
        hourlyCount += reactions.values.fold<int>(
          0,
          (prev, elem) => prev + (elem is int ? elem : 0),
        );
      }

      statsList.add(
          _NameStats(name: memberName, daily: dailyCount, hourly: hourlyCount));
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
