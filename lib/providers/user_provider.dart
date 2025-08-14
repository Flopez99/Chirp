import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _username = '';
  String _userId = '';

  String get username => _username;
  String get userId => _userId;

  void setUser(String username, String userId) {
    _username = username;
    _userId = userId;
    notifyListeners();
  }

  void clearUser() {
    _username = '';
    _userId = '';
    notifyListeners();
  }
}
