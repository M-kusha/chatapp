import 'package:chat/chat/chat_utilities/check_ban_kick_alert.dart';
import 'package:chat/chat/message_input.dart';
import 'package:chat/chat/message_list.dart';
import 'package:chat/chat/chat_utilities/chat_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String roomId;
  final String userId;
  final String roomName;

  const ChatRoom({
    Key? key,
    required this.roomId,
    required this.userId,
    required this.roomName,
    required bool isLocked,
  }) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  bool isAdmin = false;
  bool isModerator = false;
  late Stream<KickStatus> kickStatusStream;

  @override
  void initState() {
    super.initState();
    checkAdmin(widget.userId).then((value) {
      setState(() {
        isAdmin = value;
      });
    });

    checkModerator(widget.userId).then((value) {
      setState(() {
        isModerator = value;
      });
    });

    kickStatusStream = checkUserKicked(widget.userId).asStream();
  }

  void userLeftChatRoom() {
    _messageController.clear();
    decreaseOnlineUdesersCount(widget.roomId);
    Navigator.pop(context);
  }

  void decreaseOnlineUdesersCount(String roomId) {
    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    roomRef.update({
      'online_users_count': FieldValue.increment(-1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.roomName, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueGrey,
                Color.fromARGB(255, 71, 124, 150),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              userLeftChatRoom();
            },
          ),
        ],
      ),
      body: StreamBuilder<KickStatus>(
        stream: kickStatusStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Handle loading state
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final kickStatus = snapshot.data!;
            if (kickStatus.isKicked) {
              final remainingTime =
                  kickStatus.kickExpiration.difference(DateTime.now());
              _showKickAlert(remainingTime);
              userLeftChatRoom();
              return const SizedBox();
            }

            return Container(
              color: Colors.grey[300],
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: MessageList(
                        roomId: widget.roomId,
                        userId: widget.userId,
                        isAdmin: isAdmin,
                        isModerator: isModerator,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MessageInputBar(
                      messageController: _messageController,
                      roomId: widget.roomId,
                      userId: widget.userId,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _showKickAlert(Duration remainingTime) {
    showDialog(
      context: context,
      builder: (context) {
        return Text(
          'You have been kicked from the chat room. You can rejoin in ${remainingTime.inMinutes} minutes.',
        );
      },
    );
  }
}
