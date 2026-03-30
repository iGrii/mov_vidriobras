import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/pusher_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/models/almacen_model.dart';
import 'package:flutter_application_1/services/almacen_service.dart';
import 'package:flutter_application_1/screens/agregar_producto_page.dart';
import 'package:flutter_application_1/screens/pedido_proveedor_screen.dart';
import 'package:flutter_application_1/screens/producto_detalle_page.dart';
import 'package:flutter_application_1/screens/reportes_screen.dart';
import 'package:flutter_application_1/services/categoria_service.dart';

// ─────────────────────────────────────────────────────────────
// Modelo interno para parsear el evento Pusher de forma clara
// ─────────────────────────────────────────────────────────────
class _PusherEvento {
  final String
  tipo; // 'producto_creado' | 'producto_actualizado' | 'producto_eliminado' | 'stock_bajo'
  final String mensaje;
  final String? nombre;
  final String? codigo;
  final String? id;
  final int? cantidad;

  const _PusherEvento({
    required this.tipo,
    required this.mensaje,
    this.nombre,
    this.codigo,
    this.id,
    this.cantidad,
  });

  static Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return {'mensaje': raw};
      }
    }

    return <String, dynamic>{};
  }

  static String _normalizarTipo({
    required String tipo,
    required String mensaje,
    required String eventName,
  }) {
    final joined =
        '${tipo.toLowerCase()} ${mensaje.toLowerCase()} ${eventName.toLowerCase()}';

    if (joined.contains('stock_bajo') ||
        joined.contains('stock bajo') ||
        joined.contains('bajo')) {
      return 'stock_bajo';
    }
    if (joined.contains('elimin') ||
        joined.contains('delete') ||
        joined.contains('removed')) {
      return 'producto_eliminado';
    }
    if (joined.contains('actualiz') ||
        joined.contains('edit') ||
        joined.contains('update') ||
        joined.contains('stock_actualizado')) {
      return 'producto_actualizado';
    }
    if (joined.contains('cread') ||
        joined.contains('agreg') ||
        joined.contains('create') ||
        joined.contains('added')) {
      return 'producto_creado';
    }

    return tipo;
  }

  factory _PusherEvento.fromRaw(dynamic raw, {String eventName = ''}) {
    Map<String, dynamic> data = _toMap(raw);

    // Algunos backends envían el payload dentro de data/payload
    if (data['data'] is Map || data['data'] is String) {
      final nested = _toMap(data['data']);
      if (nested.isNotEmpty) {
        data = nested;
      }
    } else if (data['payload'] is Map || data['payload'] is String) {
      final nested = _toMap(data['payload']);
      if (nested.isNotEmpty) {
        data = nested;
      }
    }

    final tipoRaw =
        data['tipo']?.toString() ??
        data['accion']?.toString() ??
        data['event']?.toString() ??
        data['type']?.toString() ??
        '';

    final mensaje =
        data['mensaje']?.toString() ??
        data['message']?.toString() ??
        'Nueva notificación';

    final nombre =
        data['nombre']?.toString() ??
        data['producto_nombre']?.toString() ??
        data['producto']?.toString();

    final codigo =
        data['codigo']?.toString() ?? data['producto_codigo']?.toString();

    final id =
        data['id']?.toString() ??
        data['producto_id']?.toString() ??
        data['id_producto']?.toString();

    final tipo = _normalizarTipo(
      tipo: tipoRaw,
      mensaje: mensaje,
      eventName: eventName,
    );

    // Parsear cantidad si viene en el payload
    int? cantidad;
    final cantidadRaw = data['cantidad'];
    if (cantidadRaw != null) {
      try {
        cantidad = int.parse(cantidadRaw.toString());
      } catch (_) {}
    }

    return _PusherEvento(
      tipo: tipo,
      mensaje: mensaje,
      nombre: nombre,
      codigo: codigo,
      id: id,
      cantidad: cantidad,
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
      case 'stock_bajo':
        return const Color(0xFFE65100); // naranja oscuro
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
      case 'stock_bajo':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  String get etiqueta {
    switch (tipo) {
      case 'producto_creado':
        return '¡SE AGREGO UN NUEVO PRODUCTO!';
      case 'producto_actualizado':
        return 'STOCK ACTUALIZADO';
      case 'producto_eliminado':
        return 'PRODUCTO ELIMINADO';
      case 'stock_bajo':
        return '⚠️ STOCK BAJO – ¡REABASTECER!';
      default:
        return 'NOTIFICACIÓN';
    }
  }
}

// ─────────────────────────────────────────────────────────────
class _NotificacionBanner extends StatelessWidget {
  final _PusherEvento evento;
  final VoidCallback onCerrar;
  final VoidCallback? onVerDetalles;

  const _NotificacionBanner({
    required this.evento,
    required this.onCerrar,
    this.onVerDetalles,
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
                // Cantidad destacada únicamente para stock_bajo
                if (evento.tipo == 'stock_bajo' && evento.cantidad != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE65100),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${evento.cantidad}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const Text(
                          'unidades restantes',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFBF360C),
                          ),
                        ),
                      ],
                    ),
                  ),
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
          // Botones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onVerDetalles != null) ...[
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: evento.color),
                    onPressed: onVerDetalles,
                    child: const Text(
                      'VER DETALLES',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: evento.color),
                  onPressed: onCerrar,
                  child: const Text(
                    'CERRAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
// Dialog agrupado para múltiples actualizaciones de stock
// ─────────────────────────────────────────────────────────────
class _NotificacionListaBanner extends StatelessWidget {
  final List<_PusherEvento> eventos;
  final VoidCallback onCerrar;

  const _NotificacionListaBanner({
    required this.eventos,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF1565C0);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera
          Container(
            width: double.infinity,
            color: color,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    eventos.length == 1
                        ? 'STOCK ACTUALIZADO'
                        : 'STOCK ACTUALIZADO (${eventos.length} productos)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de productos actualizados
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: eventos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = eventos[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (e.nombre != null)
                              Text(
                                e.nombre!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            if (e.codigo != null)
                              Text(
                                'Código: ${e.codigo}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            Text(
                              e.mensaje,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (e.cantidad != null)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: e.cantidad! <= 5
                                ? const Color(0xFFC62828)
                                : color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${e.cantidad}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Botón cerrar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: color),
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

  // Buffer para agrupar notificaciones de stock actualizado en un solo dialog
  final List<_PusherEvento> _bufferActualizados = [];
  Timer? _timerDebounce;

  // Controlador para el buscador
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtro de categoría seleccionada
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _escucharPusher();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
      _cargarProductos();
    });
  }

  @override
  void dispose() {
    _timerDebounce?.cancel();
    _pusherConfig.disconnect();
    _searchController.dispose();
    super.dispose();
  }

  // ── Pusher ───────────────────────────────────────────────

  Future<void> _escucharPusher() async {
    await _pusherConfig.initPusher(
      channelName: 'productos-channel',
      eventName: "*",
      onEventTriggered: (event) {
        if (!mounted) return;

        debugPrint(
          '[ProductosPage] evento ${event.channelName}/${event.eventName} data=${event.data}',
        );

        final evento = _PusherEvento.fromRaw(
          event.data,
          eventName: event.eventName,
        );

        // Solo reaccionar a eventos de productos / stock
        final nombreEvento = event.eventName.toLowerCase();
        final nombreCanal = event.channelName.toLowerCase();
        final tipoEvento = evento.tipo.toLowerCase();
        final mensajeEvento = evento.mensaje.toLowerCase();
        final esProducto =
            nombreCanal.contains('producto') ||
            nombreEvento.contains('producto') ||
            nombreEvento.contains('stock') ||
            tipoEvento.contains('producto') ||
            tipoEvento.contains('stock') ||
            mensajeEvento.contains('producto') ||
            mensajeEvento.contains('stock') ||
            evento.nombre != null ||
            evento.codigo != null ||
            tipoEvento == 'crear' ||
            tipoEvento == 'editar' ||
            tipoEvento == 'eliminar';
        if (!esProducto) return;

        setState(() => _ultimoEvento = evento);
        _cargarProductos(); // refresca lista con nueva cantidad
        _mostrarNotificacion(evento);
      },
    );
  }

  void _mostrarNotificacion(_PusherEvento evento) {
    // Los eventos de stock_bajo se muestran individualmente (uno por producto).
    // Los eventos de stock actualizado se agrupan en un único dialog para no saturar.
    if (evento.tipo == 'producto_actualizado') {
      _bufferActualizados.add(evento);
      _timerDebounce?.cancel();
      _timerDebounce = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted || _bufferActualizados.isEmpty) return;
        final lote = List<_PusherEvento>.from(_bufferActualizados);
        _bufferActualizados.clear();
        showDialog(
          context: context,
          builder: (_) => _NotificacionListaBanner(
            eventos: lote,
            onCerrar: () => Navigator.of(context).pop(),
          ),
        );
      });
      return;
    }

    // Para producto_creado / producto_eliminado / stock_bajo: dialog individual.
    VoidCallback? onVerDetalles;
    if (evento.id != null &&
        (evento.tipo == 'producto_creado' ||
            evento.tipo == 'producto_eliminado' ||
            evento.tipo == 'stock_bajo')) {
      onVerDetalles = () async {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        try {
          final response = await _almacenService.obtenerProductoporId(
            evento.id!,
          );
          Navigator.of(context).pop();
          if (response.success && response.data != null) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductoDetallePage(
                  producto: response.data!,
                  categoriaNombre: _categoriaMap[response.data!.categoriaId],
                ),
              ),
            );
            _cargarProductos();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cargar detalles: ${response.message}'),
              ),
            );
          }
        } catch (e) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
        }
      };
    }

    showDialog(
      context: context,
      builder: (_) => _NotificacionBanner(
        evento: evento,
        onCerrar: () => Navigator.of(context).pop(),
        onVerDetalles: onVerDetalles,
      ),
    );
  }

  // ── Datos ────────────────────────────────────────────────

  void _cargarProductos() {
    setState(() {
      if (_searchQuery.trim().length >= 2) {
        _futureProductos = _almacenService.buscarProductos(_searchQuery);
      } else {
        _futureProductos = _almacenService.obtenerProductos();
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VIDRIOBRAS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: rojo,
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
              icon: Icons.local_shipping_outlined,
              label: 'Pedido',
              active: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
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
          return Column(
            children: [
              // ── Buscador ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                child: TextField(
                  controller: state._searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // ── Filtro por categoría ───────────────────────────────
              if (state._categoriaMap.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      _CategoriaChip(
                        label: 'Todas',
                        selected: state._categoriaSeleccionada == null,
                        onTap: () => state.setState(
                          () => state._categoriaSeleccionada = null,
                        ),
                      ),
                      ...state._categoriaMap.entries.map(
                        (e) => _CategoriaChip(
                          label: e.value,
                          selected: state._categoriaSeleccionada == e.key,
                          onTap: () => state.setState(
                            () => state._categoriaSeleccionada = e.key,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // ── Grid de productos ──────────────────────────────────
              Expanded(
                child: FutureBuilder<ProductoListResponse>(
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
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
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

                    if (state._categoriaMap.isEmpty) state._cargarCategorias();

                    final todos = snapshot.data?.productos ?? [];
                    final productos = state._categoriaSeleccionada == null
                        ? todos
                        : todos
                              .where(
                                (p) =>
                                    p.categoriaId ==
                                    state._categoriaSeleccionada,
                              )
                              .toList();

                    if (productos.isEmpty) {
                      return const Center(
                        child: Text('No hay productos disponibles'),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        final tieneImagen =
                            producto.imagen != null &&
                            producto.imagen!.startsWith('http');
                        final stockBajo =
                            producto.cantidad != null &&
                            producto.cantidad! <= 10;
                        final agotado =
                            producto.cantidad != null &&
                            producto.cantidad! == 0;

                        return GestureDetector(
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
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                // ── Imagen de fondo ──────────────────
                                Positioned.fill(
                                  child: tieneImagen
                                      ? Image.network(
                                          producto.imagen!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: const Color(0xFFF0F0F0),
                                                child: const Icon(
                                                  Icons.inventory_2,
                                                  size: 48,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: const Color(0xFFF0F0F0),
                                          child: const Icon(
                                            Icons.inventory_2,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                // ── Gradiente inferior para legibilidad ─
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Color(0xDD000000),
                                          Colors.transparent,
                                        ],
                                        stops: [0.0, 1.0],
                                      ),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      24,
                                      8,
                                      8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto.nombre,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 4,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          producto.precio != null
                                              ? 'S/ ${producto.precio!.toStringAsFixed(2)}'
                                              : 'N/A',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // ── Badge stock bajo / agotado ──────────
                                if (stockBajo)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: agotado
                                            ? const Color(0xFFC62828)
                                            : const Color(0xFFE65100),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        agotado
                                            ? 'AGOTADO'
                                            : '⚠ ${producto.cantidad}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );

        case 1:
          return AgregarProductoUI(onProductoAgregado: state._cargarProductos);

        case 2:
          return const ReportesScreen();

        case 3:
          return const PedidoProveedorScreen();

        default:
          return const SizedBox.shrink();
      }
    },
  );
}

// ─────────────────────────────────────────────────────────────
// Chip de filtro por categoría
// ─────────────────────────────────────────────────────────────
class _CategoriaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoriaChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const rojo = Color(0xFF9D2612);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? rojo : Colors.white,
          border: Border.all(color: selected ? rojo : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [const BoxShadow(color: Colors.black26, blurRadius: 4)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
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
