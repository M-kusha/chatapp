// ignore_for_file: use_build_context_synchronously

import 'package:chat/login/login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoom extends StatefulWidget {
  final String roomId;
  final String userId;

  const ChatRoom({Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  bool isAdmin = false;
  bool isModerator = false;

  Future<void> promoteUser(String userUid, String newRole) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    if (userDoc.exists) {
      await userDoc.reference.update({
        'role': newRole,
      });
    } else {
      print("User not found.");
    }
  }

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    final userRole = userDoc.get('role');
    setState(() {
      isAdmin = userRole == 'admin' || userRole == 'superadmin';
      isModerator = userRole == 'moderator';
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.roomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> kickUser(String userId) async {
    const kickDuration = Duration(minutes: 15);
    final kickExpiration = DateTime.now().add(kickDuration);

    await _updateUserOnlineStatus(userId);
    await _updateUserKickExpiration(context, userId, kickExpiration);

    if (widget.userId == widget.userId) {
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> muteUser(String userId) async {
    const muteDuration = Duration(minutes: 5);
    final muteExpiration = DateTime.now().add(muteDuration);

    await _updateUserOnlineStatus(userId);
    await _updateUserMuteExpiration(userId, muteExpiration);
  }

  Future<void> banUser(String userId) async {
    const banDuration = Duration(days: 2);
    final banExpiration = DateTime.now().add(banDuration);

    await _updateUserOnlineStatus(userId);
    await _updateUserBanExpiration(context, userId, banExpiration);
  }

  Future<void> _updateUserOnlineStatus(String userId) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.roomId)
        .update({
      'users_online': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> _updateUserKickExpiration(
      BuildContext context, String messageSender, DateTime expiration) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && currentUser.uid == messageSender) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(messageSender)
          .update({
        'kickExpiration': expiration,
      });

      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LoginPage(message: 'You have been kicked.'),
        ),
      );
    }
  }

  Future<void> _updateUserBanExpiration(
      BuildContext context, String userId, DateTime expiration) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'banExpiration': expiration,
    });
    if (widget.userId == userId) {
      await FirebaseAuth.instance.signOut();

      // After signing out, you can navigate to the login screen and show a message.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LoginPage(message: 'You have been banned.'),
        ),
      );
    }
  }

  Future<void> _invokeOptionsDialog(String messageSender) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final currentUserRole =
          userDoc.get('role'); // Replace 'role' with your role field name

      _showOptionsDialog(messageSender, context, currentUserRole);
    }
  }

  Future<void> _updateUserMuteExpiration(
      String userId, DateTime expiration) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'muteExpiration': expiration,
    });
  }

  final TextEditingController _messageController = TextEditingController();

  Future<void> sendMessage() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    final isMuted = isUserMuted(userDoc.data() ?? {});

    if (isMuted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are currently muted and cannot send messages.'),
        ),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final username = userDoc.get('username') ?? 'DefaultUsername';
      final profileImage = userDoc.get('profileImage') ??
          'https://firebasestorage.googleapis.com/v0/b/albanur-ks2008.appspot.com/o/profile_images%2FNGpHosH2fRTkfN3eZxr5VXxOc802?alt=media&token=4b291d96-d9cf-4dc6-b4d1-5508f8592b2e'; // Replace 'default_image_url' with the URL of your default image.

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.roomId)
          .collection('messages')
          .add({
        'text': messageText,
        'senderId': widget.userId,
        'username': username,
        'profileImage': profileImage,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Room")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
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
                            _showUserDetails(messageSender);
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!isCurrentUser)
                                    Text(
                                      '$messageSenderName',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if ((isAdmin || isModerator) &&
                                      !isCurrentUser)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        deleteMessage(message.id);
                                      },
                                    ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              ),
                            ],
                          ),
                        ),
                        if (!isCurrentUser)
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              _invokeOptionsDialog(messageSender);
                            },
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserDetails(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final username = userDoc.get('username');
    final birthdate = userDoc.get('birthdate');
    final phoneNumber = userDoc.get('phoneNumber');
    final profileImage = userDoc.get('profileImage');

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
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
                Text('Birthdate: $birthdate'),
                Text('Phone Number: $phoneNumber'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showOptionsDialog(String messageSender, BuildContext context,
      String currentUserRole) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final currentUserRole = userDoc.get('role');

    final isAdmin = currentUserRole == 'admin';
    final isModerator = currentUserRole == 'moderator';
    final isSuperAdmin = currentUserRole == 'superadmin';

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if ((isSuperAdmin || isAdmin || isModerator))
              ListTile(
                leading: const Icon(Icons.volume_off),
                title: const Text('Mute User'),
                onTap: () {
                  // Replace with your muteUser function
                  Navigator.pop(context);
                },
              ),
            if ((isSuperAdmin || isAdmin || isModerator))
              ListTile(
                leading: const Icon(Icons.person_remove),
                title: const Text('Kick User'),
                onTap: () {
                  // Replace with your kickUser function
                  Navigator.pop(context);
                },
              ),
            if ((isSuperAdmin || isAdmin))
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Ban User'),
                onTap: () {
                  // Replace with your banUser function
                  Navigator.pop(context);
                },
              ),
            if (isSuperAdmin)
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: const Text('Promote User'),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings),
                            title: const Text('Admin'),
                            onTap: () {
                              promoteUser(messageSender, 'admin');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.military_tech),
                            title: const Text('Moderator'),
                            onTap: () {
                              promoteUser(messageSender, 'moderator');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('User'),
                            onTap: () {
                              promoteUser(messageSender, 'user');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  bool isUserMuted(Map<String, dynamic> userData) {
    final muteExpiration = userData['muteExpiration'] as Timestamp?;
    if (muteExpiration != null &&
        muteExpiration.toDate().isAfter(DateTime.now())) {
      return true; // User is muted
    }
    return false; // User is not muted or mute expired
  }
}
