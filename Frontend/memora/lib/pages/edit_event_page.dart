import 'package:flutter/material.dart';

import '../map/map_picker.dart';

class EditEventPage extends StatefulWidget {
  final String eventName;
  final String date;
  final String location;
  final String note;

  const EditEventPage({
    Key? key,
    required this.eventName,
    required this.date,
    required this.location,
    required this.note,
  }) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController _eventNameController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _noteController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Inicializáljuk a szövegbeviteli mezőket a meglévő adatokkal
    _eventNameController = TextEditingController(text: widget.eventName);
    _dateController = TextEditingController(text: widget.date);
    _locationController = TextEditingController(text: widget.location);
    _noteController = TextEditingController(text: widget.note);

    // A meglévő dátumot beállítjuk, ha már létezik
    if (widget.date.isNotEmpty) {
      _selectedDate = DateTime.tryParse(widget.date);
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

  // Dátum választó funkció
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
        _dateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Mentés funkció
  void _saveEvent() {
    String updatedEventName = _eventNameController.text;
    String updatedDate = _dateController.text;
    String updatedLocation = _locationController.text;
    String updatedNote = _noteController.text;

    Navigator.pop(context, {
      'eventName': updatedEventName,
      'date': updatedDate,
      'location': updatedLocation,
      'note': updatedNote,
    });
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
              // Esemény neve
              TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Dátum
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
              /// Helyszín
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
              // Megjegyzés
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Mentés gomb
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
