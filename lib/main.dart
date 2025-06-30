import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ChirpApp());
}

class ChirpApp extends StatelessWidget {
  const ChirpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chirp',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
