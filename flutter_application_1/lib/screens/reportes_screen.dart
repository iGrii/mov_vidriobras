import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/reportes_service.dart';
import 'package:flutter_application_1/models/reporte_model.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final ReportesService _reportesService = ReportesService();
  late Future<ResumenReportes> _statsResumen;
  late Future<ReportesResponse> _reportes;
  String _filtroTipo = ''; // '' = todos, 'CREAR', 'EDITAR', 'ELIMINAR'
  int _diasResumen = 30;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _cargando = true;
      _statsResumen = _reportesService.obtenerResumen(dias: _diasResumen);
      _reportes = _filtroTipo.isEmpty
          ? _reportesService.obtenerReportes()
          : _reportesService.obtenerReportes(tipo: _filtroTipo);
    });
    // Esperar un momento para hacer ambas llamadas
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _cargando = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarDatos(),
        child: Column(
          children: [
            // Estadísticas
            Padding(
              padding: const EdgeInsets.all(12),
              child: FutureBuilder<ResumenReportes>(
                future: _statsResumen,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snap.hasData) {
                    return const SizedBox(height: 80);
                  }
                  final data = snap.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _tarjeta('Creados', data.crear, Colors.green),
                      _tarjeta('Editados', data.editar, Colors.blue),
                      _tarjeta('Eliminados', data.eliminar, Colors.red),
                    ],
                  );
                },
              ),
            ),
            // Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _filtroTipo,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: '', child: Text('Todos')),
                        DropdownMenuItem(value: 'CREAR', child: Text('Creados')),
                        DropdownMenuItem(value: 'EDITAR', child: Text('Editados')),
                        DropdownMenuItem(
                          value: 'ELIMINAR',
                          child: Text('Eliminados'),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => _filtroTipo = v ?? '');
                        _cargarDatos();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: _diasResumen,
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7d')),
                      DropdownMenuItem(value: 30, child: Text('30d')),
                      DropdownMenuItem(value: 90, child: Text('90d')),
                    ],
                    onChanged: (v) {
                      setState(() => _diasResumen = v ?? 30);
                      _cargarDatos();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Lista de reportes
            Expanded(
              child: FutureBuilder<ReportesResponse>(
                future: _reportes,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          const Text('Error al cargar reportes'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _cargarDatos,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snap.hasData || snap.data!.reportes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin reportes aún',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los cambios en productos aparecerán aquí',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _cargarDatos,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Recargar'),
                          ),
                        ],
                      ),
                    );
                  }
                  final lista = snap.data!.reportes;
                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (ctx, i) {
                      final r = lista[i];
                      final tieneNombre = r.productoNombre.isNotEmpty && r.productoNombre != 'Sin nombre';
                      return GestureDetector(
                        onTap: () => _mostrarDetalle(ctx, r),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getColorTipo(r.tipo),
                              ),
                              child: Icon(
                                _getIconTipo(r.tipo),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tieneNombre ? r.productoNombre : 'Producto sin nombre',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  _getTituloTipo(r.tipo),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getColorTipo(r.tipo),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatearFecha(r.fechaCambio),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (r.detalles != null && r.detalles!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: ${r.productoId.length > 12 ? r.productoId.substring(0, 12) + '...' : r.productoId}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(String titulo, int num, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'CREAR':
        return Colors.green;
      case 'EDITAR':
        return Colors.blue;
      case 'ELIMINAR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconTipo(String tipo) {
    switch (tipo) {
      case 'CREAR':
        return Icons.add;
      case 'EDITAR':
        return Icons.edit;
      case 'ELIMINAR':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  String _getTituloTipo(String tipo) {
    switch (tipo) {
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarDetalle(BuildContext context, ReporteProducto reporte) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColorTipo(reporte.tipo),
              ),
              child: Icon(
                _getIconTipo(reporte.tipo),
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getTituloTipo(reporte.tipo),
                style: TextStyle(color: _getColorTipo(reporte.tipo)),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detalleField('Producto', reporte.productoNombre.isEmpty ? 'Sin nombre' : reporte.productoNombre),
              const SizedBox(height: 12),
              _detalleField('ID Producto', reporte.productoId),
              const SizedBox(height: 12),
              _detalleField('Tipo', reporte.tipo),
              const SizedBox(height: 12),
              _detalleField('Fecha', _formatearFecha(reporte.fechaCambio)),
              if (reporte.detalles != null && reporte.detalles!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _detalleField('Detalles', reporte.detalles!),
              ],
              if (reporte.usuario != null && reporte.usuario!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _detalleField('Usuario', reporte.usuario!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _detalleField(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    ],
  );
}
