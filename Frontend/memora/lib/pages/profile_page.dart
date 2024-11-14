import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memora/cloudinary/cloudinary_service.dart';
import 'package:memora/pages/sign_in_page.dart';
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
  final _cloudinaryService = CloudinaryService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    friends = List.from(widget.friends);
    _fetchProfileImageUrl();
  }

  // Profilkép lekérése a Cloudinary-ról
  Future<void> _fetchProfileImageUrl() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lekérés Cloudinary-ból
      final imageUrl = await _cloudinaryService.getProfileImageUrl(widget.userName);
      setState(() {
        profileImageUrl = imageUrl ?? widget.profileImageUrl;
      });
    } catch (e) {
      // Hiba esetén az alapértelmezett kép URL-t használjuk
      setState(() {
        profileImageUrl = widget.profileImageUrl;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                Navigator.of(context).pop({
                  'name': newFriendName,
                  'imageUrl': newFriendImageUrl
                });
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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SignInPage(),
                  ),
                );
              }
            },
          ),

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: profileImageUrl.startsWith('http')
                  ? NetworkImage(profileImageUrl)
                  : const AssetImage('assets/images/profile.png')
              as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
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
                      MaterialPageRoute(
                          builder: (context) => CalendarPage()),
                    );
                  },
                  child: const Text('Calendar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GalleryPage()),
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
                      backgroundImage:
                      friend['imageUrl']!.startsWith('http')
                          ? NetworkImage(friend['imageUrl']!)
                          : AssetImage(friend['imageUrl']!)
                      as ImageProvider,
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
