import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendPage extends StatelessWidget {
  final String friendEmail;

  const FriendPage({super.key, required this.friendEmail});

  Future<Map<String, dynamic>> _fetchFriendData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendEmail)
        .get();

    if (snapshot.exists) {
      return snapshot.data()!;
    } else {
      throw Exception('Friend not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchFriendData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final friendData = snapshot.data!;
          final profileImageUrl = friendData['profileImageUrl'] as String?;
          final fullName =
          '${friendData['firstName'] ?? ''} ${friendData['lastName'] ?? ''}'.trim();
          final friendshipDate = friendData['friendshipDate'] ?? 'Unknown';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null && profileImageUrl.startsWith('http')
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('assets/images/default_friend.png') as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Friend since: $friendshipDate'),
                const SizedBox(height: 30),
                Text('Email: $friendEmail'),
              ],
            ),
          );
        },
      ),
    );
  }
}
