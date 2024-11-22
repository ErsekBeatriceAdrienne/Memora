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
    required this.creatorId,
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

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Stream<DocumentSnapshot> _eventStream()
  {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .snapshots();
  }

  Stream<List<Map<String, String>>> _participantsStream() async* {
    final eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();

    final participantsEmails = List<String>.from(eventSnapshot.data()?['participants'] ?? []);
    final participantsList = <Map<String, String>>[];

    for (var email in participantsEmails) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        participantsList.add({
          'email': email,
          'imageUrl': userData['profileImageUrl'] ?? '',
        });
      }
    }

    yield participantsList;
  }

  Future<void> _inviteParticipant() async
  {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userDoc = userSnapshot.docs.first;

          await FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .update({
            'participants': FieldValue.arrayUnion([email]),
          });

          _emailController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invitation sent successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email not found!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error during invitation!')),
        );
      }
    }
  }

  Future<void> _navigateToEditEventPage() async
  {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          eventId: widget.eventId,
          eventName: widget.eventName,
          date: widget.date,
          location: widget.location,
          note: widget.note,
          invitedPeople: widget.galleryImages, // Pass the updated values
        ),
      ),
    );

    if (updatedEvent != null) {
      setState(() {
        // Refresh event data if needed
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _eventStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasData && snapshot.data != null) {
              final eventData = snapshot.data!.data() as Map<String, dynamic>;
              final eventName = eventData['eventName'] ?? widget.eventName;
              return Text(
                eventName,
              );
            }

            return const Text('Event');
          },
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: _eventStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final eventData = snapshot.data!.data() as Map<String, dynamic>;
                  final eventDate = eventData['date'] ?? widget.date;
                  final eventLocation = eventData['location'] ?? widget.location;
                  final eventNote = eventData['note'] ?? widget.note;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date of Event:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        eventDate,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Location:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        eventLocation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Note:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        eventNote,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            // Participants list comes first
            Text(
              'Participants:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            StreamBuilder<List<Map<String, String>>>(
              stream: _participantsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final participants = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(participant['imageUrl']!),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Text('No participants');
              },
            ),
            if (widget.isCreator)
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ElevatedButton(
              onPressed: _inviteParticipant,
              child: const Text('Invite'),
            ),
          ],
        ),
      ),
    );
  }

}
