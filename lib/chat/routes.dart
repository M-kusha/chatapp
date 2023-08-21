import 'package:chat/chat/home.dart';
import 'package:chat/chat/login.dart';
import 'package:chat/chat/profile.dart';
import 'package:chat/chat/register.dart';
import 'package:chat/chat/settings.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes() {
    return {
      '/home': (context) => const Home(),
      '/profile': (context) => const ProfilePage(),
      '/settings': (context) => const SettingsPage(),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
    };
  }
}
