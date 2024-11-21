import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camera_page.dart';
import 'create_event_page.dart';
import 'event_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget
{
  final User user;
  final Map<String, dynamic> userData;

  const HomePage({Key? key, required this.user, required this.userData})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  int _selectedIndex = 0;
  late List<Widget> _pages;
  List<Map<String, String>> friendsList = [];

  @override
  void initState() {
    super.initState();
    fetchFriendsData();
  }

  Future<void> fetchFriendsData() async {
    List<dynamic> friendsEmails = widget.userData['friends'] ?? [];
    List<Map<String, String>> loadedFriends = [];

    for (String email in friendsEmails) {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        var friendData = query.docs.first.data();
        loadedFriends.add({
          'name': '${friendData['firstName']} ${friendData['lastName']}',
          'imageUrl': friendData['profileImageUrl'] ?? 'assets/images/default.png',
          'nickname': friendData['username'] ?? 'N/A',
          'birthday': friendData['birthday'] ?? 'Unknown',
        });
      }
    }

    setState(() {
      friendsList = loadedFriends;
      _pages = <Widget>[
        _buildHomeContent(),
        CameraPage(
          user: widget.user,
          userData: widget.userData,
        ),
        ProfilePage(
          email: widget.userData['email'] ?? '',
        ),
      ];
    });
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
          eventData['eventId'] = doc.id; // Add eventId from Firestore
          return eventData;
        }).toList();

        return SingleChildScrollView(
          child: Column(
            children: events.map<Widget>((event) {
              return _buildRoundedRectangle(
                event['eventId'], // Pass eventId
                event['eventName'] ?? 'N/A',
                event['creatorProfileImageUrl'] ?? '',
                event['date'] ?? 'N/A',
                event['location'] ?? 'N/A',
                event['note'] ?? 'N/A',
                event['creatorId'] ?? '',
              );
            }).toList(),
          ),
        );
      },
    );
  }


  Widget _buildRoundedRectangle(
      String eventId,
      String eventName,
      String profileImageUrl,
      String date,
      String location,
      String note,
      String creatorId,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(
              eventId: eventId,
              eventName: eventName,
              creatorProfileImageUrl: profileImageUrl,
              isCreator: widget.user.uid == creatorId,
              creatorId: creatorId,
              date: date,
              location: location,
              note: note,
              galleryImages: [], // Placeholder for gallery images
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