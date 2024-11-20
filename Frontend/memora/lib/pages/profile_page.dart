import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late List<Map<String, String?>> friends; // Allow nullable values in friends map
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    friends = List.from(widget.friends);
    profileImageUrl = widget.profileImageUrl; // Initialize with the passed URL
  }

  Future<void> _addFriend(String email) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();

        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId != null) {
          await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
            'friends': FieldValue.arrayUnion([email]),
          });

          setState(() {
            friends.add({
              'name': userData['name'] ?? 'Unknown',
              'imageUrl': userData['profileImageUrl'] ?? '',
              'email': email,
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barát sikeresen hozzáadva!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A megadott email cím nem található!')),
        );
      }
    } catch (e) {
      print('Hiba a barát hozzáadásakor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hiba történt a barát hozzáadásakor!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email cím',
              hintText: 'Adja meg a barát email címét',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Mégse'),
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  Navigator.pop(context); // Bezárja a párbeszédablakot
                  await _addFriend(email);
                  _emailController.clear(); // Tisztítja a mezőt
                }
              },
              child: const Text('Hozzáadás'),
            ),
          ],
        );
      },
    );
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
                  : const AssetImage('assets/images/gyurika.png') as ImageProvider,
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
                  onPressed: _showAddFriendDialog,
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
                      backgroundImage: friend['imageUrl'] != null && friend['imageUrl']!.startsWith('http')
                          ? NetworkImage(friend['imageUrl']!)
                          : const AssetImage('assets/images/gyurika.png') as ImageProvider,
                    ),
                    title: Text(friend['name'] ?? 'Unknown'),
                    onTap: () {
                      // Logoljuk a kiválasztott barát teljes adatát (a barát emailje, neve és egyéb adatok)
                      print('Kiválasztott barát adatainak átadása: ${friend}');

                      // Navigálás a barát adatainak megjelenítésére
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendPage(
                            friendData: friend, // Az egész barát adatát átadjuk
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
