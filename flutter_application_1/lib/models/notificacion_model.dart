// models/notificacion_model.dart
// Modelo que representa una notificación de servicio de la tabla `notificacion`

class NotificacionModel {
  final String idNotificacion;
  final String? nombre;
  final String? descripcion;
  final String? tipo;
  final String? estadoNotificacionId;
  final String? idCliente;

  const NotificacionModel({
    required this.idNotificacion,
    this.nombre,
    this.descripcion,
    this.tipo,
    this.estadoNotificacionId,
    this.idCliente,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      idNotificacion:      json['id_notificacion']?.toString() ?? '',
      nombre:              json['nombre']?.toString(),
      descripcion:         json['descripcion']?.toString(),
      tipo:                json['tipo']?.toString(),
      estadoNotificacionId: json['estado_notificacion_id']?.toString(),
      idCliente:           json['id_cliente']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_notificacion':        idNotificacion,
        'nombre':                 nombre,
        'descripcion':            descripcion,
        'tipo':                   tipo,
        'estado_notificacion_id': estadoNotificacionId,
        'id_cliente':             idCliente,
      };

  NotificacionModel copyWith({
    String? idNotificacion,
    String? nombre,
    String? descripcion,
    String? tipo,
    String? estadoNotificacionId,
    String? idCliente,
  }) {
    return NotificacionModel(
      idNotificacion:      idNotificacion      ?? this.idNotificacion,
      nombre:              nombre              ?? this.nombre,
      descripcion:         descripcion         ?? this.descripcion,
      tipo:                tipo                ?? this.tipo,
      estadoNotificacionId: estadoNotificacionId ?? this.estadoNotificacionId,
      idCliente:           idCliente           ?? this.idCliente,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Modelo del evento Pusher de notificaciones
// ─────────────────────────────────────────────────────────────

/// Tipos de acciones que puede traer un evento Pusher de notificaciones
enum AccionNotificacion {
  nuevoServicio,
  estadoActualizado,
  desconocida,
}

class NotificacionPusherEvento {
  final AccionNotificacion accion;
  final String tipo;         // 'notificacion_creada' | 'notificacion_actualizada'
  final String mensaje;
  final String? nombre;
  final String? descripcion;
  final String? tipoServicio;
  final String? cliente;
  final String? estado;
  final String? idNotificacion;
  final String? timestamp;

  const NotificacionPusherEvento({
    required this.accion,
    required this.tipo,
    required this.mensaje,
    this.nombre,
    this.descripcion,
    this.tipoServicio,
    this.cliente,
    this.estado,
    this.idNotificacion,
    this.timestamp,
  });

  factory NotificacionPusherEvento.fromJson(Map<String, dynamic> json) {
    final tipoStr = json['tipo']?.toString() ?? '';
    AccionNotificacion accion;

    switch (tipoStr) {
      case 'notificacion_creada':
        accion = AccionNotificacion.nuevoServicio;
        break;
      case 'notificacion_actualizada':
        accion = AccionNotificacion.estadoActualizado;
        break;
      default:
        accion = AccionNotificacion.desconocida;
    }

    return NotificacionPusherEvento(
      accion:          accion,
      tipo:            tipoStr,
      mensaje:         json['mensaje']?.toString() ?? 'Nueva notificación',
      nombre:          json['nombre']?.toString(),
      descripcion:     json['descripcion']?.toString(),
      tipoServicio:    json['tipo_servicio']?.toString(),
      cliente:         json['cliente']?.toString(),
      estado:          json['estado']?.toString(),
      idNotificacion:  json['id_notificacion']?.toString(),
      timestamp:       json['timestamp']?.toString(),
    );
  }
}