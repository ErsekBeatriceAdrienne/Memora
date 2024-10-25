import 'package:flutter/material.dart';
import 'package:friends_with_memories/pages/calendar_page.dart';
import 'package:friends_with_memories/pages/gallery_page.dart';

class ProfilePage extends StatelessWidget {
  final String profileImageUrl;
  final String userName;
  final List<Map<String, String>> friends;

  const ProfilePage({
    super.key,
    required this.profileImageUrl,
    required this.userName,
    required this.friends,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Eltávolítja a vissza nyilat
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit profile logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add friend logic
                  },
                  child: const Text('Add Friend'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarPage()),
                    );
                  },
                  child: const Text('Calendar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryPage()),
                    );
                  },
                  child: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend['imageUrl']!),
                    ),
                    title: Text(friend['name']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
