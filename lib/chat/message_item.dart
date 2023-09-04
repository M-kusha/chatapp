import 'package:chat/chat/chat_utilities/chat_utils.dart';
import 'package:chat/profile/chat_room_profile.dart';
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
        ? DateFormat('hh:mm ').format(timestamp.toDate())
        : 'Unknown time';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          buildProfileWidget(context, messageSender ?? ''),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMessageSenderNameandDeleteButton(
                    messageSenderName ?? '', messageSender ?? ''),
                buildMessageTextandTime(messageText ?? '', formattedDate),
              ],
            ),
          ),
          if ((isAdmin || isModerator))
            iconButton(messageSender ?? '', userId, context),
        ],
      ),
    );
  }

  Widget buildMessageSenderNameandDeleteButton(
      String messageSenderName, String messageSender) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          messageSenderName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        if ((isAdmin || isModerator))
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline_outlined,
              color: Colors.red,
            ),
            onPressed: () {
              deleteMessage(
                messageSender,
                message.id,
              );
            },
          ),
      ],
    );
  }

  Widget buildMessageTextandTime(String messageText, String formattedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            messageText,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Text(
          formattedDate,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }

  Widget buildProfileWidget(BuildContext context, String messageSender) {
    final profileImage = message['profileImage'];
    final isCurrentUser = userId == messageSender;

    return InkWell(
      onTap: () {
        if (!isCurrentUser) {
          showUserDetails(messageSender, context);
        }
      },
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: CircleAvatar(
          backgroundImage:
              profileImage != null ? NetworkImage(profileImage) : null,
          child:
              profileImage == null ? const Icon(Icons.person, size: 30) : null,
        ),
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
