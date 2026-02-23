import 'package:dio/dio.dart';
import '../utils/dio_client.dart';

class ProductosService {
  final Dio dio = DioClient.dio;

  // Listar todos los productos
  Future<List<Map<String, dynamic>>> listarProductos() async {
    try {
      final response = await dio.get('/api/productos');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error al listar productos: $e');
      return [];
    }
  }

  // Obtener producto por ID
  Future<Map<String, dynamic>?> obtenerProductoPorId(String id) async {
    try {
      final response = await dio.get('/api/productos/$id');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error al obtener producto: $e');
      return null;
    }
  }

  // Crear producto
  Future<Map<String, dynamic>?> crearProducto(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/api/productos', data: data);
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error al crear producto: $e');
      return null;
    }
  }

  // Obtener detalles por lista de IDs
  Future<List<Map<String, dynamic>>> obtenerDetallesPorIds(
    List<String> ids,
  ) async {
    try {
      final response = await dio.post(
        '/api/productos/detalles',
        data: {'ids': ids},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener detalles: $e');
      return [];
    }
  }

  // Listar imágenes
  Future<List<Map<String, dynamic>>> listarImagenes() async {
    try {
      final response = await dio.get('/api/productos/images');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((img) => img as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error al listar imágenes: $e');
      return [];
    }
  }

  // Subir imagen (multipart)
  Future<Map<String, dynamic>?> subirImagen(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        '/api/productos/upload-image',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }
}
