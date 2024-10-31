import 'package:flutter/material.dart';

class EventPage extends StatelessWidget {
  final String eventName;
  final String creatorProfileImageUrl;
  final bool isCreator;
  final String date; // új: dátum
  final String location; // új: helyszín
  final String note; // új: megjegyzés
  final List<Participant> participants; // új: résztvevők listája
  final List<String> galleryImages; // új: galéria képek

  const EventPage({
    super.key,
    required this.eventName,
    required this.creatorProfileImageUrl,
    required this.isCreator,
    required this.date,
    required this.location,
    required this.note,
    required this.participants, // új: résztvevők
    required this.galleryImages, // új: galéria
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        actions: [
          isCreator
              ? IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Szerkesztési logika
            },
          )
              : CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(creatorProfileImageUrl),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Helyszín megjelenítése
            Row(
              children: [
                Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Note megjelenítése
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                note,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Résztvevők profilképei és státuszuk
            Text(
              'Meghívottak:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Görgethető vízszintes lista a profilképeknek
            SizedBox( // Korlátozzuk a lista magasságát
              height: 70, // Állítsd be a kívánt magasságot
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Vízszintes görgetés
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        CircleAvatar(
                          radius: 30, // Növeld a kör alakú képek méretét
                          backgroundImage: NetworkImage(participant.profileImageUrl),
                        ),
                        // Státuszjelző
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: participant.isGoing ? Colors.green : Colors.red,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Galéria megjelenítése
            Text(
              'Galéria:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Függőleges görgethető lista a galéria képeinek
            Expanded(
              child: ListView.builder(
                itemCount: galleryImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.network(
                      galleryImages[index],
                      fit: BoxFit.cover,
                    ),
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

class Participant {
  final String profileImageUrl;
  final bool isGoing;

  Participant({
    required this.profileImageUrl,
    required this.isGoing,
  });
}
