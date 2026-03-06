/// Modelo para un reporte de cambio de producto
class ReporteProducto {
  final String id;
  final String productoId;
  final String productoNombre;
  final String tipo; // CREAR, EDITAR, ELIMINAR
  final String? detalles;
  final DateTime fechaCambio;
  final String? usuario;

  ReporteProducto({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.tipo,
    this.detalles,
    required this.fechaCambio,
    this.usuario,
  });

  factory ReporteProducto.fromJson(Map<String, dynamic> json) {
    return ReporteProducto(
      id: json['id']?.toString() ?? '',
      productoId: json['producto_id']?.toString() ?? '',
      productoNombre: json['nombre_producto']?.toString() ?? 
                      json['producto_nombre']?.toString() ?? 
                      json['nombre']?.toString() ?? 
                      json['name']?.toString() ?? 
                      json['product_name']?.toString() ?? 
                      'Sin nombre',
      tipo: json['tipo']?.toString() ?? '',
      detalles: json['detalles']?.toString() ?? json['details']?.toString(),
      fechaCambio: json['fecha_cambio'] != null
          ? DateTime.parse(json['fecha_cambio'].toString())
          : DateTime.now(),
      usuario: json['usuario']?.toString() ?? json['user']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'nombre_producto': productoNombre,
      'tipo': tipo,
      'detalles': detalles,
      'fecha_cambio': fechaCambio.toIso8601String(),
      'usuario': usuario,
    };
  }
}

/// Modelo para el resumen de reportes
class ResumenReportes {
  final int crear;
  final int editar;
  final int eliminar;
  final int total;

  ResumenReportes({
    required this.crear,
    required this.editar,
    required this.eliminar,
    required this.total,
  });

  factory ResumenReportes.fromJson(Map<String, dynamic> json) {
    return ResumenReportes(
      crear: (json['CREAR'] ?? 0) as int,
      editar: (json['EDITAR'] ?? 0) as int,
      eliminar: (json['ELIMINAR'] ?? 0) as int,
      total: ((json['CREAR'] ?? 0) + (json['EDITAR'] ?? 0) + (json['ELIMINAR'] ?? 0)) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CREAR': crear,
      'EDITAR': editar,
      'ELIMINAR': eliminar,
    };
  }
}

/// Modelo para respuesta de reportes
class ReportesResponse {
  final bool success;
  final List<ReporteProducto> reportes;
  final String mensaje;

  ReportesResponse({
    required this.success,
    required this.reportes,
    required this.mensaje,
  });

  factory ReportesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] is List ? json['data'] : [];
    return ReportesResponse(
      success: json['success'] ?? false,
      reportes: data
          .map((r) => ReporteProducto.fromJson(r as Map<String, dynamic>))
          .toList(),
      mensaje: json['message'] ?? json['mensaje'] ?? '',
    );
  }
}
