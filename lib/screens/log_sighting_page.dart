import 'package:chirp/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';
import '../models/bird_sighting.dart';
import '../models/bird.dart';
import '../utils/sighting_repository.dart';
import 'package:intl/intl.dart';
import '../utils/bird_repository.dart';
import '../utils/geocode_service.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chirp/config/api_config.dart';

class LogSightingPage extends StatefulWidget {
  const LogSightingPage({super.key});

  @override
  State<LogSightingPage> createState() => _LogSightingPageState();
}

class _LogSightingPageState extends State<LogSightingPage> {
  final _formKey = GlobalKey<FormState>();

  Bird? selectedBird;
  DateTime selectedDateTime = DateTime.now();

  // Coordinates for the sighting location
  double? selectedLatitude;
  double? selectedLongitude;
  String? selectedLocationName;
  bool isResolvingLocation = false;
  bool isIdentifyingBird = false;

  Uint8List? selectedImageBytes;
  String selectedImageMime = 'image/jpeg';
  String? selectedImageName;

  final _uuid = const Uuid();
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _identifyBirdFromPhoto(List<Bird> birds) async {
    if (selectedImageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload a photo first.")));
      return;
    }

    setState(() {
      isIdentifyingBird = true;
    });

    try {
      final uri = ApiConfig.uri("/identify-bird");

      final request = http.MultipartRequest("POST", uri);

      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          selectedImageBytes!,
          filename: selectedImageName ?? "bird_photo.jpg",
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data["error"] ?? "Could not identify bird");
      }

      final alternatives =
          (data["alternatives"] as List<dynamic>).take(5).toList();
      final topMatch = alternatives.first;
      final otherMatches = alternatives.skip(1).take(3).toList();

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          Bird getMatchedBird(dynamic birdJson) {
            return birds.firstWhere(
              (b) => b.id == birdJson["id"],
              orElse: () => birds.firstWhere((b) => b.name == birdJson["name"]),
            );
          }

          Widget birdImage(Bird bird, double size) {
            if (bird.photoUrl == null) {
              return Icon(Icons.image, size: size);
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  bird.photoUrl!.startsWith('http')
                      ? Image.network(
                        bird.photoUrl!,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                Icon(Icons.broken_image, size: size),
                      )
                      : Image.asset(
                        bird.photoUrl!,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                      ),
            );
          }

          String confidenceLabel(num score) {
            if (score >= 130) return "High confidence";
            if (score >= 105) return "Good match";
            return "Possible match";
          }

          void selectBird(Bird bird) {
            setState(() {
              selectedBird = bird;
            });
            Navigator.pop(context);
          }

          final topBird = getMatchedBird(topMatch["bird"]);
          final topScore = topMatch["score"] as num;

          return AlertDialog(
            title: const Text("Identify Bird"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => selectBird(topBird),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              birdImage(topBird, 72),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Chip(
                                      label: const Text("Best Match"),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      topBird.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(confidenceLabel(topScore)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.check_circle_outline),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Other possibilities",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    ...otherMatches.map((item) {
                      final bird = getMatchedBird(item["bird"]);
                      final score = item["score"] as num;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: birdImage(bird, 48),
                        title: Text(bird.name),
                        subtitle: Text(confidenceLabel(score)),
                        trailing: const Text("Select"),
                        onTap: () => selectBird(bird),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Identification failed: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isIdentifyingBird = false;
        });
      }
    }
  }

  Future<String?> _uploadImageForSighting(String sightingTempId) async {
    if (selectedImageBytes == null) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final photoId = _uuid.v4();
    final path = 'users/${user.uid}/sightings/$sightingTempId/$photoId';

    final ref = FirebaseStorage.instance.ref(path);

    final snapshot = await ref.putData(
      selectedImageBytes!,
      SettableMetadata(contentType: selectedImageMime),
    );

    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    // Infer mime from extension (good enough for now)
    final name = (file.name).toLowerCase();
    String mime = 'image/jpeg';
    if (name.endsWith('.png')) mime = 'image/png';
    if (name.endsWith('.webp')) mime = 'image/webp';
    if (name.endsWith('.gif')) mime = 'image/gif';

    setState(() {
      selectedImageBytes = bytes;
      selectedImageMime = mime;
      selectedImageName = file.name;
    });
  }

  Future<void> _resolveLocationName(double lat, double lng) async {
    setState(() {
      isResolvingLocation = true;
    });
    try {
      final locationName = await GeocodeService.getLocationName(lat, lng);
      if (mounted) {
        setState(() {
          selectedLocationName = locationName ?? 'Unknown Location';
          isResolvingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Error resolving location: $e');
      if (mounted) {
        setState(() {
          selectedLocationName = 'Unknown Location';
          isResolvingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(title: const Text("Log a Sighting")),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      selectedImageBytes != null
                          ? Image.memory(
                            selectedImageBytes!,
                            fit: BoxFit.contain,
                          )
                          : selectedBird?.photoUrl != null
                          ? (selectedBird!.photoUrl!.startsWith('http')
                              ? Image.network(
                                selectedBird!.photoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                          child: Text("Failed to load image"),
                                        ),
                              )
                              : Image.asset(
                                selectedBird!.photoUrl!,
                                fit: BoxFit.contain,
                              ))
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (selectedImageBytes != null) ...[
                        ElevatedButton.icon(
                          onPressed:
                              isIdentifyingBird
                                  ? null
                                  : () => _identifyBirdFromPhoto(birds),
                          icon:
                              isIdentifyingBird
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.search),
                          label: Text(
                            isIdentifyingBird
                                ? "Identifying..."
                                : "Identify Bird from Photo",
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      BirdDropdown(
                        birds: birds,
                        selectedBird: selectedBird,
                        onChanged: (bird) {
                          setState(() {
                            selectedBird = bird;
                          });
                        },
                      ),
                    ],
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
              ListTile(
                title: const Text("Pin Location"),
                subtitle:
                    selectedLatitude != null && selectedLongitude != null
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isResolvingLocation
                                  ? "Resolving location..."
                                  : (selectedLocationName ??
                                      "Unknown Location"),
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "Lat: ${selectedLatitude!.toStringAsFixed(4)}, Lng: ${selectedLongitude!.toStringAsFixed(4)}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                        : const Text(
                          "Tap to select location on map",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                trailing: const Icon(Icons.map),
                onTap: () async {
                  final result = await Navigator.push<LatLng>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MapPickerPage(
                            initialLatitude: selectedLatitude,
                            initialLongitude: selectedLongitude,
                          ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      selectedLatitude = result.latitude;
                      selectedLongitude = result.longitude;
                    });
                    // Resolve location name from coordinates
                    await _resolveLocationName(
                      result.latitude,
                      result.longitude,
                    );
                  }
                },
              ),

              const SizedBox(height: 24),
              Text(
                "Description (Optional)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: "Describe your sighting experience...",
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!_formKey.currentState!.validate() ||
                      selectedBird == null) {
                    return;
                  }

                  final scaffold = ScaffoldMessenger.of(context);

                  try {
                    debugPrint("SUBMIT: start");
                    debugPrint(
                      "selectedImageBytes null? ${selectedImageBytes == null}",
                    );
                    debugPrint(
                      "auth user: ${FirebaseAuth.instance.currentUser?.uid}",
                    );

                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                          selectedImageBytes != null
                              ? "Uploading photo..."
                              : "Saving sighting...",
                        ),
                      ),
                    );

                    final username =
                        Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).username;

                    // Temporary ID just for storage path
                    final tempSightingId =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    // 1️⃣ Upload image (if any)
                    debugPrint("SUBMIT: uploading...");
                    final uploadedPhotoUrl =
                        selectedImageBytes != null
                            ? await _uploadImageForSighting(tempSightingId)
                            : null;
                    debugPrint(
                      "SUBMIT: upload done. url? ${uploadedPhotoUrl != null}",
                    );
                    debugPrint("SUBMIT: url = $uploadedPhotoUrl");

                    scaffold.showSnackBar(
                      const SnackBar(content: Text("Saving sighting...")),
                    );

                    // 2️⃣ Build sighting payload
                    final descriptionValue =
                        _descriptionController.text.isEmpty
                            ? null
                            : _descriptionController.text;
                    final newSighting = BirdSighting(
                      userId: int.tryParse(userId),
                      birdId: selectedBird!.id,
                      loggedAt: selectedDateTime,
                      latitude: selectedLatitude,
                      longitude: selectedLongitude,
                      photoUrls: [
                        if (uploadedPhotoUrl != null) uploadedPhotoUrl,
                      ],
                      notes: null,
                      description: descriptionValue,
                      birdName: selectedBird!.name,
                      seenBy: username,
                      locationName: selectedLocationName ?? "Unknown Location",
                      speciesCode: selectedBird!.speciesCode,
                    );

                    // 3️⃣ Send to backend
                    await SightingRepository.addSighting(newSighting);

                    scaffold.showSnackBar(
                      const SnackBar(content: Text("Sighting logged!")),
                    );

                    Navigator.pop(context, true);
                  } catch (e, st) {
                    debugPrint("ERROR LOGGING SIGHTING: $e");
                    debugPrintStack(stackTrace: st);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error logging sighting: $e")),
                    );
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
