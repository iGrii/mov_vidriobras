import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectorService {
  static const String _baseUrl = 'http://localhost:5000';

  static const String operacionesId = '3f31e127-c7f1-49cf-8c95-efb846882165';
  static const String almacenId = '8426fd1a-2633-49d1-bc83-f6400bb58708';

  /// Login para el área de OPERACIONES
  /// Solo permite personal cuyo tipo_personal_id = OPERACIONES_ID
  Future<LoginResponse> loginOperaciones(
    String nombre,
    String codigoEmpresa,
  ) async {
    try {
      final payload = {
        'area_id': operacionesId,
        'nombre': nombre,
        'codigo_empresa': codigoEmpresa,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/selector/login-operaciones'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return LoginResponse(
          success: true,
          data: data['data'],
          message: data['message'],
        );
      } else if (response.statusCode == 401) {
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Usuario no tiene acceso a OPERACIONES',
        );
      } else if (response.statusCode == 403) {
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Acceso denegado',
        );
      } else {
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Error en servidor',
        );
      }
    } catch (e) {
      return LoginResponse(success: false, message: 'Error de conexión: $e');
    }
  }

  /// Login para el área de ALMACÉN
  /// Solo permite personal cuyo tipo_personal_id = ALMACEN_ID
  Future<LoginResponse> loginAlmacen(
    String nombre,
    String codigoEmpresa,
  ) async {
    try {
      final payload = {
        'area_id': almacenId,
        'nombre': nombre,
        'codigo_empresa': codigoEmpresa,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/selector/login-almacen'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return LoginResponse(
          success: true,
          data: data['data'],
          message: data['message'],
        );
      } else if (response.statusCode == 401) {
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Usuario no tiene acceso a ALMACÉN',
        );
      } else if (response.statusCode == 403) {
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Acceso denegado',
        );
      } else {
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Error en servidor',
        );
      }
    } catch (e) {
      return LoginResponse(success: false, message: 'Error de conexión: $e');
    }
  }
}

/// Modelo de respuesta de login
class LoginResponse {
  final bool success;
  final dynamic data;
  final String message;

  LoginResponse({required this.success, this.data, required this.message});
}
