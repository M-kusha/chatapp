import 'package:chat/chat/message_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final String roomId;
  final String userId;
  final bool isAdmin;
  final bool isModerator;

  const MessageList({
    super.key,
    required this.roomId,
    required this.userId,
    required this.isAdmin,
    required this.isModerator,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final messages = snapshot.data!.docs;
        return ListView(
          reverse: true,
          children: messages.map((message) {
            return MessageItem(
              message: message,
              isAdmin: isAdmin,
              isModerator: isModerator,
              userId: userId,
            );
          }).toList(),
        );
      },
    );
  }
}
