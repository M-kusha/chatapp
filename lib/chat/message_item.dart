import 'package:chat/chat/chat_utilities/chat_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageItem extends StatelessWidget {
  final DocumentSnapshot message;
  final bool isAdmin;
  final bool isModerator;
  final String userId;

  const MessageItem({
    Key? key,
    required this.message,
    required this.isAdmin,
    required this.isModerator,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageText = message['text'];
    final messageSender = message['senderId'];
    final messageSenderName = message['username'];
    final isCurrentUser = userId == messageSender;
    final timestamp = message['timestamp'] as Timestamp?;
    final formattedDate = timestamp != null
        ? DateFormat('hh:mm').format(timestamp.toDate())
        : 'Unknown time';
    final profileImage = message['profileImage'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isCurrentUser)
                CircleAvatar(
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage) : null,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blueGrey,
                        Color.fromARGB(255, 71, 124, 150),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        messageSenderName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        messageText ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isAdmin || isModerator)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    invokeOptionsDialog(messageSender, userId, context);
                  },
                ),
            ],
          ),
          if (isAdmin || isModerator) buildDeleteButton(context),
        ],
      ),
    );
  }

  Widget buildDeleteButton(BuildContext context) {
    return Positioned(
      top: -10,
      right: 40,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () {
          deleteMessage(message['senderId'], message.id);
        },
      ),
    );
  }

  Widget iconButton(String messageSender, String userId, BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        invokeOptionsDialog(messageSender, userId, context);
      },
    );
  }
}
