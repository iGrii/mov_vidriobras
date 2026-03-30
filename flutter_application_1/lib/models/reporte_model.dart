/// Modelo para un reporte de cambio de producto
class ReporteProducto {
  final String id;
  final String productoId;
  final String productoNombre;
  final String? productoCodigo;
  final String tipo; // CREAR, EDITAR, ELIMINAR
  final String? detalles;
  final DateTime fechaCambio;
  final String? usuario;
  final Map<String, dynamic> rawData;

  ReporteProducto({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    this.productoCodigo,
    required this.tipo,
    this.detalles,
    required this.fechaCambio,
    this.usuario,
    required this.rawData,
  });

  static DateTime _parseFecha(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;

    final text = value.toString().trim();
    if (text.isEmpty) return DateTime.now();

    return DateTime.tryParse(text) ?? DateTime.now();
  }

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }

  factory ReporteProducto.fromJson(Map<String, dynamic> json) {
    final productoNombre =
        _firstNonEmpty([
          json['nombre_producto'],
          json['producto_nombre'],
          json['nombre'],
          json['name'],
          json['product_name'],
          json['producto'],
        ]) ??
        'Sin nombre';

    final tipo =
        _firstNonEmpty([
          json['tipo'],
          json['accion'],
          json['event'],
          json['type'],
        ]) ??
        'DESCONOCIDO';

    return ReporteProducto(
      id: json['id']?.toString() ?? '',
      productoId: json['producto_id']?.toString() ?? '',
      productoNombre: productoNombre,
      productoCodigo: _firstNonEmpty([
        json['codigo'],
        json['producto_codigo'],
        json['codigo_producto'],
      ]),
      tipo: tipo,
      detalles: _firstNonEmpty([
        json['detalles'],
        json['details'],
        json['descripcion'],
        json['mensaje'],
      ]),
      fechaCambio: _parseFecha(
        _firstNonEmpty([
          json['fecha_cambio'],
          json['fecha'],
          json['created_at'],
          json['createdAt'],
          json['updated_at'],
          json['updatedAt'],
        ]),
      ),
      usuario: _firstNonEmpty([
        json['usuario'],
        json['usuario_nombre'],
        json['user'],
        json['created_by'],
      ]),
      rawData: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'nombre_producto': productoNombre,
      'codigo': productoCodigo,
      'tipo': tipo,
      'detalles': detalles,
      'fecha_cambio': fechaCambio.toIso8601String(),
      'usuario': usuario,
    };
  }

  String get tipoNormalizado {
    final text = tipo.trim().toUpperCase();
    if (text.contains('ELIM')) return 'ELIMINAR';
    if (text.contains('EDIT') || text.contains('ACTUAL')) return 'EDITAR';
    if (text.contains('CRE') || text.contains('ADD')) return 'CREAR';
    return text.isEmpty ? 'DESCONOCIDO' : text;
  }

  String get tipoEtiqueta {
    switch (tipoNormalizado) {
      case 'CREAR':
        return 'Creado';
      case 'EDITAR':
        return 'Editado';
      case 'ELIMINAR':
        return 'Eliminado';
      default:
        return tipo;
    }
  }

  String get fechaFormateada {
    final dia = fechaCambio.day.toString().padLeft(2, '0');
    final mes = fechaCambio.month.toString().padLeft(2, '0');
    final anio = fechaCambio.year.toString();
    final hora = fechaCambio.hour.toString().padLeft(2, '0');
    final minuto = fechaCambio.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$minuto';
  }

  String get descripcionCorta {
    final parts = <String>[
      'Producto: $productoNombre',
      if (productoCodigo != null && productoCodigo!.isNotEmpty)
        'Codigo: $productoCodigo',
      if (usuario != null && usuario!.isNotEmpty) 'Usuario: $usuario',
      'Fecha: $fechaFormateada',
      if (detalles != null && detalles!.isNotEmpty) 'Detalle: $detalles',
    ];
    return '${tipoEtiqueta} | ${parts.join(' | ')}';
  }

  @override
  String toString() => descripcionCorta;
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
      total:
          ((json['CREAR'] ?? 0) +
                  (json['EDITAR'] ?? 0) +
                  (json['ELIMINAR'] ?? 0))
              as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'CREAR': crear, 'EDITAR': editar, 'ELIMINAR': eliminar};
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
