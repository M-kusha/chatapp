import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/utilities/side_navigation.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showUserDetails(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final username = userDoc.get('username');
    final country = userDoc.get('country');
    final birthdate = userDoc.get('birthdate');
    final phoneNumber = userDoc.get('phoneNumber');
    final profileImage = userDoc.get('profileImage');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(username),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (profileImage != null)
                CachedNetworkImage(
                  imageUrl: profileImage,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),
              Text('Country: $country'),
              Text('Birthdate: $birthdate'),
              Text('Phone Number: $phoneNumber'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final userDoc =
          await _firestore.collection('users').doc(widget.userId).get();
      final username = userDoc.get('username') ?? 'DefaultUsername';

      await _firestore
          .collection('chatrooms')
          .doc(widget.roomId)
          .collection('messages')
          .add({
        'text': messageText,
        'senderId': widget.userId,
        'username': username,
        'profileImage': userDoc.get('profileImage'),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Room")),
      drawer: SideNavigationBar(
        handleLogout: () async {
          await FirebaseAuth.instance.signOut();
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatrooms')
                  .doc(widget.roomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final messages = snapshot.data!.docs;
                final messageWidgets = messages.map((message) {
                  final messageText = message.get('text');
                  final messageSender = message.get('senderId');
                  final messageSenderName = message.get('username');
                  final profileImage = message.get('profileImage');
                  final isCurrentUser = widget.userId == messageSender;
                  final timestamp = message.get('timestamp') as Timestamp?;
                  final formattedDate = timestamp != null
                      ? DateFormat('hh:mm ').format(timestamp.toDate())
                      : 'Unknown time';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: isCurrentUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            if (!isCurrentUser) {
                              _showUserDetails(messageSender);
                            }
                          },
                          child: Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: CircleAvatar(
                              backgroundImage: profileImage != null
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage == null
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Column(
                          children: [
                            Container(
                              alignment: isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.blue
                                    : Colors.grey[300],
                                borderRadius: isCurrentUser
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                      )
                                    : const BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                      ),
                              ),
                              child: Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isCurrentUser)
                                    Text(
                                      '$messageSenderName',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList();

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    reverse: true,
                    children: messageWidgets,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Enter your message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
