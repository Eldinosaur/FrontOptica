import 'package:dio/dio.dart';
import '../models/acuty_model.dart';
import '../utils/secure_storage_service.dart';
import '../utils/navigation.dart';

class EvolucionService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: AppConfig.baseUrl),
  );

  static Future<String?> _getToken() async {
    return await SecureStorageService.getToken();
  }

  // Obtener evolución visual por paciente
  static Future<List<EvolucionVisual>> getEvolucionPorPaciente(String pacienteId) async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/evolucion_visual/paciente/$pacienteId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => EvolucionVisual.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener evolución visual');
      }
    } catch (e) {
      print('Error en getEvolucionPorPaciente: $e');
      rethrow;
    }
  }
}
