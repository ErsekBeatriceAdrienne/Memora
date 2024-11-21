import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../map/map_picker.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String date;
  final String location;
  final String note;
  final List<String> invitedPeople;

  const EditEventPage({
    Key? key,
    required this.eventId,
    required this.eventName,
    required this.date,
    required this.location,
    required this.note,
    required this.invitedPeople,
  }) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController _eventNameController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _noteController;
  late List<String> _invitedPeople; // Meghívottak listája
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.eventName);
    _dateController = TextEditingController(text: widget.date);
    _locationController = TextEditingController(text: widget.location);
    _noteController = TextEditingController(text: widget.note);
    _invitedPeople = List.from(widget.invitedPeople); // Inicializálás
    if (widget.date.isNotEmpty) {
      _selectedDate = DateTime.tryParse(widget.date);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _selectedDate ?? DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addPerson(String person) {
    setState(() {
      _invitedPeople.add(person);
    });
  }

  void _removePerson(int index) {
    setState(() {
      _invitedPeople.removeAt(index);
    });
  }

  void _saveEvent() async {
    String updatedEventName = _eventNameController.text;
    String updatedDate = _dateController.text;
    String updatedLocation = _locationController.text;
    String updatedNote = _noteController.text;

    try {
      // Esemény dokumentumának frissítése a Firestore-ban
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId.toString()).update({
        'eventName': updatedEventName,
        'date': updatedDate,
        'location': updatedLocation,
        'note': updatedNote,
        'invitedPeople': _invitedPeople,
      });

      // Visszatérés az előző oldalra
      Navigator.pop(context, {
        'eventName': updatedEventName,
        'date': updatedDate,
        'location': updatedLocation,
        'note': updatedNote,
        'invitedPeople': _invitedPeople,
      });
    } catch (e) {
      // Hiba kezelése
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event: $e')),
      );
    }
  }

  Future<void> _showAddPersonDialog() async {
    TextEditingController personController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Invited Person"),
          content: TextField(
            controller: personController,
            decoration: const InputDecoration(
              labelText: "Name or Email",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (personController.text.isNotEmpty) {
                  _addPerson(personController.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event: ${widget.eventName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEvent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapPickerPage(),
                    ),
                  );
                  if (result != null && result['location'] != null) {
                    setState(() {
                      _locationController.text = result['location'];
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Invited People",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _invitedPeople.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_invitedPeople[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removePerson(index),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showAddPersonDialog,
                child: const Text("Add Person"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveEvent,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}