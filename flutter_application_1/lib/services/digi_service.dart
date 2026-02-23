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
        formData.files.add(
          MapEntry(
            'IMG_P',
            await MultipartFile.fromFile(
              imagenFile.path,
              filename: imagenFile.path.split('/').last,
            ),
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
}
