import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/entrega_notificacion_model.dart';
import '../widgets/notificacion_entrega_widget.dart';
import 'menu_operaciones_screen.dart';

class EntregaScreen extends StatefulWidget {
  const EntregaScreen({super.key});

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  List<EntregaNotificacion> notificaciones = [];
  List<Map<String, dynamic>> notificacionesBD = [];
  Timer? _timerRefresh;
  bool cargando = false;

  // ⚙️ CONFIGURAR ESTOS VALORES
  static const String BACKEND_URL =
      'https://api.vidriobras.com'; // Tu URL backend
  static const String USUARIO_ID = 'tu_usuario_id'; // ID del usuario logueado

  @override
  void initState() {
    super.initState();
    _inicializarNotificaciones();
    // Cargar notificaciones cada 10 segundos
    _timerRefresh = Timer.periodic(const Duration(seconds: 10), (_) {
      _cargarNotificacionesBD();
    });
  }

  Future<void> _inicializarNotificaciones() async {
    // Cargar notificaciones de la BD inmediatamente
    await _cargarNotificacionesBD();
  }

  /// Obtiene las notificaciones de la BD via API
  Future<void> _cargarNotificacionesBD() async {
    if (!mounted || cargando) return;

    try {
      setState(() => cargando = true);

      final url = Uri.parse(
        '$BACKEND_URL/api/flutter/notificaciones/obtener'
        '?usuario_id=$USUARIO_ID'
        '&limite=20'
        '&no_leidas=false',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Timeout conectando con backend'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<dynamic> notifs = data['data'] ?? [];

          if (mounted) {
            setState(() {
              notificacionesBD = List<Map<String, dynamic>>.from(
                notifs.map(
                  (n) => {
                    'id': n['id'],
                    'titulo': n['titulo'] ?? '',
                    'mensaje': n['mensaje'] ?? '',
                    'tipo': n['tipo'] ?? 'general',
                    'leida': n['leida'] ?? false,
                    'fecha': n['fecha'] ?? '',
                    'icono': n['icono'] ?? 'info',
                  },
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      print('❌ Error cargando notificaciones: $e');
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  /// Marca una notificación como leída
  Future<void> _marcarComoLeida(String notificacionId) async {
    try {
      final url = Uri.parse(
        '$BACKEND_URL/api/flutter/notificaciones/marcar-leida',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notificacion_id': notificacionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Recargar notificaciones
          await _cargarNotificacionesBD();
        }
      }
    } catch (e) {
      print('❌ Error marcando como leída: $e');
    }
  }

  /// Elimina notificación de la vista local
  void _eliminarNotificacion(String notificacionId) {
    setState(() {
      notificacionesBD.removeWhere((n) => n['id'] == notificacionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalNotificaciones = notificacionesBD.length + notificaciones.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF79BDDD),
        elevation: 0,
        title: const Text(
          'Entregas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.black54,
              builder: (_) => const MenuOperacionesScreen(),
            );
          },
        ),
        actions: [
          if (totalNotificaciones > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalNotificaciones',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          // Botón de refresh
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: cargando ? null : _cargarNotificacionesBD,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarNotificacionesBD,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ═══ NOTIFICACIONES DE LA BD ═══
              if (notificacionesBD.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Notificaciones de BD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${notificacionesBD.length}',
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...notificacionesBD.map((notif) {
                  bool noLeida = notif['leida'] != true;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: noLeida ? const Color(0xFFFEF2F2) : Colors.white,
                      border: Border.all(
                        color: noLeida
                            ? const Color(0xFFFECACA)
                            : Colors.grey.shade200,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado con estado
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notif['titulo'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: const Color(0xFF1F2937),
                                      decoration: notif['leida'] == true
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif['mensaje'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (noLeida)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Tipo y fecha
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _obtenerColorTipo(notif['tipo']),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notif['tipo'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notif['fecha'],
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  _eliminarNotificacion(notif['id']),
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Descartar'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (noLeida)
                              ElevatedButton.icon(
                                onPressed: () => _marcarComoLeida(notif['id']),
                                icon: const Icon(Icons.done, size: 16),
                                label: const Text('Marcar leída'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],

              // ═══ NOTIFICACIONES PUSHER (si existen) ═══
              if (notificaciones.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Notificaciones de Sistema',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...notificaciones
                    .map(
                      (notif) => NotificacionEntregaWidget(
                        notificacion: notif,
                        onRealizar: () {
                          setState(() => notificaciones.remove(notif));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Entrega confirmada'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        onEliminar: () {
                          setState(() => notificaciones.remove(notif));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notificación eliminada'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
                const SizedBox(height: 20),
              ],

              // ═══ PRODUCTOS A ENTREGAR ═══
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF79BDDD), Color(0xFF5AA9CC)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Lista de Productos a Entregar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _producto(
                producto: 'Ventana de Vidrio',
                cantidad: '4 unidades',
                cliente: 'Cliente: Constructora Lima',
                estado: 'En Ruta',
                hora: '08:30 AM',
                urgente: false,
              ),
              _producto(
                producto: 'Puerta de Aluminio',
                cantidad: '2 unidades',
                cliente: 'Cliente: Edificio Central',
                estado: 'Urgente',
                hora: '09:15 AM',
                urgente: true,
              ),
              _producto(
                producto: 'Mampara de Vidrio',
                cantidad: '1 unidad',
                cliente: 'Cliente: Residencial Sol',
                estado: 'Pendiente',
                hora: '10:00 AM',
                urgente: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el color según el tipo de notificación
  Color _obtenerColorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'pedido':
        return Colors.blue;
      case 'entrega':
        return Colors.green;
      case 'pago':
        return Colors.purple;
      case 'problema':
        return Colors.red;
      case 'promocion':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _producto({
    required String producto,
    required String cantidad,
    required String cliente,
    required String estado,
    required String hora,
    required bool urgente,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            producto,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 6),
          Text(cantidad, style: const TextStyle(color: Colors.grey)),
          Text(cliente, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: urgente
                      ? const Color(0xFF9D2612)
                      : const Color(0xFFE0F2F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: urgente ? Colors.white : const Color(0xFF0B8FB0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(hora, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timerRefresh?.cancel();
    super.dispose();
  }
}
