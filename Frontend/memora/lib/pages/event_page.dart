import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  final String eventName;
  final String creatorProfileImageUrl;
  final bool isCreator;
  final String date;
  final String location;
  final String note;
  final List<String> galleryImages;

  const EventPage({
    super.key,
    required this.eventName,
    required this.creatorProfileImageUrl,
    required this.isCreator,
    required this.date,
    required this.location,
    required this.note,
    required this.galleryImages,
  });

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, String>> participantsData = []; // Tárolja a résztvevők adatait
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants() async {
    try {
      // Lekérjük az eseményt az adatbázisból
      final eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('eventName', isEqualTo: widget.eventName)
          .limit(1)
          .get();

      if (eventSnapshot.docs.isNotEmpty) {
        final eventDoc = eventSnapshot.docs.first;
        final participantsEmails = List<String>.from(eventDoc.data()['participants'] ?? []);

        // Résztvevők adatainak lekérése
        final List<Map<String, String>> fetchedParticipants = [];
        for (var email in participantsEmails) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            final userData = userSnapshot.docs.first.data();
            fetchedParticipants.add({
              'email': email,
              'imageUrl': userData['profileImageUrl'] ?? '',
            });
          }
        }

        setState(() {
          participantsData = fetchedParticipants;
        });
      }
    } catch (e) {
      print('Hiba a résztvevők lekérésekor: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _inviteParticipant() async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        // Keresés a felhasználók között a megadott email cím alapján
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userDoc = userSnapshot.docs.first;

          // Keresés az események között a 'eventName' alapján
          final eventSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .where('eventName', isEqualTo: widget.eventName)
              .limit(1)
              .get();

          if (eventSnapshot.docs.isNotEmpty) {
            final eventDoc = eventSnapshot.docs.first;

            // Résztvevők frissítése az esemény dokumentumában
            await FirebaseFirestore.instance
                .collection('events')
                .doc(eventDoc.id)
                .update({
              'participants': FieldValue.arrayUnion([email]),
            });

            // Résztvevők frissítése az UI-n
            setState(() {
              participantsData.add({
                'email': email,
                'imageUrl': userDoc.data()['profileImageUrl'] ?? '',
              });
            });

            // Töröljük az email mezőt
            _emailController.clear();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meghívás sikeresen elküldve!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Esemény nem található!')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A megadott email cím nem található!')),
          );
        }
      } catch (e) {
        print('Hiba történt a meghívás során: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hiba történt a meghívás során!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
        actions: [
          widget.isCreator
              ? IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Szerkesztési logika
            },
          )
              : CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(widget.creatorProfileImageUrl),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Az esemény dátuma, helyszíne, megjegyzés stb.
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  widget.date,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.location,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                widget.note,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Meghívás email alapú
            if (widget.isCreator)
              Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Meghívó email címe',
                      hintText: 'Email cím',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _inviteParticipant,
                    child: const Text('Meghívás'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Résztvevők listája vízszintesen
            Text(
              'Meghívottak:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: participantsData.length,
                itemBuilder: (context, index) {
                  final participant = participantsData[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: participant['imageUrl'] != null &&
                          participant['imageUrl']!.isNotEmpty
                          ? NetworkImage(participant['imageUrl']!)
                          : const AssetImage('assets/images/default_friend.png')
                      as ImageProvider,
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
