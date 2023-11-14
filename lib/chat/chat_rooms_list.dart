import 'package:chat/chat/chat_room.dart';
import 'package:chat/chat/chat_utilities/chat_utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomsList extends StatefulWidget {
  const ChatRoomsList({Key? key}) : super(key: key);

  @override
  ChatRoomsListState createState() => ChatRoomsListState();
}

class ChatRoomsListState extends State<ChatRoomsList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    checkAdmin(_auth.currentUser!.uid).then((value) {
      setState(() {
        isSuperAdmin = value;
      });
    });
  }

  void redirectToChatRoom(
    String roomId,
    String userId,
    String roomName,
    bool isLocked,
  ) async {
    if (isLocked) {
      await showDialog(
        context: context,
        builder: (context) {
          final passwordController = TextEditingController();
          bool isPasswordValid = true;

          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blueGrey,
                        Color.fromARGB(255, 71, 124, 150),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Enter Password',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: 'Room Password',
                            errorText:
                                isPasswordValid ? null : 'Invalid Password',
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.white),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () async {
                                final enteredPassword =
                                    passwordController.text.trim();
                                final roomRef = _firestore
                                    .collection('chat_rooms')
                                    .doc(roomId);
                                final roomSnapshot = await roomRef.get();

                                if (roomSnapshot.exists) {
                                  final correctPassword =
                                      roomSnapshot.get('password');

                                  if (enteredPassword == correctPassword) {
                                    increasOnlineUsersCount(roomId);
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRoom(
                                          roomId: roomId,
                                          userId: userId,
                                          roomName: roomName,
                                          isLocked: isLocked,
                                        ),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      isPasswordValid = false;
                                    });
                                  }
                                }
                              },
                              child: const Text('Submit',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      increasOnlineUsersCount(roomId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoom(
            roomId: roomId,
            userId: userId,
            roomName: roomName,
            isLocked: isLocked,
          ),
        ),
      );
    }
  }

  void increasOnlineUsersCount(String roomId) {
    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    roomRef.update({
      'online_users_count': FieldValue.increment(1),
    });
  }

  Future<void> createNewChatRoom() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isLocked = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueGrey,
                      Color.fromARGB(255, 71, 124, 150),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Create New Chat Room',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Room Name',
                            prefixIcon: Icon(Icons.chat, color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Room Description',
                            prefixIcon:
                                Icon(Icons.description, color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        if (isLocked)
                          TextFormField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              hintText: 'Enter Room Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Do you want it locked?',
                                style: TextStyle(color: Colors.white)),
                            Switch(
                              value: isLocked,
                              onChanged: (value) {
                                setState(() {
                                  isLocked = value;
                                });
                              },
                              activeColor: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () async {
                                final name = nameController.text.trim();
                                final description =
                                    descriptionController.text.trim();
                                final password = passwordController.text.trim();

                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter room name'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final userId = _auth.currentUser!.uid;
                                final roomId = FirebaseFirestore.instance
                                    .collection('chat_rooms')
                                    .doc()
                                    .id;

                                await _firestore
                                    .collection('chat_rooms')
                                    .doc(roomId)
                                    .set({
                                  'name': name,
                                  'created_at': FieldValue.serverTimestamp(),
                                  'creator_id': userId,
                                  'description': description,
                                  'online_users_count': 0,
                                  'active_users': [],
                                  'is_locked': isLocked,
                                  'password': isLocked ? password : null,
                                });

                                redirectToChatRoom(
                                  roomId,
                                  userId,
                                  name,
                                  isLocked,
                                );
                                Navigator.pop(context);
                              },
                              child: const Text('Create',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms', style: TextStyle(color: Colors.white)),
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chat_rooms').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final roomDoc = rooms[index];
              final roomId = roomDoc.id;
              final roomName = roomDoc.get('name');
              final roomDescription =
                  roomDoc.get('description') ?? 'No description available';
              final onlineUsersCount = roomDoc.get('online_users_count') ?? 0;
              final isLocked = roomDoc.get('is_locked') ?? false;

              return GestureDetector(
                onTap: () => redirectToChatRoom(
                  roomId,
                  userId,
                  roomName,
                  isLocked,
                ),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            roomName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          roomDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Online Users: $onlineUsersCount',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                              ),
                            ),
                            if (isLocked)
                              const Icon(
                                Icons.lock_clock_outlined,
                                color: Colors.white60,
                              )
                            else
                              const Icon(
                                Icons.lock_open,
                                color: Colors.white60,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isSuperAdmin ? _buildAddRoomButton() : null,
    );
  }

  Widget _buildAddRoomButton() {
    return FloatingActionButton(
      onPressed: () => createNewChatRoom(),
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.add),
    );
  }
}
