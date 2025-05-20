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

    final oneDayAgo = Timestamp.fromDate(
      now.subtract(const Duration(days: 1, minutes: 10)),
    );
    final oneHourAgo =
        Timestamp.fromDate(now.subtract(const Duration(hours: 1)));

    try {
      final querySnapshot = await membersCollection.get();
      if (querySnapshot.docs.isEmpty) {
        return {'mostActive': [], 'gainingEnergy': []};
      }

      final List<_NameStats> statsList = [];

      for (final memberDoc in querySnapshot.docs) {
        final memberName = memberDoc.id.toLowerCase();

        final messagesCollection =
            membersCollection.doc(memberName).collection('messages');

        // Daily: messages posted in the last 24h
        final dailyMessagesSnapshot = await messagesCollection
            .where('timestamp', isGreaterThanOrEqualTo: oneDayAgo)
            .get();

        // Hourly: messages with interaction in the last hour
        final hourlyMessagesSnapshot = await messagesCollection
            .where('lastInteraction', isGreaterThanOrEqualTo: oneHourAgo)
            .get();

        int dailyCount = 0;
        for (final msgDoc in dailyMessagesSnapshot.docs) {
          dailyCount++; // message itself
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

        if (dailyCount > 0 || hourlyCount > 0) {
          statsList.add(_NameStats(
            name: memberName,
            daily: dailyCount,
            hourly: hourlyCount,
          ));
        }
      }

      final mostActive = statsList.where((e) => e.daily > 0).toList()
        ..sort((a, b) => b.daily.compareTo(a.daily));
      final mostActiveNames = mostActive.take(topN).map((e) => e.name).toList();

      final gainingEnergy = statsList.where((e) => e.hourly > 0).toList()
        ..sort((a, b) => b.hourly.compareTo(a.hourly));
      final gainingEnergyNames =
          gainingEnergy.take(topN).map((e) => e.name).toList();

      return {
        'mostActive': mostActiveNames,
        'gainingEnergy': gainingEnergyNames,
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
