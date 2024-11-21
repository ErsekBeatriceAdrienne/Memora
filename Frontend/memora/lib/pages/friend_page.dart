import 'package:flutter/material.dart';

class FriendPage extends StatelessWidget {
  final String username;
  final String email;
  final String? imageUrl;

  const FriendPage({
    super.key,
    required this.username,
    required this.email,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : const AssetImage('assets/images/default.png')
              as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
