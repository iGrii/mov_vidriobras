import 'package:dio/dio.dart';
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
}
