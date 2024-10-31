import 'package:flutter/material.dart';
import 'event_page.dart';  // Import EventPage
import 'profile_page.dart'; // Import ProfilePage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const String profileImageUrl = 'https://example.com/profile.jpg';
  static const String userName = 'Memora';
  static const List<Map<String, String>> friends = [
    {'name': '♥ Bea ♥', 'imageUrl': 'assets/images/bea.png','nickname': 'bea', 'birthday': '2002-05-16'},
    {'name': '♥ Kati ♥', 'imageUrl': 'assets/images/kati.png','nickname': 'kati', 'birthday': '2003-09-14'},
    {'name': '♥ Emi ♥', 'imageUrl': 'assets/images/emi.png','nickname': 'emi', 'birthday': '2003-08-19'},
    {'name': '♥ Gyurika ♥', 'imageUrl': 'assets/images/gyurika.png','nickname': 'gyuriiii', 'birthday': '1990-05-08'},
    {'name': 'Friend 5', 'imageUrl': 'https://example.com/friend1.jpg','nickname': 'Johnny', 'birthday': '1990-01-01'},
    {'name': 'Friend 6', 'imageUrl': 'https://example.com/friend2.jpg','nickname': 'Johnny', 'birthday': '1990-01-01'},
  ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      SingleChildScrollView(
        child: Column(
          children: [
            _buildRoundedRectangle('Event 1'),
            _buildRoundedRectangle('Event 2'),
            _buildRoundedRectangle('Event 3'),
            _buildRoundedRectangle('Event 4'),
            _buildRoundedRectangle('Event 5'),
            _buildRoundedRectangle('Event 6'),
          ],
        ),
      ),
      const Center(child: Text('Camera Page')),
      ProfilePage(
        profileImageUrl: profileImageUrl,
        userName: userName,
        friends: friends,
      ),
    ];
  }

  Widget _buildRoundedRectangle(String text) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(
              eventName: text,
              creatorProfileImageUrl: 'https://example.com/creator.jpg',
              isCreator: true,
              date: '2024-10-24',
              location: 'New York, Central Park',
              note: 'Egy példa megjegyzés az eseményhez.',
              participants: [
                Participant(profileImageUrl: 'https://example.com/friend1.jpg', isGoing: true),
                Participant(profileImageUrl: 'https://example.com/friend2.jpg', isGoing: true),
                Participant(profileImageUrl: 'https://example.com/friend1.jpg', isGoing: true),
                Participant(profileImageUrl: 'https://example.com/friend2.jpg', isGoing: false),
                Participant(profileImageUrl: 'https://example.com/friend1.jpg', isGoing: false),
                Participant(profileImageUrl: 'https://example.com/friend2.jpg', isGoing: true),
                Participant(profileImageUrl: 'https://example.com/friend1.jpg', isGoing: true),
                Participant(profileImageUrl: 'https://example.com/friend2.jpg', isGoing: true),
                Participant(profileImageUrl: 'https://example.com/friend1.jpg', isGoing: true),
                Participant(profileImageUrl: 'https://example.com/friend2.jpg', isGoing: false),
                Participant(profileImageUrl: 'https://example.com/friend1.jpg', isGoing: false),
                Participant(profileImageUrl: 'https://example.com/friend2.jpg', isGoing: true),
              ],
              galleryImages: [
                'https://example.com/image1.jpg',
                'https://example.com/image2.jpg',
                'https://example.com/image3.jpg',
                // További képek...
              ],
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
            text,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          _selectedIndex == 0 ? 'Home Page' :
          _selectedIndex == 1 ? 'Camera Page' :
          'Profile',
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
