import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/selector_model.dart';

class SelectorService {
  static const String _baseUrl = 'http://localhost:5000';

  /// Obtener lista de áreas disponibles
  Future<AreasResponse> getAreas() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/selector/areas'))
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return AreasResponse(
          success: true,
          data: data['data'],
          message: data['message'],
        );
      } else {
        return AreasResponse(
          success: false,
          message: data['message'] ?? 'Error al obtener áreas',
        );
      }
    } catch (e) {
      return AreasResponse(success: false, message: 'Error de conexión: $e');
    }
  }
}
