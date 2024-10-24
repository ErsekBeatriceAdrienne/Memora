import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String profileImageUrl;
  final String userName;
  final List<Map<String, String>> friends; // Minden barát: {'name': 'Nev', 'imageUrl': 'KepLink'}

  ProfilePage({
    required this.profileImageUrl,
    required this.userName,
    required this.friends,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profilkép
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            SizedBox(height: 16),
            // Felhasználó neve
            Text(
              userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Gombok
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Szerkesztés logika
                  },
                  child: Text('Szerkesztés'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Barát hozzáadása logika
                  },
                  child: Text('Barát hozzáadása'),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Barátok listája
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
