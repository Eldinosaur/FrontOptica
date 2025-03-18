import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  // Simula un inicio de sesión
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simula un delay de red
    if (username == "admin" && password == "12345") {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Cerrar sesión
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
