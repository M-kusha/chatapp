import 'package:chat/chat/chat_utilities/chat_utils.dart';
import 'package:flutter/material.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController messageController;
  final String roomId;
  final String userId;

  const MessageInputBar({
    super.key,
    required this.messageController,
    required this.roomId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: const InputDecoration(
              hintText: "Enter your message...",
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            sendMessage(roomId, userId, messageController, context);
          },
        ),
      ],
    );
  }
}
