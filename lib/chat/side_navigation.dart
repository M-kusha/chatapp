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

  Future<Map<String, dynamic>> getUserData() async {
    if (_user == null) {
      throw Exception('User not logged in!');
    }
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();
    return userDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
              child: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Drawer(child: Center(child: Text('Error: ${snapshot.error}')));
        }

        final userData = snapshot.data!;
        final profileImageUrl = userData['profileImage'] ?? '';
        final userName = userData['username'] ?? '';

        return Drawer(
          width: 70,
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(profileImageUrl),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              ListTile(
                title: const Icon(Icons.home),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/home',
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
