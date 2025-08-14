import 'dart:convert';
import 'package:chirp/providers/user_provider.dart';
import 'package:chirp/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../screens/home_page.dart';
import '../widgets/responsive_layout.dart';
// import 'package:chirp/config/constants.dart';

const String baseUrl = 'http://127.0.0.1:5000'; // Change this in production
final storage = FlutterSecureStorage();

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        //Chooses the widget size based on the device
        mobile: _LoginForm(maxWidth: double.infinity), // full width for mobile
        tablet: _LoginForm(maxWidth: 500),
        desktop: _LoginForm(maxWidth: 400),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final double maxWidth;

  const _LoginForm({required this.maxWidth});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  String loginMessage = '';
  bool isLoading = false;

  @override
  void initState() {
    //
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    //clear memory to avoid leaks
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _register() {
    // Switch to register screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RegisterScreen()),
    );
  }

  void _login() async {
    setState(() {
      isLoading = true;
      loginMessage = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    //Checks if fields are empty
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        loginMessage = 'Email and password are required.';
        isLoading = false;
      });
      return;
    }

    try {
      //Login
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      //Succesful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token']?.trim();

        //Stores user token as logged
        await storage.write(key: 'jwt', value: token);

        // 2. Fetch user info from /me using the token
        final userResponse = await http.get(
          Uri.parse('$baseUrl/me'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          final username = userData['username'];
          final userId = userData['id'];
          // Store in provider
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUser(username, userId.toString());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        } else {
          setState(() {
            loginMessage = 'Failed to fetch user details.';
          });
        }
      } else {
        final error = jsonDecode(response.body)['message'];
        setState(() {
          loginMessage = error ?? 'Login Failed';
        });
      }
    } catch (e) {
      setState(() {
        loginMessage = 'Error connecting to server';
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
                  'Welcome to Chirp!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _login, child: const Text('Login')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
                Text(loginMessage, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
