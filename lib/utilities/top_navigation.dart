import 'package:flutter/material.dart';

class TopNavigation extends StatefulWidget {
  const TopNavigation({Key? key}) : super(key: key);

  @override
  State<TopNavigation> createState() => _TopNavigationState();
}

class _TopNavigationState extends State<TopNavigation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showProfileMenu() {
    // Implementation of profile menu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Navigation'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Align(
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TabBar(
                    indicatorColor: Colors.green,
                    controller: _tabController,
                    indicator: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.chat, color: Colors.white)),
                      Tab(icon: Icon(Icons.mail, color: Colors.white)),
                      Tab(icon: Icon(Icons.group, color: Colors.white)),
                    ],
                    onTap: (index) {
                      _tabController.animateTo(index);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: _showProfileMenu,
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Chat Room')),
          Center(child: Text('Private Chats')),
          Center(child: Text('Friends')),
        ],
      ),
    );
  }
}
