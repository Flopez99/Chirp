import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart'; // Add at the top
import '../models/bird_sighting.dart';
import '../utils/sighting_repository.dart';

class LogSightingPage extends StatefulWidget {
  const LogSightingPage({super.key});

  @override
  State<LogSightingPage> createState() => _LogSightingPageState();
}

class _LogSightingPageState extends State<LogSightingPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedBird;
  DateTime selectedDateTime = DateTime.now();
  // Image? selectedImage; <-- Placeholder for now
  // LatLng? selectedLocation; <-- Placeholder for future map pin

  final List<String> birdOptions = [
    "Bald Eagle",
    "Northern Cardinal",
    "California Condor",
    "Not Sure?",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log a Sighting")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Bird Photo",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                color: Colors.grey[300],
                child: const Center(child: Text("Upload Image (TBD)")),
              ),

              const SizedBox(height: 16),
              DropdownSearch<String>(
                items: birdOptions,
                selectedItem: selectedBird,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select Bird",
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(labelText: "Search bird..."),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedBird = value;
                  });
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Please select a bird"
                            : null,
              ),

              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  "Date & Time: ${selectedDateTime.toLocal()}".split('.')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (time != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),

              const SizedBox(height: 16),
              const ListTile(
                title: Text("Pin Location"),
                trailing: Icon(Icons.map),
                // onTap: () => push map picker page
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newSighting = BirdSighting(
                      birdName: selectedBird!,
                      imagePath:
                          "assets/Placeholder.jpg", // use selected image later
                      dateTime: selectedDateTime,
                      locationName: "Unknown Location", // integrate map later
                    );

                    SightingRepository.addSighting(newSighting);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sighting logged!")),
                    );

                    Navigator.pop(
                      context,
                      true,
                    ); // signal that something was submitted
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
