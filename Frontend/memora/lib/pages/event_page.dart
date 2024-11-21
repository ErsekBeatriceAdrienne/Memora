import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_event_page.dart';

class EventPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String creatorProfileImageUrl;
  final bool isCreator;
  final String creatorId;
  final String date;
  final String location;
  final String note;
  final List<String> galleryImages;

  const EventPage({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.creatorProfileImageUrl,
    required this.isCreator,
    required this.creatorId, // Initialize the new parameter
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
  List<Map<String, String>> participantsData = [];
  bool _isLoading = true;
  String? currentUserId;

  // Add state variables to hold updated event data
  late String eventName;
  late String date;
  late String location;
  late String note;
  late List<String> galleryImages;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    _getCurrentUserId();

    // Initialize state with widget data
    eventName = widget.eventName;
    date = widget.date;
    location = widget.location;
    note = widget.note;
    galleryImages = widget.galleryImages;
  }

  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> _fetchParticipants() async {
    // Your participant fetching logic
  }

  Future<void> _inviteParticipant() async {
    // Your invite participant logic
  }

  Future<void> _navigateToEditEventPage() async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          eventId: widget.eventId,
          eventName: eventName,  // Pass the updated values to the EditEventPage
          date: date,
          location: location,
          note: note,
          invitedPeople: galleryImages, // Pass the updated values
        ),
      ),
    );

    if (updatedEvent != null) {
      setState(() {
        // Update the event data in the EventPage with the new values
        eventName = updatedEvent['eventName'];
        date = updatedEvent['date'];
        location = updatedEvent['location'];
        note = updatedEvent['note'];
        galleryImages = updatedEvent['invitedPeople']; // Adjust as necessary
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        actions: [
          (widget.creatorId == currentUserId)
              ? IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditEventPage,
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
          children: [
            Text(date),
            Text(location),
            Text(note),
            if (widget.isCreator)
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ElevatedButton(
              onPressed: _inviteParticipant,
              child: const Text('Invite'),
            ),
            const SizedBox(height: 20),
            Text('Participants:'),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: participantsData.length,
                itemBuilder: (context, index) {
                  final participant = participantsData[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(participant['imageUrl']!),
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
