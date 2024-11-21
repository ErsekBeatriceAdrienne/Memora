import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friend_page.dart';

class ProfilePage extends StatefulWidget {
  final String email; // Az email alapján azonosítjuk a felhasználót

  const ProfilePage({super.key, required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  List<Map<String, String?>> friendsData = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Felhasználó adatainak lekérdezése az email alapján
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          userData = data;
        });

        // Barátok adatainak lekérdezése
        final friendsEmails = (data['friends'] as List<dynamic>).cast<String>();
        await _fetchFriendsData(friendsEmails);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchFriendsData(List<String> emails) async {
    final List<Map<String, String?>> fetchedData = [];

    for (final email in emails) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          fetchedData.add({
            'email': email,
            'username': data['username'] as String?,
            'imageUrl': data['profileImageUrl'] as String?,
          });
        } else {
          fetchedData.add({
            'email': email,
            'username': 'Unknown User',
            'imageUrl': null,
          });
        }
      } catch (e) {
        fetchedData.add({
          'email': email,
          'username': 'Unknown User',
          'imageUrl': null,
        });
      }
    }

    setState(() {
      friendsData = fetchedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: userData!['profileImageUrl'] != null &&
                userData!['profileImageUrl'].startsWith('http')
                ? NetworkImage(userData!['profileImageUrl'])
                : const AssetImage('assets/images/profile.png') as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(
            userData!['username'] ?? 'Unknown User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: friendsData.length,
              itemBuilder: (context, index) {
                final friend = friendsData[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend['imageUrl'] != null
                        ? NetworkImage(friend['imageUrl']!)
                        : const AssetImage('assets/images/default_friend.png') as ImageProvider,
                  ),
                  title: Text(friend['username'] ?? 'Unknown User'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FriendPage(friendEmail: friend['email']!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
