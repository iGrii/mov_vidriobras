// services/notificacion_service.dart
// Servicio HTTP para consumir /api/notificaciones del backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/notificacion_model.dart';

class NotificacionService {
  // ── Ajusta esta URL a la de tu backend ──────────────────────
  static const String _baseUrl = 'http://localhost:5000/api/notificaciones';

  // ─────────────────────────────────────────────────────────────
  // GET  /api/notificaciones
  // ─────────────────────────────────────────────────────────────
  Future<List<NotificacionModel>> obtenerNotificaciones({
    int limit = 50,
    int offset = 0,
    String? estadoId,
    String? idCliente,
    String? tipo,
  }) async {
    try {
      final params = <String, String>{
        'limit':  limit.toString(),
        'offset': offset.toString(),
        if (estadoId != null)  'estado_id':  estadoId,
        if (idCliente != null) 'id_cliente': idCliente,
        if (tipo != null)      'tipo':        tipo,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = body['data'] as List<dynamic>? ?? [];
        return lista
            .map((e) => NotificacionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      print('[NotificacionService] Error ${response.statusCode}: ${response.body}');
      return [];
    } catch (e) {
      print('[NotificacionService] Error en obtenerNotificaciones: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // GET  /api/notificaciones/<id>
  // ─────────────────────────────────────────────────────────────
  Future<NotificacionModel?> obtenerPorId(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return NotificacionModel.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('[NotificacionService] Error en obtenerPorId: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // POST /api/notificaciones
  // ─────────────────────────────────────────────────────────────
  Future<NotificacionModel?> crearNotificacion({
    required String nombre,
    String? descripcion,
    String? tipo,
    String? estadoNotificacionId,
    String? idCliente,
  }) async {
    try {
      final body = <String, dynamic>{
        'nombre':      nombre,
        if (descripcion != null)          'descripcion':             descripcion,
        if (tipo != null)                 'tipo':                    tipo,
        if (estadoNotificacionId != null) 'estado_notificacion_id':  estadoNotificacionId,
        if (idCliente != null)            'id_cliente':              idCliente,
      };

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final respBody = jsonDecode(response.body) as Map<String, dynamic>;
        return NotificacionModel.fromJson(
            respBody['data'] as Map<String, dynamic>);
      }

      print('[NotificacionService] Error al crear: ${response.body}');
      return null;
    } catch (e) {
      print('[NotificacionService] Error en crearNotificacion: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PATCH /api/notificaciones/<id>/estado
  // ─────────────────────────────────────────────────────────────
  Future<bool> actualizarEstado({
    required String idNotificacion,
    required String estadoNotificacionId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_baseUrl/$idNotificacion/estado'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'estado_notificacion_id': estadoNotificacionId}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('[NotificacionService] Error en actualizarEstado: $e');
      return false;
    }
  }
}