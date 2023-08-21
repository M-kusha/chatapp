import 'package:chat/chat/side_navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleLogout() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page"), centerTitle: true),
      drawer: SideNavigationBar(
        handleLogout: _handleLogout,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text("Welcome to the Home Page"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogout,
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
