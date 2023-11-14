import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> kickUser(
    String userId, String roomId, BuildContext context) async {
  const kickDuration = Duration(minutes: 15);
  final kickExpiration = DateTime.now().add(kickDuration);

  await updateUserKickExpiration(userId, kickExpiration);
}

Future<void> muteUser(String userId, String roomId) async {
  const muteDuration = Duration(minutes: 5);
  final muteExpiration = DateTime.now().add(muteDuration);

  await updateUserMuteExpiration(userId, muteExpiration);
}

bool isUserMuted(Map<String, dynamic> userData) {
  final muteExpiration = userData['muteExpiration'] as Timestamp?;
  if (muteExpiration != null &&
      muteExpiration.toDate().isAfter(DateTime.now())) {
    return true; // User is muted
  }
  return false; // User is not muted or mute expired
}

Future<void> updateUserMuteExpiration(
    String userId, DateTime expiration) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'muteExpiration': expiration,
  });
}

Future<void> banUser(
  String userId,
  String roomId,
  String widgetUserId,
) async {
  const banDuration = Duration(days: 2);
  final banExpiration = DateTime.now().add(banDuration);

  // await updateUserOnlineStatus(roomId, userId);
  await updateUserBanExpiration(userId, banExpiration, widgetUserId);
}

// Future<void> updateUserOnlineStatus(String roomId, String userId) async {
//   await FirebaseFirestore.instance.collection('chatrooms').doc(roomId).update({
//     'users_online': FieldValue.arrayRemove([userId]),
//   });
// }

Future<void> updateUserKickExpiration(
    String userId, DateTime expiration) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'kickExpiration': expiration,
  });
}

Future<void> updateUserBanExpiration(
    String userId, DateTime expiration, String widgetUserId) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'banExpiration': expiration,
  });
}

Future<void> invokeOptionsDialog(
    String messageSender, String widgetUserId, BuildContext context) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final currentUserRole = userDoc.get('role');
    final localContext = context;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showOptionsDialog(
        messageSender,
        localContext,
        currentUserRole,
      );
    });
  }
}

Future<bool> checkAdmin(String userId) async {
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userRole = userDoc.get('role');

  return userRole == 'admin' || userRole == 'superadmin';
}

Future<bool> checkModerator(String userId) async {
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userRole = userDoc.get('role');

  return userRole == 'moderator';
}

Future<void> deleteMessage(String roomId, String messageId) async {
  await FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(roomId)
      .collection('messages')
      .doc(messageId)
      .delete();
}

void showScaffoldMessage(String message, BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.red),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> sendMessage(
  String roomId,
  String userId,
  TextEditingController messageController,
  BuildContext context,
) async {
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (isUserMuted(userDoc.data() as Map<String, dynamic>)) {
    const snackBar = SnackBar(
      content: Text(
        'You are muted and cannot send messages.',
        style: TextStyle(color: Colors.red),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
    return;
  }

  final messageText = messageController.text.trim();
  if (messageText.isNotEmpty) {
    final username = userDoc.get('username') ?? 'DefaultUsername';
    final profileImage = userDoc.get('profileImage');

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add({
      'text': messageText,
      'senderId': userId,
      'username': username,
      'profileImage': profileImage,
      'timestamp': FieldValue.serverTimestamp(),
    });

    messageController.clear();
  }
}

Future<void> promoteUser(String userUid, String newRole) async {
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userUid).get();

  if (userDoc.exists) {
    await userDoc.reference.update({
      'role': newRole,
    });
  } else {}
}

Future<void> showOptionsDialog(
    String messageSender, BuildContext context, String currentUserRole) async {
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  final currentUserRole = userDoc.get('role');

  final isAdmin = currentUserRole == 'admin';
  final isModerator = currentUserRole == 'moderator';
  final isSuperAdmin = currentUserRole == 'superadmin';

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if ((isSuperAdmin || isAdmin || isModerator))
              ListTile(
                leading: const Icon(Icons.volume_off),
                title: const Text('Mute User'),
                onTap: () {
                  muteUser(
                    messageSender,
                    FirebaseAuth.instance.currentUser!.uid,
                  );
                  Navigator.pop(context);
                },
              ),
            if ((isSuperAdmin || isAdmin || isModerator))
              ListTile(
                leading: const Icon(Icons.person_remove),
                title: const Text('Kick User'),
                onTap: () {
                  kickUser(
                    messageSender,
                    FirebaseAuth.instance.currentUser!.uid,
                    context,
                  );
                  Navigator.pop(context);
                },
              ),
            if ((isSuperAdmin || isAdmin))
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Ban User'),
                onTap: () {
                  banUser(
                    messageSender,
                    FirebaseAuth.instance.currentUser!.uid,
                    currentUserRole,
                  );
                  Navigator.pop(context);
                },
              ),
            if (isSuperAdmin)
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: const Text('Promote User'),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings),
                            title: const Text('Admin'),
                            onTap: () {
                              promoteUser(messageSender, 'admin');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.military_tech),
                            title: const Text('Moderator'),
                            onTap: () {
                              promoteUser(messageSender, 'moderator');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('User'),
                            onTap: () {
                              promoteUser(messageSender, 'user');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  });
}
