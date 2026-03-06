import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/reporte_model.dart';

/// Servicio para obtener reportes de cambios de productos
class ReportesService {
  static const String _baseUrl = 'http://localhost:5000/api/flutter/productos';

  /// Obtener reportes con filtros opcionales
  Future<ReportesResponse> obtenerReportes({
    int limit = 100,
    int offset = 0,
    String? tipo, // CREAR, EDITAR, ELIMINAR
    String? productoId,
  }) async {
    try {
      String url = '$_baseUrl/reportes?limit=$limit&offset=$offset';
      if (tipo != null) url += '&tipo=$tipo';
      if (productoId != null) url += '&producto_id=$productoId';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        return ReportesResponse.fromJson(json);
      } else {
        return ReportesResponse(
          success: false,
          reportes: [],
          mensaje: json['message'] ?? 'Error al obtener reportes',
        );
      }
    } catch (e) {
      return ReportesResponse(
        success: false,
        reportes: [],
        mensaje: 'Error de conexión: $e',
      );
    }
  }

  /// Obtener solo creaciones
  Future<ReportesResponse> obtenerCreaciones({
    int limit = 100,
    int offset = 0,
  }) => obtenerReportes(tipo: 'CREAR', limit: limit, offset: offset);

  /// Obtener solo ediciones
  Future<ReportesResponse> obtenerEdiciones({
    int limit = 100,
    int offset = 0,
  }) => obtenerReportes(tipo: 'EDITAR', limit: limit, offset: offset);

  /// Obtener solo eliminaciones
  Future<ReportesResponse> obtenerEliminaciones({
    int limit = 100,
    int offset = 0,
  }) => obtenerReportes(tipo: 'ELIMINAR', limit: limit, offset: offset);

  /// Obtener resumen de reportes
  Future<ResumenReportes> obtenerResumen({int dias = 30}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/reportes/resumen?dias=$dias'))
          .timeout(const Duration(seconds: 10));

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        return ResumenReportes.fromJson(json['data'] ?? {});
      } else {
        return ResumenReportes(crear: 0, editar: 0, eliminar: 0, total: 0);
      }
    } catch (e) {
      return ResumenReportes(crear: 0, editar: 0, eliminar: 0, total: 0);
    }
  }

  /// Obtener historial de un producto específico
  Future<ReportesResponse> obtenerHistorialProducto(
    String productoId, {
    int limit = 100,
    int offset = 0,
  }) => obtenerReportes(productoId: productoId, limit: limit, offset: offset);
}
