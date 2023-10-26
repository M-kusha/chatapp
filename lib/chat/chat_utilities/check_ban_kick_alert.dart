import 'package:cloud_firestore/cloud_firestore.dart';

class KickStatus {
  final bool isKicked;
  final DateTime kickExpiration;

  KickStatus({
    required this.isKicked,
    required this.kickExpiration,
  });
}

Future<KickStatus> checkUserKicked(String userId) async {
  try {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final kickExpirationTimestamp = userDoc.get('kickExpiration') as Timestamp?;

    if (kickExpirationTimestamp == null) {
      return KickStatus(isKicked: false, kickExpiration: DateTime.now());
    }

    final isKicked = kickExpirationTimestamp.toDate().isAfter(DateTime.now());
    final kickExpiration =
        isKicked ? kickExpirationTimestamp.toDate() : DateTime.now();

    return KickStatus(
      isKicked: isKicked,
      kickExpiration: kickExpiration,
    );
  } catch (error) {
    // Handle the error, e.g., log it or return a default value
    return KickStatus(isKicked: false, kickExpiration: DateTime.now());
  }
}
