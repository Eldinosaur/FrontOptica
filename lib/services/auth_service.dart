import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage_service.dart';
import '../models/usuario_model.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.79.7.184:8000/api')); // Ruta del servicio local
  // https://eyemedix-api.onrender.com/api // Ruta del servicio en línea, si se necesita cambiar

  bool _isAuthenticated = false;
  Usuario? _usuarioActual;

  bool get isAuthenticated => _isAuthenticated;
  Usuario? get usuarioActual => _usuarioActual;
  int? get userId => _usuarioActual?.id;

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

  // Método para cambiar la contraseña del usuario
  Future<bool> cambiarClave(String claveActual, String nuevaClave) async {
    final token = await SecureStorageService.getToken();
    if (token == null || _usuarioActual == null) {
      return false; // Si no hay token o no hay usuario actual, no podemos proceder
    }

    try {
      // Realizamos la petición POST para cambiar la contraseña
      final response = await _dio.post(
        '/cambioclave',
        data: {
          'IDusuario': _usuarioActual!.id, // Enviamos el ID del usuario
          'ClaveActual': claveActual,     // Enviamos la clave actual
          'NuevaClave': nuevaClave,       // Enviamos la nueva clave
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token', // Enviamos el token de autorización
        }),
      );

      return response.statusCode == 200; // Si la respuesta es exitosa, devolvemos true
    } catch (e) {
      print('Error al cambiar clave: $e');
      return false; // Si ocurre un error, devolvemos false
    }
  }
}
