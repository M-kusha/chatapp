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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey,
            Color.fromARGB(255, 71, 124, 150),
          ], // Gradient colors
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                  hintText: "Enter your message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // Implement file attachment functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (messageController.text.trim().isNotEmpty) {
                sendMessage(roomId, userId, messageController, context);
              }
            },
          ),
        ],
      ),
    );
  }
}
