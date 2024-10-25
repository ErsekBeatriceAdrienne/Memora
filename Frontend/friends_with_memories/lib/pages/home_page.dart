import 'package:flutter/material.dart';
import 'package:friends_with_memories/pages/profile_page.dart'; // Import ProfilePage

class HomePage extends StatefulWidget
{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
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
    // Home page content
    SingleChildScrollView(  // Use SingleChildScrollView for scrolling
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

  // Function to build larger rounded rectangles
  static Widget _buildRoundedRectangle(String text) {
    return Container(
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
      body: _pages.elementAt(_selectedIndex), // Switches between Home, Camera, and Profile
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