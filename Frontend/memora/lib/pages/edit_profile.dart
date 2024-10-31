import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String initialProfileImageUrl;
  final String initialUserName;

  const EditProfilePage({
    super.key,
    required this.initialProfileImageUrl,
    required this.initialUserName,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _profileImageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUserName);
    _profileImageController = TextEditingController(text: widget.initialProfileImageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedName = _nameController.text;
    final updatedImageUrl = _profileImageController.text;

    Navigator.pop(context, {
      'userName': updatedName,
      'profileImageUrl': updatedImageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _profileImageController,
              decoration: const InputDecoration(
                labelText: 'Profile Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
