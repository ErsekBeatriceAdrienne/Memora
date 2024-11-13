//home page
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_event_page.dart';
import 'event_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userData;

  const HomePage({Key? key, required this.user, required this.userData})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _buildHomeContent(),
      const Center(child: Text('Camera Page')),
      ProfilePage(
        profileImageUrl: widget.userData['profileImageUrl'] ?? '',
        userName: widget.userData['username'] ?? 'N/A',
        friends: [
          {'name': '♥ Emi ♥', 'imageUrl': 'assets/images/emi.png', 'nickname': 'emi', 'birthday': '2002-05-16'},
          {'name': '♥ Kati ♥', 'imageUrl': 'assets/images/kati.png', 'nickname': 'kati', 'birthday': '2003-09-14'},
        ],
      ),
    ];
  }

  // HomePage tartalom dinamikus töltése Firestore-ból
  Widget _buildHomeContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hiba történt: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nincsenek események.'));
        }

        var events = snapshot.data!.docs.map((doc) {
          var eventData = doc.data() as Map<String, dynamic>;
          return eventData;
        }).toList();

        return SingleChildScrollView(
          child: Column(
            children: events.map<Widget>((event) {
              return _buildRoundedRectangle(
                event['eventName'] ?? 'N/A',
                event['creatorProfileImageUrl'] ?? '',
                event['date'] ?? 'N/A',
                event['location'] ?? 'N/A',
                event['note'] ?? 'N/A',
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRoundedRectangle(String eventName, String profileImageUrl, String date, String location, String note) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(
              eventName: eventName,
              creatorProfileImageUrl: profileImageUrl,
              isCreator: true,
              date: date,
              location: location,
              note: note,
              participants: [], // Dinamikusan tölthetjük fel
              galleryImages: [], // Galéria képek
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        padding: const EdgeInsets.all(30),
        height: 130,
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            eventName,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Home Page' :
          _selectedIndex == 1 ? 'Camera Page' : 'Profile',
        ),
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purpleAccent,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventPage(userId: widget.user.uid),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
