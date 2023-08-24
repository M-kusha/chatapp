// chat_rooms_list.dart

import 'package:chat/chat/chat_room.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomsList extends StatefulWidget {
  const ChatRoomsList({super.key});

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
            return const CircularProgressIndicator();
          }

          final rooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final roomDoc = rooms[index];
              final roomId = roomDoc.id;

              return ListTile(
                title: Text(roomId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatRoom(roomId: roomId, userId: userId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
