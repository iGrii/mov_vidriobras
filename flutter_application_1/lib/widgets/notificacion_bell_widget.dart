import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 🔔 Modelo de Notificación desde la tabla notificacion
class Notificacion {
  final String idNotificacion;
  final String? nombre;
  final String? descripcion;
  final String? tipo;
  final String? estadoNotificacionId;
  final String? idCliente;

  Notificacion({
    required this.idNotificacion,
    this.nombre,
    this.descripcion,
    this.tipo,
    this.estadoNotificacionId,
    this.idCliente,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      idNotificacion: json['id_notificacion']?.toString() ?? '',
      nombre: json['nombre']?.toString(),
      descripcion: json['descripcion']?.toString(),
      tipo: json['tipo']?.toString(),
      estadoNotificacionId: json['estado_notificacion_id']?.toString(),
      idCliente: json['id_cliente']?.toString(),
    );
  }
}

/// 📡 Servicio para obtener notificaciones del backend
class NotificacionService {
  static const String _baseUrl =
      'https://api.vidriobras.com/api/notificaciones';

  /// ✅ Obtener todas las notificaciones (opcional filtrar por cliente)
  static Future<List<Notificacion>> obtenerNotificaciones({
    String? idCliente,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (idCliente != null) 'id_cliente': idCliente,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = body['data'] as List<dynamic>? ?? [];
        return lista
            .map((e) => Notificacion.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      print(
        '[NotificacionService] Error ${response.statusCode}: ${response.body}',
      );
      return [];
    } catch (e) {
      print('[NotificacionService] Error obteniendo notificaciones: $e');
      return [];
    }
  }
}

/// 🔔 Widget que muestra una Campana con Notificaciones
class NotificacionBell extends StatefulWidget {
  final String? clienteId; // Si tienes cliente_id para filtrar
  final Color bellColor;
  final Color badgeColor;
  final Function()? onRefresh; // Callback para recargar

  const NotificacionBell({
    this.clienteId,
    this.bellColor = const Color(0xFF79BDDD),
    this.badgeColor = Colors.red,
    this.onRefresh,
    super.key,
  });

  @override
  State<NotificacionBell> createState() => _NotificacionBellState();
}

class _NotificacionBellState extends State<NotificacionBell> {
  int _notificacionesCount = 0;
  List<Notificacion> _notificaciones = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  /// 📥 Cargar notificaciones del backend
  Future<void> _cargarNotificaciones() async {
    setState(() => _isLoading = true);

    try {
      final notificaciones = await NotificacionService.obtenerNotificaciones(
        idCliente: widget.clienteId,
      );

      if (mounted) {
        setState(() {
          _notificaciones = notificaciones;
          _notificacionesCount = notificaciones.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando notificaciones: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 🔄 Refrescar manualmente
  Future<void> _refrescar() async {
    await _cargarNotificaciones();
    widget.onRefresh?.call();
  }

  /// 📋 Mostrar popup con lista de notificaciones
  void _mostrarNotificaciones(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Notificaciones'),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refrescar,
              tooltip: 'Refrescar',
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _notificaciones.isEmpty
              ? const Center(child: Text('Sin notificaciones'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notificaciones.length,
                  itemBuilder: (context, index) {
                    final notif = _notificaciones[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: _getColorByTipo(notif.tipo),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notif.nombre != null)
                            Text(
                              notif.nombre!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          if (notif.descripcion != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              notif.descripcion!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                          if (notif.tipo != null) ...[
                            const SizedBox(height: 6),
                            Chip(
                              label: Text(notif.tipo!),
                              labelStyle: const TextStyle(fontSize: 10),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// 🎨 Color según tipo
  Color _getColorByTipo(String? tipo) {
    switch (tipo) {
      case 'instalacion':
        return Colors.blue;
      case 'servicio':
        return Colors.green;
      case 'urgente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔔 Campana
        GestureDetector(
          onTap: () => _mostrarNotificaciones(context),
          onLongPress: _refrescar, // Long press para refrescar
          child: Icon(Icons.notifications, color: widget.bellColor, size: 28),
        ),

        // 🔴 Badge con número de notificaciones
        if (_notificacionesCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _notificacionesCount > 99 ? '99+' : '$_notificacionesCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // ⏳ Indicador de carga
        if (_isLoading)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// 🎨 Widget completo - Ejemplo de uso en AppBar
class AppBarConNotificaciones extends StatelessWidget {
  final String? clienteId;

  const AppBarConNotificaciones({this.clienteId, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF79BDDD),
      title: const Text(
        'Mi Aplicación',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: NotificacionBell(
              clienteId: clienteId,
              bellColor: Colors.white,
              badgeColor: Colors.red,
              onRefresh: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Notificaciones actualizadas'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
