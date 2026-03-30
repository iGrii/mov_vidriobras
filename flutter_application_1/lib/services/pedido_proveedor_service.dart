import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pedido_proveedor_model.dart';

class PedidoProveedorService {
  static const String _baseUrl = 'https://api.vidriobras.com';

  Future<PedidoProveedorResponse> obtenerProductosBajoStock({
    int maxCantidad = 10,
    int limit = 200,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/flutter/productos/listar').replace(
        queryParameters: {
          'max_cantidad': maxCantidad.toString(),
          'limit': limit.toString(),
          'offset': '0',
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        return PedidoProveedorResponse.fromJson(json);
      }

      return PedidoProveedorResponse(
        success: false,
        productos: const [],
        message: json is Map<String, dynamic>
            ? json['message']?.toString() ?? 'No se pudo cargar el pedido'
            : 'No se pudo cargar el pedido',
      );
    } catch (e) {
      return PedidoProveedorResponse(
        success: false,
        productos: const [],
        message: 'Error de conexión: $e',
      );
    }
  }

  Future<PedidoProveedorResponse> buscarProductosParaAgregar(
    String query, {
    int minCantidad = 11,
    int limit = 50,
  }) async {
    final texto = query.trim();
    if (texto.length < 2) {
      return const PedidoProveedorResponse(
        success: true,
        productos: [],
        message: '',
      );
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl/api/flutter/productos/buscar',
      ).replace(queryParameters: {'q': texto, 'limit': limit.toString()});

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        final data = json['data'] is List ? json['data'] as List : const [];
        final productos = data
            .map(
              (item) => PedidoProveedorProducto.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .where((producto) => producto.cantidadActual >= minCantidad)
            .map((producto) => producto.copyWith(agregadoManual: true))
            .toList();

        return PedidoProveedorResponse(
          success: true,
          productos: productos,
          message: '',
        );
      }

      return PedidoProveedorResponse(
        success: false,
        productos: const [],
        message: json is Map<String, dynamic>
            ? json['message']?.toString() ?? 'No se pudo buscar productos'
            : 'No se pudo buscar productos',
      );
    } catch (e) {
      return PedidoProveedorResponse(
        success: false,
        productos: const [],
        message: 'Error de conexión: $e',
      );
    }
  }
}
