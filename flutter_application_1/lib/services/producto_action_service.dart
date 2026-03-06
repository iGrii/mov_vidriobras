import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/almacen_model.dart';
import '../models/producto_action_model.dart';

/// Servicio centralizado para acciones de producto (editar, eliminar)
class ProductoActionService {
  static const String _baseUrl = 'http://localhost:5000';

  /// Confirma y elimina un producto
  Future<bool> confirmarYEliminarProducto(
    BuildContext context,
    Producto producto,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok != true) return false;

    final request = EliminarProductoRequest(productoId: producto.id ?? '');
    final resp = await eliminarProducto(request);

    if (!context.mounted) return false;

    if (resp.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${resp.mensaje}')));
      return false;
    }
  }

  /// Elimina un producto usando el servicio de acciones
  Future<ProductoActionResponse> eliminarProducto(
    EliminarProductoRequest request,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
              '$_baseUrl/api/flutter/productos/eliminar/${request.productoId}',
            ),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ProductoActionResponse(
          success: true,
          mensaje: data['message'] ?? 'Producto eliminado exitosamente',
          productoId: request.productoId,
          accion: 'eliminar',
        );
      } else {
        return ProductoActionResponse(
          success: false,
          mensaje: data['message'] ?? 'Error al eliminar producto',
          productoId: request.productoId,
          accion: 'eliminar',
        );
      }
    } catch (e) {
      return ProductoActionResponse(
        success: false,
        mensaje: 'Error de conexión: $e',
        productoId: request.productoId,
        accion: 'eliminar',
      );
    }
  }

  /// Edita un producto usando el servicio de acciones
  Future<ProductoActionResponse> editarProducto(
    EditarProductoRequest request,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse(
              '$_baseUrl/api/flutter/productos/actualizar/${request.productoId}',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ProductoActionResponse(
          success: true,
          mensaje: data['message'] ?? 'Producto editado exitosamente',
          productoId: request.productoId,
          accion: 'editar',
        );
      } else {
        return ProductoActionResponse(
          success: false,
          mensaje: data['message'] ?? 'Error al editar producto',
          productoId: request.productoId,
          accion: 'editar',
        );
      }
    } catch (e) {
      return ProductoActionResponse(
        success: false,
        mensaje: 'Error de conexión: $e',
        productoId: request.productoId,
        accion: 'editar',
      );
    }
  }
}
