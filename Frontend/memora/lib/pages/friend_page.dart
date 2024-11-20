import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {
  final Map<String, String?> friendData; // A barát adatainak tárolása

  const FriendPage({
    Key? key,
    required this.friendData, // A barát adatainak átadása
  }) : super(key: key);

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Itt lehetne adatlekérés, de mivel már átadjuk a teljes barát adatot, nincs szükség adatbázis lekérésre.
  }

  @override
  Widget build(BuildContext context) {
    final friendData = widget.friendData; // A barát adatai

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(friendData['name'] ?? 'Friend Details'), // A barát neve, ha van
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profilkép és adatok megjelenítése
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: friendData['imageUrl'] != null && friendData['imageUrl']!.startsWith('http')
                      ? NetworkImage(friendData['imageUrl']!)
                      : const AssetImage('assets/images/gyurika.png') as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${friendData['name'] ?? 'N/A'}'), // Barát neve
                      Text('Email: ${friendData['email'] ?? 'N/A'}'), // Barát email cím
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Bármilyen további adat megjelenítése, ha szükséges
            const Text(
              'Friend Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Itt további információk is elhelyezhetőek, ha szükséges
            // Például a barát születési dátuma, cím stb.
          ],
        ),
      ),
    );
  }
}
