/// Modelo para respuestas de acciones sobre productos (eliminar, editar)
class ProductoActionResponse {
  final bool success;
  final String mensaje;
  final String? productoId;
  final String? accion; // 'eliminar', 'editar', etc.

  ProductoActionResponse({
    required this.success,
    required this.mensaje,
    this.productoId,
    this.accion,
  });

  factory ProductoActionResponse.fromJson(Map<String, dynamic> json) {
    return ProductoActionResponse(
      success: json['success'] ?? false,
      mensaje: json['mensaje'] ?? json['message'] ?? '',
      productoId: json['producto_id']?.toString(),
      accion: json['accion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'mensaje': mensaje,
      'producto_id': productoId,
      'accion': accion,
    };
  }
}

/// Modelo para solicitud de eliminación de producto
class EliminarProductoRequest {
  final String productoId;
  final String? razon;

  EliminarProductoRequest({
    required this.productoId,
    this.razon,
  });

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'razon': razon,
    };
  }
}

/// Modelo para solicitud de edición de producto
class EditarProductoRequest {
  final String productoId;
  final String? nombre;
  final String? descripcion;
  final double? precio;
  final int? cantidad;

  EditarProductoRequest({
    required this.productoId,
    this.nombre,
    this.descripcion,
    this.precio,
    this.cantidad,
  });

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_unitario': precio,
      'cantidad': cantidad,
    };
  }
}
