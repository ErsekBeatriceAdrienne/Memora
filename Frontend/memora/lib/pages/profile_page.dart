import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'calendar_page.dart';
import 'friend_page.dart';
import 'gallery_page.dart';

class ProfilePage extends StatefulWidget {
  final User user; // Pass the entire user object

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
      // Felhasználó adatainak lekérdezése
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;

        // Barátok emailjeinek kinyerése
        final friendsEmails = (data['friends'] as List<dynamic>).cast<String>();

        setState(() {
          userData = data; // Felhasználó adatai
        });

        // Barátok adatainak lekérdezése
        await _fetchFriendsData(friendsEmails);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchFriendsData(List<String> emails) async {
    try {
      final List<Map<String, String?>> fetchedFriends = [];
      for (final email in emails) {
        // Egyenként lekérdezzük az email alapján a barátokat
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final friendData = querySnapshot.docs.first.data();

          // Az 'birthday' mezőt Timestamp típusúra konvertáljuk, majd String formátumba
          final birthday = friendData['birthday'] != null
              ? (friendData['birthday'] as Timestamp).toDate().toString()
              : 'Unknown birthday';

          fetchedFriends.add({
            'email': friendData['email'] as String?,
            'fullname': friendData['firstName'] + ' ' + friendData['lastName'],
            'imageUrl': friendData['profileImageUrl'] as String?,
            'username': friendData['username'] ?? 'No nickname',
            'birthday': birthday,
          });
        }
      }

      setState(() {
        friendsData = fetchedFriends;
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
            userData!['firstName'] + ' ' + userData!['lastName'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '${userData!['username']}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Add Friend'),
                      content: const TextField(
                        decoration: InputDecoration(
                          labelText: 'Enter email address',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Add friend logic
                            Navigator.pop(context);
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Add Friend'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarPage(),
                    ),
                  );
                },
                child: const Text('Calendar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GalleryPage(),
                    ),
                  );
                },
                child: const Text('Gallery'),
              ),
            ],
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
                  title: Text(friend['fullname'] ?? 'Unknown User'),
                  subtitle: Text(friend['email'] ?? 'No email'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendPage(
                          fullname: friend['fullname'] ?? 'Unknown User',
                          email: friend['email'] ?? 'No email',
                          imageUrl: friend['imageUrl'],
                          username: friend['username'] ?? 'No nickname',
                          birthday: friend['birthday'] ?? 'Unknown birthday',
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
