// settings_page.dart

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool _notifications = true; // Example setting

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Notifications'),
            trailing: Switch(
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
                // You can also add functionality to handle this change, e.g., updating in a database, etc.
              },
            ),
          ),
          // Add more settings options as ListTile items here
          ListTile(
            title: const Text('About'),
            onTap: () {
              // Handle tap, maybe navigate to an 'About' page or show a dialog
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () {
              // Handle tap, maybe navigate to a 'Privacy Policy' page or show a dialog
            },
          ),
        ],
      ),
    );
  }
}
