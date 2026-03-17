import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/notificacion_model.dart';
import 'package:flutter_application_1/services/notificacion_service.dart';
import 'package:flutter_application_1/services/pusher_config.dart';
import 'menu_operaciones_screen.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  // ── Colores ──────────────────────────────────────────────
  static const Color rojo       = Color(0xFF9D2612);
  static const Color grisFondo  = Color(0xFFF4F6F8);
  static const Color verdeNuevo = Color(0xFF1B8A4C);
  static const Color azulActual = Color(0xFF1565C0);

  // ── Pusher & notificaciones ──────────────────────────────
  final PusherConfig _pusherConfig        = PusherConfig();
  final NotificacionService _notifService = NotificacionService();

  List<NotificacionModel> _notificaciones = [];
  int _sinLeer = 0;

  // ── Datos originales ─────────────────────────────────────
  List<String> clientes = ["Carlos", "María", "José", "Andrea", "Luis", "Sofía"];
  String? clienteSeleccionado;
  String textoBusqueda = "";

  final Map<String, List<Map<String, String>>> tareasCliente = {
    "Carlos": [
      {
        "titulo": "Instalación de Ventanas",
        "detalle": "Ventana de vidrio · 4 unidades",
        "hora": "8:30 AM",
        "estado": "ENTREGA",
      },
    ],
  };

  // ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
    _escucharPusher();
  }

  @override
  void dispose() {
    _pusherConfig.disconnect();
    super.dispose();
  }

  // ── Pusher ───────────────────────────────────────────────

  void _escucharPusher() {
    _pusherConfig.initPusher(
      channelName: 'my-channel',
      eventName: 'my-event',
      onEventTriggered: (event) {
        if (!mounted) return;

        Map<String, dynamic> data = {};
        try {
          final raw = event.data;
          data = raw is String
              ? jsonDecode(raw) as Map<String, dynamic>
              : Map<String, dynamic>.from(raw as Map);
        } catch (_) {
          data = {'mensaje': event.data.toString()};
        }

        // Solo procesar eventos de notificaciones de servicios
        final tipo = data['tipo']?.toString() ?? '';
        if (!tipo.startsWith('notificacion_')) return;

        final evento = NotificacionPusherEvento.fromJson(data);
        _cargarNotificaciones();
        setState(() => _sinLeer++);
        _mostrarBanner(evento);
      },
    );
  }

  // ── Datos ────────────────────────────────────────────────

  Future<void> _cargarNotificaciones() async {
    final lista = await _notifService.obtenerNotificaciones(limit: 50);
    if (mounted) setState(() => _notificaciones = lista);
  }

  // ── Banner de notificación coloreado ─────────────────────

  void _mostrarBanner(NotificacionPusherEvento evento) {
    final esNuevo = evento.accion == AccionNotificacion.nuevoServicio;
    final color   = esNuevo ? verdeNuevo : azulActual;
    final icono   = esNuevo ? Icons.notifications_active : Icons.update;
    final label   = esNuevo ? 'NUEVO SERVICIO' : 'SERVICIO ACTUALIZADO';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabecera coloreada
            Container(
              width: double.infinity,
              color: color,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Row(
                children: [
                  Icon(icono, color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Cuerpo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (evento.cliente != null)
                    _InfoFila(label: 'Cliente',  value: evento.cliente!),
                  if (evento.nombre != null)
                    _InfoFila(label: 'Servicio', value: evento.nombre!),
                  if (evento.tipoServicio != null)
                    _InfoFila(label: 'Tipo',     value: evento.tipoServicio!),
                  if (evento.descripcion != null) ...[
                    const SizedBox(height: 6),
                    Text(evento.descripcion!,
                        style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                  if (evento.estado != null)
                    _InfoFila(label: 'Estado', value: evento.estado!),
                  const SizedBox(height: 6),
                  Text(evento.mensaje,
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 10),
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: color),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CERRAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Panel inferior con lista de notificaciones ────────────

  void _abrirPanelNotificaciones() {
    setState(() => _sinLeer = 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Cabecera del panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: rojo),
                    const SizedBox(width: 8),
                    const Text('Notificaciones de Servicios',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: rojo),
                      onPressed: _cargarNotificaciones,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Lista
              Expanded(
                child: _notificaciones.isEmpty
                    ? const Center(
                        child: Text('No hay notificaciones',
                            style: TextStyle(color: Colors.black45)))
                    : ListView.separated(
                        controller: ctrl,
                        itemCount: _notificaciones.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) =>
                            _TarjetaNotif(notif: _notificaciones[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BUILD PRINCIPAL ──────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final clientesFiltrados = clientes
        .where((c) => c.toLowerCase().contains(textoBusqueda.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: grisFondo,
      body: Stack(
        children: [
          // Fondo superior con imagen
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Image.asset("assets/images/celeste.png", fit: BoxFit.cover),
          ),

          // Logo + botones superiores
          SafeArea(
            child: Stack(
              children: [
                // Logo centrado
                Positioned(
                  top: 10, left: 0, right: 0,
                  child: Center(
                    child: Image.asset("assets/images/rojo.png", height: 160),
                  ),
                ),

                // Botón menú (izquierda)
                Positioned(
                  top: 18, left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    color: rojo,
                    iconSize: 30,
                    onPressed: () => showDialog(
                      context: context,
                      barrierColor: Colors.black54,
                      builder: (_) => const MenuOperacionesScreen(),
                    ),
                  ),
                ),

                // 🔔 Botón notificaciones con badge (derecha)
                Positioned(
                  top: 18, right: 10,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: rojo,
                        iconSize: 30,
                        onPressed: _abrirPanelNotificaciones,
                      ),
                      if (_sinLeer > 0)
                        Positioned(
                          right: 8, top: 8,
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$_sinLeer',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal (scroll)
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 200, 20, 20),
            children: [

              // Banner última notificación recibida
              if (_notificaciones.isNotEmpty)
                GestureDetector(
                  onTap: _abrirPanelNotificaciones,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: verdeNuevo.withOpacity(0.1),
                      border: Border.all(color: verdeNuevo.withOpacity(0.35)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active,
                            color: verdeNuevo, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _notificaciones.first.nombre ?? 'Nuevo servicio',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: verdeNuevo),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_notificaciones.first.descripcion != null)
                                Text(
                                  _notificaciones.first.descripcion!,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors.black38, size: 18),
                      ],
                    ),
                  ),
                ),

              // Selector de clientes (círculos)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: clientesFiltrados.map((cliente) {
                    final seleccionado = clienteSeleccionado == cliente;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => clienteSeleccionado = cliente),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            seleccionado ? rojo : Colors.blue.shade200,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Buscador
              TextField(
                onChanged: (v) => setState(() => textoBusqueda = v),
                decoration: InputDecoration(
                  hintText: "Buscar cliente...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Tarjetas de servicio o mensaje vacío
              if (clienteSeleccionado == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("Selecciona un cliente"),
                  ),
                )
              else
                Column(
                  children: (tareasCliente[clienteSeleccionado] ?? [])
                      .map((t) => _cardServicio(t))
                      .toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tarjeta de servicio (original) ───────────────────────

  Widget _cardServicio(Map<String, String> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: rojo,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Text(t["titulo"]!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(t["detalle"]!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: rojo,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t["estado"]!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                    Text(t["hora"]!),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => showDialog(
                      context: context,
                      barrierColor: Colors.black54,
                      builder: (_) => const MenuOperacionesScreen(),
                    ),
                    child: const Text("REALIZAR",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget auxiliar: fila label + valor
// ─────────────────────────────────────────────────────────────
class _InfoFila extends StatelessWidget {
  final String label;
  final String value;
  const _InfoFila({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black54)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget auxiliar: tarjeta dentro del panel de notificaciones
// ─────────────────────────────────────────────────────────────
class _TarjetaNotif extends StatelessWidget {
  final NotificacionModel notif;
  const _TarjetaNotif({required this.notif});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1B8A4C).withOpacity(0.12),
        child: const Icon(Icons.build_circle_outlined,
            color: Color(0xFF1B8A4C), size: 20),
      ),
      title: Text(notif.nombre ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: notif.descripcion != null
          ? Text(notif.descripcion!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54))
          : null,
      trailing: notif.tipo != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF9D2612).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(notif.tipo!.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9D2612))),
            )
          : null,
    );
  }
}