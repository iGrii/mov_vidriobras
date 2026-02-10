class Producto {
  final String? id;
  final String nombre;
  final String? descripcion;
  final String? categoria;
  final String? imagen;
  final double? precio;

  Producto({
    this.id,
    required this.nombre,
    this.descripcion,
    this.categoria,
    this.imagen,
    this.precio,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id_producto']?.toString() ?? json['id']?.toString(),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      categoria: json['categoria']?.toString(),
      imagen: json['IMG_P']?.toString() ?? json['imagen']?.toString(),
      precio: (json['precio_unitario'] is num)
          ? (json['precio_unitario'] as num).toDouble()
          : (json['precio'] is num ? (json['precio'] as num).toDouble() : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'IMG_P': imagen,
      'precio_unitario': precio,
    };
  }
}
