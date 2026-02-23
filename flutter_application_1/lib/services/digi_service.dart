import 'package:dio/dio.dart';
import 'dart:io';
import '../utils/dio_client.dart';
import '../models/vidriobras_model.dart';

class DigiService {
  final Dio _dio = DioClient.dio;

  Future<List<Producto>> getProductos() async {
    try {
      final response = await _dio.get('/api/productos');
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => Producto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (data is Map && data['content'] is List) {
        return (data['content'] as List)
            .map((e) => Producto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw Exception('Respuesta inválida del backend');
    } on DioError catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response?.statusCode}'
          : e.message;
      throw Exception('Error cargando productos: $msg');
    }
  }

  Future<Producto> crearProducto({
    required String nombre,
    String? descripcion,
    String? categoria,
    double? precio,
    String? grosor,
    int? cantidad,
    File? imagenFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nombre': nombre,
        'descripcion': descripcion ?? '',
        'categoria': categoria ?? '',
        'precio_unitario': precio ?? 0.0,
        'grosor': grosor ?? '',
        'cantidad': cantidad ?? 1,
      });

      // Si hay una imagen, agregarla al form data
      if (imagenFile != null) {
        final filename = imagenFile.path.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'IMG_P',
            await MultipartFile.fromFile(imagenFile.path, filename: filename),
          ),
        );
      }

      final response = await _dio.post('/api/productos', data: formData);

      return Producto.fromJson(Map<String, dynamic>.from(response.data));
    } on DioError catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response?.statusCode} - ${e.response?.data}'
          : e.message;
      throw Exception('Error creando producto: $msg');
    }
  }

  Future<Producto> getProductoById(String id) async {
    try {
      final response = await _dio.get('/api/productos/$id');
      final data = response.data;

      if (data is Map) {
        return Producto.fromJson(Map<String, dynamic>.from(data));
      }

      throw Exception('Respuesta inválida al obtener producto');
    } on DioError catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response?.statusCode} - ${e.response?.data}'
          : e.message;
      throw Exception('Error obteniendo producto: $msg');
    }
  }

  Future<Producto> actualizarProducto(
    String id, {
    required String nombre,
    String? descripcion,
    String? categoria,
    double? precio,
    String? grosor,
    int? cantidad,
    File? imagenFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nombre': nombre,
        'descripcion': descripcion ?? '',
        'categoria': categoria ?? '',
        'precio_unitario': precio ?? 0.0,
        'grosor': grosor ?? '',
        'cantidad': cantidad ?? 1,
      });

      if (imagenFile != null) {
        final filename = imagenFile.path.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'IMG_P',
            await MultipartFile.fromFile(imagenFile.path, filename: filename),
          ),
        );
      }

      final response = await _dio.put('/api/productos/$id', data: formData);

      return Producto.fromJson(Map<String, dynamic>.from(response.data));
    } on DioError catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response?.statusCode} - ${e.response?.data}'
          : e.message;
      throw Exception('Error actualizando producto: $msg');
    }
  }

  Future<void> eliminarProducto(String id) async {
    try {
      await _dio.delete('/api/productos/$id');
    } on DioError catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response?.statusCode} - ${e.response?.data}'
          : e.message;
      throw Exception('Error eliminando producto: $msg');
    }
  }

  Future<List<String>> getCategorias() async {
    try {
      final response = await _dio.get('/api/categorias');
      final data = response.data;

      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }

      if (data is Map && data['data'] is List) {
        return (data['data'] as List).map((e) => e.toString()).toList();
      }

      throw Exception('Respuesta inválida al obtener categorías');
    } on DioError catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response?.statusCode} - ${e.response?.data}'
          : e.message;
      throw Exception('Error obteniendo categorías: $msg');
    }
  }
}
