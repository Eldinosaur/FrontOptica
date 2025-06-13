import 'package:dio/dio.dart';
import '../models/rx_model.dart';
import '../utils/secure_storage_service.dart';
import '../utils/navigation.dart';

class ConsultaService {
  static final Dio _dio = Dio(BaseOptions(baseUrl:AppConfig.baseUrl));

  static Future<String?> _getToken() async {
    return await SecureStorageService.getToken();
  }

  // Obtener todas las consultas de un paciente
  static Future<List<ConsultaCompleta>> getConsultasPorPaciente(
    String pacienteId,
  ) async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/consultas/paciente/$pacienteId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => ConsultaCompleta.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener consultas');
      }
    } catch (e) {
      print('Error en getConsultasPorPaciente: $e');
      rethrow;
    }
  }

  // Obtener consultas de tipo armazón
  static Future<List<ConsultaCompleta>> getConsultasArmazon(
    String pacienteId,
  ) async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/consulta_completa/paciente/$pacienteId/tipo_armazon/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => ConsultaCompleta.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener consultas de armazón');
      }
    } catch (e) {
      print('Error en getConsultasArmazon: $e');
      rethrow;
    }
  }

  // Obtener una consulta por su ID
  static Future<ConsultaCompleta> getConsultaId(String consultaId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await _dio.get(
        '/consulta_completa/$consultaId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return ConsultaCompleta.fromJson(response.data);
      } else {
        throw Exception('Error al obtener la consulta por ID');
      }
    } catch (e) {
      print('Error en getConsultaPorId: $e');
      rethrow;
    }
  }

  // Obtener consultas de tipo contacto
  static Future<List<ConsultaCompleta>> getConsultasContacto(
    String pacienteId,
  ) async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/consulta_completa/paciente/$pacienteId/tipo_contacto/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => ConsultaCompleta.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener consultas de contacto');
      }
    } catch (e) {
      print('Error en getConsultasContacto: $e');
      rethrow;
    }
  }

  // Guardar consultas
  static Future<bool> registrarConsultaCompleta(
    Map<String, dynamic> payload,
  ) async {
    try {
      final token = await _getToken();

      final response = await _dio.post(
        '/consulta_completa/',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        //print('Consulta registrada correctamente.');
        return true;
      } else {
        print('Error al registrar consulta: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error en registrarConsultaCompleta: $e');
      return false;
    }
  }
}
