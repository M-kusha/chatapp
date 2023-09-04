import 'package:chat/chat/chat_utilities/check_ban_kick_alert.dart';
import 'package:chat/chat/message_input.dart';
import 'package:chat/chat/message_list.dart';
import 'package:chat/chat/chat_utilities/chat_utils.dart';
import 'package:chat/utilities/side_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String roomId;
  final String userId;

  const ChatRoom({Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.roomId == 'general'
            ? const Text('General Chat')
            : const Text('Chat Room'),
        centerTitle: true,
      ),
      drawer: SideNavigationBar(
        handleLogout: () async {
          await FirebaseAuth.instance.signOut();
        },
      ),
      body: StreamBuilder<KickStatus>(
        stream: kickStatusStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Handle loading state
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final kickStatus = snapshot.data!;
            if (kickStatus.isKicked) {
              final remainingTime =
                  kickStatus.kickExpiration.difference(DateTime.now());

              _showKickAlert(remainingTime);

              // Immediately navigate out of the chat room
              _navigateOutOfChatRoom();

              // Return an empty widget
              return const SizedBox();
            }

            // Render the chat room if not kicked
            return Column(
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

  void _navigateOutOfChatRoom() {
    setState(() {
      // Clear the message input controller if needed
      _messageController.clear();
    });

    Navigator.pop(context);
  }
}
