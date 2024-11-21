import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friend_page.dart'; // Importáljuk a FriendPage-et

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

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
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          userData = data;
        });

        final friendsEmails = (data['friends'] as List<dynamic>).cast<String>();
        await _fetchFriendsData(friendsEmails);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchFriendsData(List<String> emails) async {
    try {
      final List<Map<String, String?>> fetchedData = [];

      for (String email in emails) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final friendData = querySnapshot.docs.first.data();

          fetchedData.add({
            'email': friendData['email'] as String?,
            'username':
            '${friendData['firstName'] ?? ''} ${friendData['lastName'] ?? ''}',
            'imageUrl': friendData['profileImageUrl'] as String?,
          });
        }
      }

      setState(() {
        friendsData = fetchedData;
      });
    } catch (e) {
      print('Error during friends data fetch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: userData!['profileImageUrl'] != null &&
                userData!['profileImageUrl'].startsWith('http')
                ? NetworkImage(userData!['profileImageUrl'])
                : const AssetImage('assets/images/default.png')
            as ImageProvider,
          ),
          const SizedBox(height: 10),
          Text(
            '${userData!['firstName']} ${userData!['lastName']}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Username: ${userData!['username']}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          const Text('Friends:', style: TextStyle(fontSize: 18)),
          Expanded(
            child: ListView.builder(
              itemCount: friendsData.length,
              itemBuilder: (context, index) {
                final friend = friendsData[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend['imageUrl'] != null
                        ? NetworkImage(friend['imageUrl']!)
                        : const AssetImage('assets/images/default.png')
                    as ImageProvider,
                  ),
                  title: Text(friend['username'] ?? 'Unknown User'),
                  subtitle: Text(friend['email'] ?? 'No email'),
                  onTap: () {
                    // Navigáció a FriendPage-re
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendPage(
                          username: friend['username'] ?? 'Unknown User',
                          email: friend['email'] ?? 'No email',
                          imageUrl: friend['imageUrl'],
                        ),
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
