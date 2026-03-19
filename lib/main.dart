import 'package:chirp/utils/bird_repository.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Program starts
  WidgetsFlutterBinding.ensureInitialized();

  await BirdRepository()
      .getBirds(); //Grabbing birds from DB and getting them cached before app runs.

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB8hKUX_vxJ4o3pNPAudwjtJY_tKgj0ifM",
      authDomain: "chirp-60b12.firebaseapp.com",
      projectId: "chirp-60b12",
      storageBucket: "chirp-60b12.firebasestorage.app", // IMPORTANT: see note below
      messagingSenderId: "1029341009830",
      appId: "1:1029341009830:web:41520b1210e51efb9ce167",
      // measurementId is NOT needed for Flutter Firebase
    ),
  );

  final app = Firebase.app();
  debugPrint("Firebase initialized: ${app.name}");


  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const ChirpApp(),
    ), // Provider that allows holding logged in user
  );
}

class ChirpApp extends StatelessWidget {
  const ChirpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chirp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, // any Color
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), //First screen the user sees
    );
  }
}
