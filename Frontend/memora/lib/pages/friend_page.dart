import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importáljuk az intl csomagot

class FriendPage extends StatelessWidget {
  final String fullname;
  final String email;
  final String? imageUrl;
  final String username; // Új mező
  final String birthday; // Új mező

  const FriendPage({
    super.key,
    required this.fullname,
    required this.email,
    this.imageUrl,
    required this.username, // Új paraméter
    required this.birthday, // Új paraméter
  });

  @override
  Widget build(BuildContext context) {
    // Születési dátum formázása
    DateTime birthdayDate = DateTime.parse(birthday);
    String formattedBirthday = DateFormat('yyyy.MM.dd').format(birthdayDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(fullname),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // A kép teteje és szöveg teteje összehangolása
          children: [
            // Kép a bal oldalon
            CircleAvatar(
              radius: 60,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : const AssetImage('assets/images/default.png')
              as ImageProvider,
            ),
            const SizedBox(width: 20), // Kép és szöveg közötti távolság
            // A szövegek középre igazítva
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Kép és szöveg középre igazítása
                children: [
                  Text(
                    '$username',
                    style: const TextStyle(fontSize: 25),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Birthday: $formattedBirthday', // Formázott születési dátum
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: $email',
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
