import 'package:flutter/material.dart';
import 'event_page.dart';
import 'profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRoundedRectangle('Event 1'),
          _buildRoundedRectangle('Event 2'),
        ],
      ),
    );
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
              participants: [],
              galleryImages: [],
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
    );
  }
}
