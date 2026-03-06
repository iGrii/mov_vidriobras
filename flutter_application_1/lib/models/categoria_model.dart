class Categoria {
  final String id;
  final String descripcion;

  Categoria({required this.id, required this.descripcion});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id_categoria']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
    );
  }
}

class CategoriaListResponse {
  final bool success;
  final List<Categoria> data;
  final String message;

  CategoriaListResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory CategoriaListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    List<Categoria> list = [];
    if (raw is List) {
      list = raw
          .map((e) => Categoria.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return CategoriaListResponse(
      success: json['success'] ?? false,
      data: list,
      message: json['message'] ?? '',
    );
  }
}
