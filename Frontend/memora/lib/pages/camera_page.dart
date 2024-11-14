import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../cloudinary/cloudinary_service.dart';

import '../cloudinary/cloudinary_apis.dart';

class CameraPage extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userData;


  const CameraPage({Key? key, required this.user, required this.userData}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
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

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchUserEvents() async {
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

      for (var doc in creatorQuerySnapshot.docs) {
        events.add(doc.data() as Map<String, dynamic>);
      }

      for (var doc in participantQuerySnapshot.docs) {
        var eventData = doc.data() as Map<String, dynamic>;
        if (!events.any((event) => event['eventName'] == eventData['eventName'])) {
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
      print('No image selected or event selected');
      return;
    }

    try {
      final event = _events[_selectedEventIndex!];
      final eventDocId = event['docId'];
      final imageUrl = await _uploadImage(_imageFile!, eventDocId);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        print('Image uploaded successfully: $imageUrl');

        // Update Firestore with the image URL only if it's valid
        await FirebaseFirestore.instance.collection('events').doc(eventDocId).update({
          'imageUrl': imageUrl,
        });

        print('Image uploaded successfully and saved to Firestore');
      } else {
        print('Image upload failed, URL is null or empty');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<String?> _uploadImage(File imageFile, String eventDocId) async {
    try {
      // Get the upload preset for the event
      String? presetName = await cloudinaryService.createUploadPreset(eventDocId);
      if (presetName == null) {
        print('Failed to create upload preset.');
        return null;
      }

      // Upload the image and get the URL
      final imageUrl = await cloudinaryService.uploadImageUnsigned(imageFile, presetName);
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
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
