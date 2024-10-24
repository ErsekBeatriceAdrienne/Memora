import 'package:flutter/material.dart';
import 'package:friends_with_memories/pages/profile_page.dart'; // Import ProfilePage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Create a list of pages, including the ProfilePage
  static const String profileImageUrl = 'https://example.com/profile.jpg';
  static const String userName = 'John Doe';
  static const List<Map<String, String>> friends = [
    {'name': '♥ Bea ♥', 'imageUrl': 'https://example.com/friend1.jpg'},
    {'name': '♥ Kati ♥', 'imageUrl': 'https://example.com/friend2.jpg'},
    {'name': '♥ Emi ♥', 'imageUrl': 'https://example.com/friend1.jpg'},
    {'name': 'Friend 2', 'imageUrl': 'https://example.com/friend2.jpg'},
    {'name': 'Friend 1', 'imageUrl': 'https://example.com/friend1.jpg'},
    {'name': 'Friend 2', 'imageUrl': 'https://example.com/friend2.jpg'},
    {'name': 'Friend 1', 'imageUrl': 'https://example.com/friend1.jpg'},
    {'name': 'Friend 2', 'imageUrl': 'https://example.com/friend2.jpg'},
    {'name': 'Friend 1', 'imageUrl': 'https://example.com/friend1.jpg'},
    {'name': 'Friend 2', 'imageUrl': 'https://example.com/friend2.jpg'},
    {'name': 'Friend 1', 'imageUrl': 'https://example.com/friend1.jpg'},
    {'name': 'Friend 2', 'imageUrl': 'https://example.com/friend2.jpg'},
  ];

  final List<Widget> _pages = <Widget>[
    const Center(child: Text('Home Page')),
    const Center(child: Text('Camera Page')),
    ProfilePage(
      profileImageUrl: profileImageUrl,
      userName: userName,
      friends: friends,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex), // Display the selected page
      ),
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
        selectedItemColor: Colors.blue,
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
