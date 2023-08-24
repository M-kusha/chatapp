import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SideNavigationBar extends StatefulWidget {
  final Future<void> Function() handleLogout;

  const SideNavigationBar({
    Key? key,
    required this.handleLogout,
  }) : super(key: key);

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarState();
}

class _SideNavigationBarState extends State<SideNavigationBar> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get()
          .then((snapshot) => snapshot.data() as Map<String, dynamic>),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.containsKey('username')) {
          return const Center(child: Text('User data not found.'));
        }

        final userData = snapshot.data!;

        return Drawer(
          width: 70,
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userData['profileImage'] != null
                          ? NetworkImage(userData['profileImage'])
                          : null,
                      child: userData['profileImage'] == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              ListTile(
                title: const Icon(Icons.chat_bubble_outline),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chatrooms',
                  );
                },
              ),
              ListTile(
                title: const Icon(Icons.chat_sharp),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/privatemessages',
                  );
                },
              ),
              ListTile(
                title: const Icon(Icons.person),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/profile',
                  );
                },
              ),
              ListTile(
                title: const Icon(Icons.settings),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/settings',
                  );
                },
              ),
              ListTile(
                title: const Icon(Icons.logout),
                onTap: () {
                  widget.handleLogout(); // Call the provided logout function
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
