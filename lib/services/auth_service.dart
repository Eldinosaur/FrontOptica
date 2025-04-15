import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage_service.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.100.2:8000/api')); //ruta del servicio
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'Usuario': username,
        'Clave': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token != null) {
          await SecureStorageService.saveToken(token);
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('Error en login: $e');
    }
    return false;
  }

  Future<void> logout() async {
    await SecureStorageService.deleteToken();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await SecureStorageService.getToken();
    if (token != null) {
      try {
        final response = await _dio.get('/me', options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));

        if (response.statusCode == 200) {
          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
        }
      } catch (e) {
        _isAuthenticated = false;
      }
      notifyListeners();
    } else {
      _isAuthenticated = false;
    }
  }
}
