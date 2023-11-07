import 'package:chat/chat/chat_room.dart';
import 'package:chat/chat/chat_rooms_list.dart';
import 'package:chat/login/change_password.dart';
import 'package:chat/login/reset_password.dart';
import 'package:chat/login/reset_verification.dart';
import 'package:chat/profile/profile.dart';
import 'package:chat/login/register.dart';
import 'package:chat/utilities/settings.dart';
import 'package:flutter/material.dart';
import 'package:chat/login/login.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes() {
    return {
      '/chatroom': (context) => const ChatRoom(
            roomId: '',
            userId: '',
          ),
      '/chatrooms': (context) => const ChatRoomsList(),
      '/profile': (context) => const ProfilePage(),
      '/settings': (context) => const SettingsPage(),
      '/login': (context) => const LoginPage(
            message: '',
          ),
      '/register': (context) => const RegisterPage(),
      '/reset_password': (context) => const ResetPasswordPage(),
      '/ResetPasswordVerificationPage': (context) =>
          const ResetPasswordVerificationPage(),
      '/ChangePasswordPage': (context) => const ChangePasswordPage(),
    };
  }
}
