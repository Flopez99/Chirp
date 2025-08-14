import 'dart:io';

import 'package:chirp/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/bird_sighting.dart';
import '../models/bird.dart';
import '../utils/sighting_repository.dart';
import 'package:intl/intl.dart';
import '../utils/bird_repository.dart';

class LogSightingPage extends StatefulWidget {
  const LogSightingPage({super.key});

  @override
  State<LogSightingPage> createState() => _LogSightingPageState();
}

class _LogSightingPageState extends State<LogSightingPage> {
  final _formKey = GlobalKey<FormState>();

  Bird? selectedBird;
  DateTime selectedDateTime = DateTime.now();
  File? selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;

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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.black26),
                  ),
                  child:
                      selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : const Center(child: Text("Tap to upload image")),
                ),
              ),

              const SizedBox(height: 16),
              FutureBuilder<List<Bird>>(
                future: BirdRepository().getBirds(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text("Failed to load birds");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No birds available");
                  }
                  final birds = snapshot.data!;

                  return BirdDropdown(
                    birds: birds,
                    selectedBird: selectedBird,
                    onChanged: (bird) {
                      setState(() {
                        selectedBird = bird;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  "Date & Time: ${DateFormat('MM/dd/yyyy - hh:mm a').format(selectedDateTime)}",
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
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      selectedBird != null) {
                    final username =
                        Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).username;

                    // Construct BirdSighting with backend fields:
                    final newSighting = BirdSighting(
                      userId: int.tryParse(
                        userId,
                      ), // You might want to store userId somewhere or get from provider
                      birdId: selectedBird!.id,
                      loggedAt: selectedDateTime,
                      latitude: null, // Replace with picked location lat
                      longitude: null, // Replace with picked location long
                      photoUrls: [
                        selectedBird?.photoUrl ?? '',
                      ], // Using bird photo url for now
                      notes: null, // Add notes UI if needed
                      birdName: selectedBird!.name,
                      seenBy: username,
                      locationName: "Unknown Location",
                    );

                    try {
                      await SightingRepository.addSighting(newSighting);
                      print("SIGHTING GETTING LOGGED");
                      print(newSighting.loggedAt);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Sighting logged!")),
                      );

                      Navigator.pop(context, true);
                    } catch (e) {
                      print("ERROR WITH SIGHTING");
                      print(newSighting.loggedAt);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error logging sighting: $e")),
                      );
                    }
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

class BirdDropdown extends StatelessWidget {
  final List<Bird> birds;
  final Bird? selectedBird;
  final ValueChanged<Bird?> onChanged;

  const BirdDropdown({
    required this.birds,
    required this.selectedBird,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Bird>(
      items: birds,
      selectedItem: selectedBird,
      itemAsString: (bird) => bird.name,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Select Bird",
          border: OutlineInputBorder(),
        ),
      ),
      popupProps: PopupProps.dialog(
        showSearchBox: true,
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            labelText: "Search bird...",
            border: OutlineInputBorder(),
          ),
        ),
        itemBuilder:
            (context, bird, isSelected) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    bird.photoUrl != null
                        ? (bird.photoUrl!.startsWith('http')
                            ? Image.network(
                              bird.photoUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 40),
                            )
                            : Image.asset(
                              bird.photoUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ))
                        : const Icon(Icons.image_not_supported, size: 40),
              ),
              title: Text(bird.name),
            ),
      ),
      onChanged: onChanged,
    );
  }
}
