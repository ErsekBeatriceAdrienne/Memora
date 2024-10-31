import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FriendPage extends StatelessWidget {
  final String name;
  final String nickname;
  final String birthday;
  final bool areFriends;
  final String imageUrl;

  const FriendPage({
    Key? key,
    required this.name,
    required this.nickname,
    required this.birthday,
    required this.areFriends,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profilkép és adatok
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nickname: $nickname'),
                      Text('Birthday: $birthday'),
                      Text('We are friends: ${areFriends ? 'Yes' : 'No'}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Kétsoros naptár
            const Text(
              'Calendar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 300, // Csökkentett magasságú naptár
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 1, 1),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month, // Heti formátum, hogy két sorban jelenjen meg
                headerVisible: false,
                daysOfWeekVisible: true,
                availableGestures: AvailableGestures.none,
              ),
            ),
            const SizedBox(height: 20),

            // Galéria
            const Text(
              'Gallery',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3, // Három oszlop
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                children: List.generate(6, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://picsum.photos/200?image=${index + 1}'), // Helyettesítő kép URL
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
