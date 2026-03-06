// Modelo de Producto para Almacén
class Producto {
  final String? id;
  final String nombre;
  final String? descripcion;
  final String? categoriaId;
  final String? imagen;
  final double? precio;
  final int? cantidad;
  final String? codigo;
  final String? grosor;

  Producto({
    this.id,
    required this.nombre,
    this.descripcion,
    this.categoriaId,
    this.imagen,
    this.precio,
    this.cantidad,
    this.codigo,
    this.grosor,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id_producto']?.toString() ?? json['id']?.toString(),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      categoriaId: json['categoria_id']?.toString(),
      imagen: json['IMG_P']?.toString() ?? json['imagen']?.toString(),
      precio: (json['precio_unitario'] is num)
          ? (json['precio_unitario'] as num).toDouble()
          : (json['precio'] is num ? (json['precio'] as num).toDouble() : null),
      cantidad: json['cantidad'] is num
          ? (json['cantidad'] as num).toInt()
          : null,
      codigo: json['codigo']?.toString(),
      grosor: json['grosor']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'IMG_P': imagen,
      'precio_unitario': precio,
      'cantidad': cantidad,
      'codigo': codigo,
      'grosor': grosor,
    };
  }
}

// Modelo para crear producto
class CrearProductoRequest {
  final String nombre;
  final String? descripcion;
  final String? categoriaId;
  final double precio;
  final int? cantidad;
  final String? codigo;
  final String? grosor;
  final String? imagen; // URL o base64

  CrearProductoRequest({
    required this.nombre,
    this.descripcion,
    this.categoriaId,
    required this.precio,
    this.cantidad,
    this.codigo,
    this.grosor,
    this.imagen,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'precio_unitario': precio,
      'cantidad': cantidad,
      'codigo': codigo,
      'grosor': grosor,
      'IMG_P': imagen,
    };
  }
}

// Modelo de respuesta genérica
class AlmacenResponse<T> {
  final bool success;
  final T? data;
  final String message;

  AlmacenResponse({required this.success, this.data, required this.message});

  factory AlmacenResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataConverter,
  ) {
    return AlmacenResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? dataConverter(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}

// Modelo de lista de productos
class ProductoListResponse {
  final bool success;
  final List<Producto> productos;
  final String message;

  ProductoListResponse({
    required this.success,
    required this.productos,
    required this.message,
  });

  factory ProductoListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> productosData = json['data'] is List
        ? json['data']
        : [];
    final productos = productosData
        .map((p) => Producto.fromJson(p as Map<String, dynamic>))
        .toList();

    return ProductoListResponse(
      success: json['success'] ?? false,
      productos: productos,
      message: json['message'] ?? '',
    );
  }
}
