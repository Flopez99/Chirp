import 'package:chirp/screens/home_page.dart';
import 'package:flutter/material.dart';
import '../widgets/responsive_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
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

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Simple test user check
    if (email == 'test' && password == '123') {
      // Clear message
      setState(() {
        loginMessage = '';
      });

      // Navigate to MainPage, passing email as username
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: email)),
      );
    } else {
      setState(() {
        loginMessage = 'Invalid email or password';
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
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _login, child: const Text('Login')),
                const SizedBox(height: 12),
                Text(loginMessage, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
