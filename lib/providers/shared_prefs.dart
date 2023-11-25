
import 'package:flutter/material.dart';

class SharedPrefs with ChangeNotifier {
  late String _userId;
  late String _role;

  String get userId => _userId;
  String get role => _role;

  void setUserData(String userId, String role) {
    _userId = userId;
    _role = role;
    notifyListeners();
  }
}
