class PedidoProveedorProducto {
  final String id;
  final String nombre;
  final String? codigo;
  final int cantidadActual;
  final double? precio;
  final String? grosor;
  final String? categoriaId;
  final String? imagen;
  final bool agregadoManual;

  const PedidoProveedorProducto({
    required this.id,
    required this.nombre,
    required this.cantidadActual,
    this.codigo,
    this.precio,
    this.grosor,
    this.categoriaId,
    this.imagen,
    this.agregadoManual = false,
  });

  bool get stockBajo => cantidadActual <= 10;

  int get cantidadSugerida {
    final sugerida = 11 - cantidadActual;
    return sugerida > 0 ? sugerida : 1;
  }

  PedidoProveedorProducto copyWith({
    String? id,
    String? nombre,
    String? codigo,
    int? cantidadActual,
    double? precio,
    String? grosor,
    String? categoriaId,
    String? imagen,
    bool? agregadoManual,
  }) {
    return PedidoProveedorProducto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      precio: precio ?? this.precio,
      grosor: grosor ?? this.grosor,
      categoriaId: categoriaId ?? this.categoriaId,
      imagen: imagen ?? this.imagen,
      agregadoManual: agregadoManual ?? this.agregadoManual,
    );
  }

  factory PedidoProveedorProducto.fromJson(Map<String, dynamic> json) {
    return PedidoProveedorProducto(
      id: json['id_producto']?.toString() ?? json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      codigo: json['codigo']?.toString(),
      cantidadActual: json['cantidad'] is num
          ? (json['cantidad'] as num).toInt()
          : int.tryParse(json['cantidad']?.toString() ?? '') ?? 0,
      precio: json['precio_unitario'] is num
          ? (json['precio_unitario'] as num).toDouble()
          : (json['precio'] is num ? (json['precio'] as num).toDouble() : null),
      grosor: json['grosor']?.toString(),
      categoriaId: json['categoria_id']?.toString(),
      imagen: json['IMG_P']?.toString() ?? json['imagen']?.toString(),
      agregadoManual: json['agregado_manual'] == true,
    );
  }
}

class PedidoProveedorResponse {
  final bool success;
  final List<PedidoProveedorProducto> productos;
  final String message;

  const PedidoProveedorResponse({
    required this.success,
    required this.productos,
    required this.message,
  });

  factory PedidoProveedorResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is List ? json['data'] as List : const [];
    return PedidoProveedorResponse(
      success: json['success'] == true,
      productos: data
          .map(
            (item) => PedidoProveedorProducto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}
