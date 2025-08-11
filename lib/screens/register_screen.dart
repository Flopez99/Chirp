import 'dart:convert';
import 'package:chirp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/responsive_layout.dart';

const String baseUrl = 'http://127.0.0.1:5000'; // Change this in production
final storage = FlutterSecureStorage();

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        //Chooses the widget based on the device
        mobile: _RegisterScreenForm(
          maxWidth: double.infinity,
        ), // full width for mobile
        tablet: _RegisterScreenForm(maxWidth: 500),
        desktop: _RegisterScreenForm(maxWidth: 400),
      ),
    );
  }
}

class _RegisterScreenForm extends StatefulWidget {
  final double maxWidth;

  const _RegisterScreenForm({required this.maxWidth});

  @override
  State<_RegisterScreenForm> createState() => _RegisterScreenFormState();
}

class _RegisterScreenFormState extends State<_RegisterScreenForm> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  String registerMessage = '';
  bool isLoading = false;

  @override
  void initState() {
    //
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    //clear memory to avoid leaks
    usernameController = TextEditingController();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _back() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _register() async {
    setState(() {
      isLoading = true;
      registerMessage = '';
    });

    final username = usernameController.text;
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      setState(() {
        // Make better error checks in here
        registerMessage = 'Email, password, and username are required.';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        await storage.write(key: 'jwt', value: token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        final error = jsonDecode(response.body)['message'];
        setState(() {
          registerMessage = error ?? 'Register Failed';
        });
      }
    } catch (e) {
      setState(() {
        registerMessage = 'Error connecting to server';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Join Us!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true, //hide password
                  decoration: const InputDecoration(labelText: 'Password'),
                ),

                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _back,
                  child: const Text('Back to Login'),
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register!'),
                ),
                Text(registerMessage, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
