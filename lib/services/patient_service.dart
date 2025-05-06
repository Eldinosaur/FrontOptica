import 'package:dio/dio.dart';
import '../models/patient_model.dart';
import '../utils/secure_storage_service.dart';

class PatientService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://eyemedix-api.onrender.com/api'),
  );

  // Método para obtener el token desde almacenamiento seguro
  static Future<String?> _getToken() async {
    return await SecureStorageService.getToken();
  }

  // Obtener todos los pacientes
  static Future<List<Patient>> getAllPatients() async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/pacientes',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener pacientes');
      }
    } catch (e) {
      print('Error en getAllPatients: $e');
      rethrow;
    }
  }

  // Buscar paciente por cédula
  static Future<List<Patient>> searchByCedula(String cedula) async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/pacientecedula/$cedula',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar por cédula');
      }
    } catch (e) {
      print('Error en searchByCedula: $e');
      rethrow;
    }
  }

  // Buscar paciente por nombre
  static Future<List<Patient>> searchByNombre(String nombre) async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/buscar_paciente/$nombre',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar por nombre');
      }
    } catch (e) {
      print('Error en searchByNombre: $e');
      rethrow;
    }
  }

  // Buscar paciente por ID
  static Future<Patient> getPatientById(String id) async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/paciente/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        if (data.isNotEmpty) {
          return Patient.fromJson(data[0]);
        } else {
          throw Exception('Paciente no encontrado');
        }
      } else {
        throw Exception('Error al obtener paciente por ID');
      }
    } catch (e) {
      print('Error en getPatientById: $e');
      rethrow;
    }
  }

  //Creacion de paciente
  static Future<Map<String, dynamic>> createPatient(
    Map<String, dynamic> data,
  ) async {
    final token = await SecureStorageService.getToken();
    final response = await _dio.post(
      '/paciente', // asegúrate de que esta sea la ruta correcta
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
