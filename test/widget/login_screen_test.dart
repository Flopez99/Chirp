import 'dart:convert';

import 'package:chirp/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Finder emailField;
  late Finder passwordField;
  late Finder loginButton;
  late Finder registerButton;
  late Finder errorText;

  setUp(() async {
    emailField = find.byKey(const Key('login_email'));
    passwordField = find.byKey(const Key('login_password'));
    loginButton = find.byKey(const Key('login_log_button'));
    registerButton = find.byKey(const Key('login_reg_button'));
    errorText = find.byKey(const Key('login_error_text'));
  });

  final mockClient = MockClient((request) async {
    if (request.url.path == '/login') {
      final body = jsonDecode(request.body);
      if (body['email'] == 'good@example.com' &&
          body['password'] == 'goodpass') {
        return http.Response(jsonEncode({'access_token': 'fake_token'}), 200);
      } else {
        return http.Response(
          jsonEncode({'message': 'Invalid credentials'}),
          401,
        );
      }
    }
    if (request.url.path == '/me') {
      return http.Response(jsonEncode({'username': 'TestUser', 'id': 1}), 200);
    }
    return http.Response('Not Found', 404);
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(client: mockClient)));
    await tester.pumpAndSettle();
  }

  testWidgets('Login fails if both fields empty', (tester) async {
    await pumpLoginScreen(tester);

    await tester.tap(loginButton);
    await tester.pump();

    expect(errorText, findsOneWidget);
    expect(find.text('Email and password are required.'), findsOneWidget);
  });

  testWidgets('Login fails if password is missing', (tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(emailField, 'test@example.com');
    await tester.tap(loginButton);
    await tester.pump();

    expect(errorText, findsOneWidget);
    expect(find.text('Email and password are required.'), findsOneWidget);
  });

  testWidgets('Login fails if email is missing', (tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(passwordField, 'password123');
    await tester.tap(loginButton);
    await tester.pump();

    expect(errorText, findsOneWidget);
    expect(find.text('Email and password are required.'), findsOneWidget);
  });

  testWidgets('Wrong credentials fail to log in', (tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(emailField, 'wrong@example.com');
    await tester.enterText(passwordField, 'wrongpass');

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('Successful login credentials leads to Home Page', (
    tester,
  ) async {
    await pumpLoginScreen(tester);

    await tester.enterText(emailField, 'good@example.com');
    await tester.enterText(passwordField, 'goodpass');

    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Pressing register button navigates to RegisterScreen', (
    tester,
  ) async {
    await pumpLoginScreen(tester);

    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.byKey(Key('register_title')), findsWidgets);
  });
}
