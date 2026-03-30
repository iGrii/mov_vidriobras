import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/categoria_model.dart';

class CategoriaService {
  static const String _baseUrl = 'https://api.vidriobras.com';

  /// Obtiene la lista de categorías desde el backend.
  ///
  /// Retorna un arreglo vacío en caso de error o si la respuesta no
  /// contiene datos válidos.
  Future<List<Categoria>> obtenerCategorias() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/flutter/productos/categorias'))
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      // debug
      // ignore: avoid_print
      print(
        'CategoriaService.obtenerCategorias response: ${response.statusCode} $data',
      );
      if (response.statusCode == 200 && data['success'] == true) {
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((e) => Categoria.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener categorías: $e');
    }
    return [];
  }
}
