import 'package:flutter/material.dart';

class AuthNotifier with ChangeNotifier {
  String? _username;
  String? get username => _username;

  void login(String user) {
    _username = user;
    notifyListeners();
  }
}
