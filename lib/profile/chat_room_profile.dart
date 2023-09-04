import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> showUserDetails(String userId, BuildContext context) async {
  final localContext = context;

  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  final username = userDoc.get('username');
  final profileImage = userDoc.get('profileImage');
  final userRole = userDoc.get('role');
  bool isFriend = false;
  bool blocked = false;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (Navigator.canPop(localContext)) {
      showDialog(
        context: localContext,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (profileImage != null)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: profileImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person, size: 80),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  'Role: $userRole',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text('Username: $username'),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isFriend == true)
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        onPressed: () {
                          // add friend logic
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.person_remove_alt_1_outlined),
                        onPressed: () {
                          // remove friend logic
                        },
                      ),
                    if (isFriend == true)
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {
                          // chat logic
                        },
                      ),
                    if (blocked == true)
                      IconButton(
                        icon: const Icon(Icons.block_outlined),
                        onPressed: () {
                          // block friend logic
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.app_blocking),
                        onPressed: () {
                          // remove block friend logic
                        },
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  });
}
