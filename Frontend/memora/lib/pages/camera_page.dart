import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cloudinary/cloudinary_service.dart';
import '../cloudinary/cloudinary_apis.dart';

class CameraPage extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userData;

  const CameraPage({Key? key, required this.user, required this.userData}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
{
  File? _imageFile;
  List<Map<String, dynamic>> _events = [];
  int? _selectedEventIndex;
  final String apiKey = CloudinaryData.apiKey;
  final String apiSecret = CloudinaryData.apiSecret;
  final String cloudName = CloudinaryData.cloudName;
  CloudinaryService cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _openCamera();
    _fetchUserEvents();
  }

  Future<void> _openCamera() async
  {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          print("Kép kiválasztva: ${_imageFile?.path}");
        });
      } else {
        print("Nem választottál ki képet.");
      }
    } catch (e) {
      print("Hiba történt a kamera megnyitásakor: $e");
    }
  }

  Future<void> _fetchUserEvents() async
  {
    try {
      final userId = widget.user.uid;
      final userEmail = widget.user.email;

      QuerySnapshot creatorQuerySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('creatorId', isEqualTo: userId)
          .get();

      QuerySnapshot participantQuerySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('participants', arrayContains: userEmail)
          .get();

      List<Map<String, dynamic>> events = [];

      // Hozzáadjuk a docId-t az eseményekhez
      for (var doc in creatorQuerySnapshot.docs) {
        var eventData = doc.data() as Map<String, dynamic>;
        eventData['docId'] = doc.id; // docId hozzáadása
        events.add(eventData);
      }

      for (var doc in participantQuerySnapshot.docs) {
        var eventData = doc.data() as Map<String, dynamic>;
        if (!events.any((event) => event['eventName'] == eventData['eventName'])) {
          eventData['docId'] = doc.id; // docId hozzáadása
          events.add(eventData);
        }
      }

      setState(() {
        _events = events;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_imageFile == null || _selectedEventIndex == null) {
      print('Nincs kép kiválasztva vagy esemény kiválasztva');
      return;
    }

    try {
      final event = _events[_selectedEventIndex!];
      final eventDocId = event['docId'] ?? '';

      if (eventDocId.isEmpty) {
        print('Az esemény azonosítója (docId) nem található.');
        return;
      }

      // Használjuk a presetName-t és az event ID-t az upload függvényben
      final imageUrl = await cloudinaryService.uploadImageForEvent(
        _imageFile!,
        CloudinaryData.presetNameEvents,
        eventDocId,
      );
    } catch (e) {
      print('Hiba a kép feltöltésekor: $e');
    }
  }

  Future<String?> _uploadImage(File imageFile, String uploadPreset) async {
    try {
      if (uploadPreset.isEmpty) {
        print('Upload preset nem lehet üres.');
        return null;
      }

      final imageUrl = await cloudinaryService.uploadImageUnsigned(imageFile, uploadPreset);
      return imageUrl;
    } catch (e) {
      print('Hiba a kép feltöltésekor: $e');
      return null;
    }
  }

  void _selectEvent(int index) {
    setState(() {
      _selectedEventIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userData['username'] ?? 'Camera Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _imageFile == null
                  ? const Text('No image captured.')
                  : Image.file(_imageFile!),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your Events',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                final isSelected = _selectedEventIndex == index;

                return GestureDetector(
                  onTap: () => _selectEvent(index),
                  child: Container(
                    color: isSelected
                        ? Colors.blueAccent.withOpacity(0.3)
                        : Colors.transparent,
                    child: ListTile(
                      title: Text(event['eventName'] ?? 'N/A'),
                      subtitle: Text(
                        'Date: ${event['date'] ?? 'N/A'}\nLocation: ${event['location'] ?? 'N/A'}',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: _uploadImageToCloudinary,
            child: const Text('Upload Image to Cloudinary'),
          ),
        ],
      ),
    );
  }
}
