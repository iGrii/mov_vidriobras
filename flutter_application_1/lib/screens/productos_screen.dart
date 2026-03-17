import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/pusher_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/models/almacen_model.dart';
import 'package:flutter_application_1/services/almacen_service.dart';
import 'package:flutter_application_1/screens/agregar_producto_page.dart';
import 'package:flutter_application_1/screens/producto_detalle_page.dart';
import 'package:flutter_application_1/screens/reportes_screen.dart';
import 'package:flutter_application_1/services/categoria_service.dart';

// ─────────────────────────────────────────────────────────────
// Modelo interno para parsear el evento Pusher de forma clara
// ─────────────────────────────────────────────────────────────
class _PusherEvento {
  final String tipo;   // 'producto_creado' | 'producto_actualizado' | 'producto_eliminado'
  final String mensaje;
  final String? nombre;
  final String? codigo;

  const _PusherEvento({
    required this.tipo,
    required this.mensaje,
    this.nombre,
    this.codigo,
  });

  factory _PusherEvento.fromRaw(dynamic raw) {
    Map<String, dynamic> data = {};

    if (raw is String) {
      try {
        data = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        data = {'mensaje': raw};
      }
    } else if (raw is Map) {
      data = Map<String, dynamic>.from(raw);
    }

    return _PusherEvento(
      tipo: data['tipo']?.toString() ?? '',
      mensaje: data['mensaje']?.toString() ?? 'Nueva notificación',
      nombre: data['nombre']?.toString(),
      codigo: data['codigo']?.toString(),
    );
  }

  // ── Metadatos visuales según el tipo ──────────────────────

  Color get color {
    switch (tipo) {
      case 'producto_creado':
        return const Color(0xFF1B8A4C); // verde
      case 'producto_actualizado':
        return const Color(0xFF1565C0); // azul
      case 'producto_eliminado':
        return const Color(0xFFC62828); // rojo
      default:
        return const Color(0xFF424242); // gris oscuro
    }
  }

  IconData get icono {
    switch (tipo) {
      case 'producto_creado':
        return Icons.add_circle_outline;
      case 'producto_actualizado':
        return Icons.edit_outlined;
      case 'producto_eliminado':
        return Icons.delete_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String get etiqueta {
    switch (tipo) {
      case 'producto_creado':
        return '¡SE AGREGO UN NUEVO PRODUCTO!';
      case 'producto_actualizado':
        return 'PRODUCTO EDITADO';
      case 'producto_eliminado':
        return 'PRODUCTO ELIMINADO';
      default:
        return 'NOTIFICACIÓN';
    }
  }
}

// ─────────────────────────────────────────────────────────────
class _NotificacionBanner extends StatelessWidget {
  final _PusherEvento evento;
  final VoidCallback onCerrar;

  const _NotificacionBanner({
    required this.evento,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera coloreada
          Container(
            width: double.infinity,
            color: evento.color,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Icon(evento.icono, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    evento.etiqueta,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cuerpo
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (evento.nombre != null) ...[
                  _InfoRow(label: 'Producto', value: evento.nombre!),
                  const SizedBox(height: 8),
                ],
                if (evento.codigo != null) ...[
                  _InfoRow(label: 'Código', value: evento.codigo!),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 4),
                Text(
                  evento.mensaje,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          // Botón cerrar
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: evento.color),
                onPressed: onCerrar,
                child: const Text(
                  'CERRAR',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Página principal
// ─────────────────────────────────────────────────────────────
class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final PusherConfig _pusherConfig = PusherConfig();
  static const Color rojo = Color(0xFF9D2612);

  final AlmacenService _almacenService = AlmacenService();
  final CategoriaService _categoriaService = CategoriaService();
  late Future<ProductoListResponse> _futureProductos;
  Map<String, String> _categoriaMap = {};
  int _currentIndex = 0;

  // Último evento Pusher recibido (para el título del AppBar)
  _PusherEvento? _ultimoEvento;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
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
      channelName: "my-channel",
      eventName: "my-event",
      onEventTriggered: (event) {
        if (!mounted) return;

        final evento = _PusherEvento.fromRaw(event.data);

        setState(() => _ultimoEvento = evento);
        _cargarProductos();
        _mostrarNotificacion(evento);
      },
    );
  }

  void _mostrarNotificacion(_PusherEvento evento) {
    showDialog(
      context: context,
      builder: (_) => _NotificacionBanner(
        evento: evento,
        onCerrar: () => Navigator.of(context).pop(),
      ),
    );
  }

  // ── Datos ────────────────────────────────────────────────

  void _cargarProductos() {
    setState(() {
      _futureProductos = _almacenService.obtenerProductos();
    });
  }

  Future<void> _cargarCategorias() async {
    final cats = await _categoriaService.obtenerCategorias();
    setState(() {
      _categoriaMap = {for (var c in cats) c.id: c.descripcion};
    });
  }

  // ── UI ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Título del AppBar cambia según el último evento recibido
    String titulo = 'Productos';
    Color appBarColor = rojo;

    if (_ultimoEvento != null) {
      titulo = _ultimoEvento!.etiqueta;
      appBarColor = _ultimoEvento!.color;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_ultimoEvento != null) ...[
              Icon(_ultimoEvento!.icono, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                titulo,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: appBarColor,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomAction(
              icon: Icons.inventory_2,
              label: 'Inventario',
              active: _currentIndex == 0,
              onTap: () {
                setState(() => _currentIndex = 0);
                _cargarProductos();
              },
            ),
            _BottomAction(
              icon: Icons.add,
              label: 'Agregar',
              active: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _BottomAction(
              icon: Icons.bar_chart,
              label: 'Reportes',
              active: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _BottomAction(
              icon: Icons.logout,
              label: 'Salir',
              onTap: () => context.go('/'),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body según pestaña activa
// ─────────────────────────────────────────────────────────────
Widget _buildBody() {
  return Builder(
    builder: (context) {
      final state = context.findAncestorStateOfType<_ProductosPageState>();
      if (state == null) return const SizedBox.shrink();

      switch (state._currentIndex) {
        case 0:
          return FutureBuilder<ProductoListResponse>(
            future: state._futureProductos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: state._cargarProductos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final productos = snapshot.data?.productos ?? [];

              if (state._categoriaMap.isEmpty) state._cargarCategorias();

              if (productos.isEmpty) {
                return const Center(
                    child: Text('No hay productos disponibles'));
              }

              return ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: (producto.imagen != null &&
                              producto.imagen!.startsWith('http'))
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                producto.imagen!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.inventory_2),
                              ),
                            )
                          : const Icon(Icons.inventory_2),
                      title: Text(
                        producto.nombre,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (producto.descripcion != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              producto.descripcion ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                          if (producto.categoriaId != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Categoría: ${state._categoriaMap[producto.categoriaId] ?? producto.categoriaId}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                      trailing: Text(
                        producto.precio != null
                            ? 'S/ ${producto.precio!.toStringAsFixed(2)}'
                            : 'N/A',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onTap: () async {
                        final refreshed = await Navigator.of(context)
                            .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => ProductoDetallePage(
                              producto: producto,
                              categoriaNombre: state
                                  ._categoriaMap[producto.categoriaId],
                            ),
                          ),
                        );
                        if (refreshed == true) state._cargarProductos();
                      },
                    ),
                  );
                },
              );
            },
          );

        case 1:
          return AgregarProductoUI(
              onProductoAgregado: state._cargarProductos);

        case 2:
          return const ReportesScreen();

        default:
          return const SizedBox.shrink();
      }
    },
  );
}

// ─────────────────────────────────────────────────────────────
// Botón de la barra inferior
// ─────────────────────────────────────────────────────────────
class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _ProductosPageState.rojo : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}