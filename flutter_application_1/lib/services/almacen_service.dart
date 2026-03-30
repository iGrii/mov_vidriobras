import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

import '../models/almacen_model.dart';

class AlmacenService {
  static const String _baseUrl = 'https://api.vidriobras.com';

  String _mapBackendError({
    String? message,
    String? details,
    String fallback = 'Error en el servidor',
  }) {
    final combined = '${message ?? ''} ${details ?? ''}'.toLowerCase();
    if (combined.contains('productos_codigo_key') ||
        combined.contains('key (codigo)=') ||
        combined.contains('duplicate key value')) {
      return 'El codigo del producto ya existe. Usa otro codigo.';
    }
    if ((message ?? '').trim().isNotEmpty) {
      return message!.trim();
    }
    return fallback;
  }

  /// Obtener lista de productos del almacén
  Future<ProductoListResponse> obtenerProductos({
    String? categoriaId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/flutter/productos/listar').replace(
        queryParameters: {
          if (categoriaId != null) 'categoria_id': categoriaId,
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ProductoListResponse.fromJson(data);
      } else {
        return ProductoListResponse(
          success: false,
          productos: [],
          message: data['message'] ?? 'Error al obtener productos',
        );
      }
    } catch (e) {
      return ProductoListResponse(
        success: false,
        productos: [],
        message: 'Error de conexión: $e',
      );
    }
  }

  /// Buscar productos
  Future<ProductoListResponse> buscarProductos(
    String query, {
    int limit = 50,
  }) async {
    final q = query.trim();
    if (q.length < 2) {
      return obtenerProductos(limit: limit, offset: 0);
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl/api/flutter/productos/buscar',
      ).replace(queryParameters: {'q': q, 'limit': limit.toString()});

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ProductoListResponse.fromJson(data);
      } else {
        return ProductoListResponse(
          success: false,
          productos: [],
          message: data['message'] ?? 'Error al buscar productos',
        );
      }
    } catch (e) {
      return ProductoListResponse(
        success: false,
        productos: [],
        message: 'Error de conexión: $e',
      );
    }
  }

  /// Crear un nuevo producto
  ///
  /// Si se proporciona [imagenFile], se enviará como multipart/form-data
  /// utilizando el campo `file`, de lo contrario se asume que el request
  /// contiene la URL en `IMG_P`.
  Future<AlmacenResponse<Producto>> crearProducto(
    CrearProductoRequest request, {
    Uint8List? imageBytes,
    String? filename,
  }) async {
    try {
      http.Response response;
      if (imageBytes != null && filename != null) {
        // enviar multipart con bytes
        final uri = Uri.parse('$_baseUrl/api/flutter/productos/registrar');
        final requestMultipart = http.MultipartRequest('POST', uri);
        requestMultipart.fields.addAll(
          request.toJson().map((k, v) => MapEntry(k, v?.toString() ?? '')),
        );
        requestMultipart.files.add(
          http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
        );
        final streamed = await requestMultipart.send().timeout(
          const Duration(seconds: 20),
        );
        response = await http.Response.fromStream(streamed);
      } else {
        // enviar JSON
        response = await http
            .post(
              Uri.parse('$_baseUrl/api/flutter/productos/registrar'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(request.toJson()),
            )
            .timeout(const Duration(seconds: 10));
      }

      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final producto = Producto.fromJson(data['data']);
        return AlmacenResponse(
          success: true,
          data: producto,
          message: data['message'] ?? 'Producto creado exitosamente',
        );
      } else {
        return AlmacenResponse(
          success: false,
          message: _mapBackendError(
            message: data['message']?.toString(),
            details: data['details']?.toString(),
            fallback: 'Error al crear producto',
          ),
        );
      }
    } catch (e) {
      return AlmacenResponse(success: false, message: 'Error de conexión: $e');
    }
  }

  /// Obtener un producto por ID
  Future<AlmacenResponse<Producto>> obtenerProductoporId(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/flutter/productos/obtener/$id'))
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final producto = Producto.fromJson(data['data']);
        return AlmacenResponse(
          success: true,
          data: producto,
          message: data['message'] ?? 'Producto obtenido',
        );
      } else {
        return AlmacenResponse(
          success: false,
          message: data['message'] ?? 'Producto no encontrado',
        );
      }
    } catch (e) {
      return AlmacenResponse(success: false, message: 'Error de conexión: $e');
    }
  }

  /// Actualizar un producto
  Future<AlmacenResponse<Producto>> actualizarProducto(
    String id,
    CrearProductoRequest request,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/api/flutter/productos/actualizar/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}

      if (response.statusCode == 200 && data['success'] == true) {
        final producto = Producto.fromJson(data['data']);
        return AlmacenResponse(
          success: true,
          data: producto,
          message: data['message'] ?? 'Producto actualizado',
        );
      } else {
        return AlmacenResponse(
          success: false,
          message: _mapBackendError(
            message: data['message']?.toString(),
            details: data['details']?.toString(),
            fallback: 'Error al actualizar producto',
          ),
        );
      }
    } catch (e) {
      return AlmacenResponse(success: false, message: 'Error de conexión: $e');
    }
  }

  /// Actualizar producto con posibilidad de enviar imagen como multipart
  Future<AlmacenResponse<Producto>> actualizarProductoConImagen(
    String id,
    CrearProductoRequest request, {
    Uint8List? imageBytes,
    String? filename,
  }) async {
    try {
      http.Response response;
      if (imageBytes != null && filename != null) {
        final uri = Uri.parse('$_baseUrl/api/flutter/productos/actualizar/$id');
        final requestMultipart = http.MultipartRequest('PUT', uri);
        requestMultipart.fields.addAll(
          request.toJson().map((k, v) => MapEntry(k, v?.toString() ?? '')),
        );
        requestMultipart.files.add(
          http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
        );
        final streamed = await requestMultipart.send().timeout(
          const Duration(seconds: 20),
        );
        response = await http.Response.fromStream(streamed);
      } else {
        response = await http
            .put(
              Uri.parse('$_baseUrl/api/flutter/productos/actualizar/$id'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(request.toJson()),
            )
            .timeout(const Duration(seconds: 10));
      }

      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}

      if (response.statusCode == 200 && data['success'] == true) {
        final producto = Producto.fromJson(data['data']);
        return AlmacenResponse(
          success: true,
          data: producto,
          message: data['message'] ?? 'Producto actualizado',
        );
      } else {
        return AlmacenResponse(
          success: false,
          message: _mapBackendError(
            message: data['message']?.toString(),
            details: data['details']?.toString(),
            fallback: 'Error al actualizar producto',
          ),
        );
      }
    } catch (e) {
      return AlmacenResponse(success: false, message: 'Error de conexión: $e');
    }
  }

  /// Verifica si ya existe un producto con el mismo codigo.
  Future<bool> existeCodigoProducto(
    String codigo, {
    String? excluirProductoId,
  }) async {
    final codigoLimpio = codigo.trim();
    if (codigoLimpio.isEmpty) return false;

    final resultado = await buscarProductos(codigoLimpio, limit: 100);
    if (!resultado.success) return false;

    for (final p in resultado.productos) {
      final mismoCodigo =
          (p.codigo ?? '').trim().toLowerCase() == codigoLimpio.toLowerCase();
      final esMismoProducto =
          excluirProductoId != null && (p.id ?? '') == excluirProductoId;
      if (mismoCodigo && !esMismoProducto) {
        return true;
      }
    }
    return false;
  }

  /// Eliminar un producto
  Future<AlmacenResponse<void>> eliminarProducto(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/api/flutter/productos/eliminar/$id'))
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return AlmacenResponse(
          success: true,
          message: data['message'] ?? 'Producto eliminado',
        );
      } else {
        return AlmacenResponse(
          success: false,
          message: data['message'] ?? 'Error al eliminar producto',
        );
      }
    } catch (e) {
      return AlmacenResponse(success: false, message: 'Error de conexión: $e');
    }
  }

  /// Obtener productos por categoría
  Future<ProductoListResponse> obtenerProductosPorCategoria(
    String categoriaId,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/flutter/productos/listar',
      ).replace(queryParameters: {'categoria_id': categoriaId});
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ProductoListResponse.fromJson(data);
      } else {
        return ProductoListResponse(
          success: false,
          productos: [],
          message: data['message'] ?? 'Error al obtener productos',
        );
      }
    } catch (e) {
      return ProductoListResponse(
        success: false,
        productos: [],
        message: 'Error de conexión: $e',
      );
    }
  }

  // Nota: la gestión de categorías ahora se realiza mediante
  // [CategoriaService]. El método anterior ha quedado obsoleto.
  @deprecated
  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    return [];
  }
}
