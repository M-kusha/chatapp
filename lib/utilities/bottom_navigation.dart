import 'package:chat/chat/chat_rooms_list.dart';
import 'package:chat/profile/profile.dart';
import 'package:flutter/material.dart';

class BotomNavigation extends StatefulWidget {
  const BotomNavigation({super.key});

  @override
  BotomNavigationState createState() => BotomNavigationState();
}

class BotomNavigationState extends State<BotomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ChatRoomsList(),
    const ProfilePage()
    // const FavoritesPage(),
    // const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped, // Call _onTabTapped when a tab is tapped
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat Rooms',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Search',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_disabled_outlined),
            label: 'Favorites',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}
