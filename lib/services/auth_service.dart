import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage_service.dart';
import '../models/usuario_model.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.100.2:8000/api')); //ruta del servicio
  // https://eyemedix-api.onrender.com/api  // servicio en linea

  bool _isAuthenticated = false;
  Usuario? _usuarioActual;

  bool get isAuthenticated => _isAuthenticated;
  Usuario? get usuarioActual => _usuarioActual;

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

          // Construir el usuario desde la respuesta
          _usuarioActual = Usuario.fromJson(response.data);

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
    _usuarioActual = null;
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
          _usuarioActual = Usuario.fromJson(response.data);
        } else {
          _isAuthenticated = false;
        }
      } catch (e) {
        _isAuthenticated = false;
      }
      notifyListeners();
    } else {
      _isAuthenticated = false;
      _usuarioActual = null;
    }
  }
}
