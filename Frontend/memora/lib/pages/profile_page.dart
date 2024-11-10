//profile
import 'package:flutter/material.dart';

import 'calendar_page.dart';
import 'edit_profile.dart';
import 'friend_page.dart';
import 'gallery_page.dart';

class ProfilePage extends StatefulWidget {
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
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String profileImageUrl;
  late String userName;
  late List<Map<String, String>> friends;

  @override
  void initState() {
    super.initState();
    profileImageUrl = widget.profileImageUrl;
    userName = widget.userName;
    friends = List.from(widget.friends); // Deep copy to prevent modifying the original list
  }

  void _addFriend() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        String newFriendName = '';
        String newFriendImageUrl = '';

        return AlertDialog(
          title: const Text('Add Friend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Friend Name'),
                onChanged: (value) {
                  newFriendName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Friend Image URL'),
                onChanged: (value) {
                  newFriendImageUrl = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({'name': newFriendName, 'imageUrl': newFriendImageUrl});
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        friends.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    initialProfileImageUrl: profileImageUrl,
                    initialUserName: userName,
                  ),
                ),
              );

              if (result != null) {
                setState(() {
                  userName = result['userName'];
                  profileImageUrl = result['profileImageUrl'];
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile.png'),
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
                  onPressed: _addFriend,
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
                      backgroundImage: friend['imageUrl']!.startsWith('http')
                          ? NetworkImage(friend['imageUrl']!)
                          : AssetImage(friend['imageUrl']!) as ImageProvider,
                    ),
                    title: Text(friend['name']!),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendPage(
                            name: friend['name']!,
                            nickname: friend['nickname'] ?? 'N/A',
                            birthday: friend['birthday'] ?? 'N/A',
                            areFriends: true,
                            imageUrl: friend['imageUrl']!,
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
      ),
    );
  }
}
