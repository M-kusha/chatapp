import 'package:chat/chat/chat_room.dart';
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatRoom(roomId: roomId, userId: userId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
