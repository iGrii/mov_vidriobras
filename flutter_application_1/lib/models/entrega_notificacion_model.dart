class EntregaNotificacion {
  final String id;
  final String tipo;
  final String titulo;
  final String mensaje;
  final String estado;
  final DateTime timestamp;

  EntregaNotificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.estado,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory EntregaNotificacion.fromJson(Map<String, dynamic> json) {
    return EntregaNotificacion(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: json['tipo'] as String? ?? 'info',
      titulo: json['titulo'] as String? ?? 'Nueva notificación',
      mensaje: json['mensaje'] as String? ?? '',
      estado: json['estado'] as String? ?? 'PENDIENTE',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'estado': estado,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
