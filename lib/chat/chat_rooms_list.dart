import 'package:chat/chat/chat_room.dart';
import 'package:chat/chat/chat_utilities/check_ban_kick_alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomsList extends StatefulWidget {
  const ChatRoomsList({Key? key}) : super(key: key);

  @override
  ChatRoomsListState createState() => ChatRoomsListState();
}

class ChatRoomsListState extends State<ChatRoomsList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void redirectToChatRoom(String roomId, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoom(
          roomId: roomId,
          userId: userId,
        ),
      ),
    );
  }

  void showKickAlert(
      String userName, String message, String remainingTimeFormatted) {
    showDialog(
      context: context,
      builder: (context) {
        return _buildKickAlert(
          message: message,
          remainingTimeFormatted: remainingTimeFormatted,
          userName: userName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Rooms')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chatrooms').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final roomDoc = rooms[index];
              final roomId = roomDoc.id;
              final roomName = roomDoc.get('chatroom');
              final usersOnline = roomDoc.get('users_online');

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(roomName),
                  subtitle: Text('$usersOnline users online'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final kickStatus = await checkUserKicked(userId);

                    if (kickStatus.isKicked) {
                      final kickedUserDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get();

                      final kickedUserName = kickedUserDoc.get('username');

                      final remainingTime =
                          kickStatus.kickExpiration.difference(DateTime.now());

                      const String message = 'You are kicked';
                      final String remainingTimeFormatted =
                          '${remainingTime.inMinutes} minutes ${remainingTime.inSeconds % 60} seconds';

                      showKickAlert(
                          kickedUserName, message, remainingTimeFormatted);
                    } else {
                      redirectToChatRoom(roomId, userId);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildKickAlert({
    required String userName,
    required String message,
    required String remainingTimeFormatted,
  }) {
    return AlertDialog(
      title: Center(child: Text(userName)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 10),
          Text('Remaining time: $remainingTimeFormatted'),
        ],
      ),
    );
  }
}
