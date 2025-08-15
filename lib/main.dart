import 'package:chirp/utils/bird_repository.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';

void main() async {
  // Program starts
  WidgetsFlutterBinding.ensureInitialized();

  await BirdRepository()
      .getBirds(); //Grabbing birds from DB and getting them cached before app runs.

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
