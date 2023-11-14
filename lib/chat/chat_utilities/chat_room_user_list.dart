import 'package:flutter/material.dart';

class UserListDrawer extends StatelessWidget {
  final List<String> usernames;
  final List<bool> isBlockedStatus;
  final Function(int) onProfilePressed;
  final Function(int) onAddFriendPressed;
  final Function(int, bool) onBlockToggle;

  const UserListDrawer({
    super.key,
    required this.usernames,
    required this.isBlockedStatus,
    required this.onProfilePressed,
    required this.onAddFriendPressed,
    required this.onBlockToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // Customize header background color
            ),
            child: Text(
              'Joined Users',
              style: TextStyle(
                color: Colors.white, // Customize header text color
                fontSize: 20,
              ),
            ),
          ),
          // Display the list of joined users
          for (var i = 0; i < usernames.length; i++)
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(usernames[i]),
              trailing: PopupMenuButton<int>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: const Text('Profile'),
                    onTap: () => onProfilePressed(i),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: const Text('Add Friend'),
                    onTap: () => onAddFriendPressed(i),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: isBlockedStatus[i]
                        ? const Text('Unblock')
                        : const Text('Block'),
                    onTap: () {
                      onBlockToggle(i, !isBlockedStatus[i]);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
