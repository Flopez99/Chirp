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
  final http.Client client;

  LoginScreen({super.key, http.Client? client})
    : client = client ?? http.Client(); // defaults to real client

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        //Chooses the widget size based on the device
        mobile: _LoginForm(
          maxWidth: double.infinity,
          client: client,
        ), // full width for mobile
        tablet: _LoginForm(maxWidth: 500, client: client),
        desktop: _LoginForm(maxWidth: 400, client: client),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final double maxWidth;
  final http.Client client;

  const _LoginForm({required this.maxWidth, required this.client});

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
      final response = await widget.client.post(
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
        final userResponse = await widget.client.get(
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
                  key: const Key('login_email'),
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('login_password'),
                  controller: passwordController,
                  obscureText: true, //hide password
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('login_log_button'),
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  key: const Key('login_reg_button'),
                  onPressed: _register,
                  child: const Text('Register'),
                ),
                Text(
                  key: const Key('login_error_text'),
                  loginMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
