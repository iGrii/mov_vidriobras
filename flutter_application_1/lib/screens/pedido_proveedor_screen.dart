import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/pedido_proveedor_model.dart';
import '../services/pedido_proveedor_service.dart';

class PedidoProveedorScreen extends StatefulWidget {
  const PedidoProveedorScreen({super.key});

  @override
  State<PedidoProveedorScreen> createState() => _PedidoProveedorScreenState();
}

class _PedidoProveedorScreenState extends State<PedidoProveedorScreen> {
  final PedidoProveedorService _service = PedidoProveedorService();
  final Map<String, TextEditingController> _cantidadControllers = {};
  final Set<String> _excluidos = <String>{};
  final TextEditingController _buscadorController = TextEditingController();

  bool _cargando = true;
  bool _exportandoPdf = false;
  bool _buscandoExtras = false;
  String? _error;
  String? _errorBusqueda;
  List<PedidoProveedorProducto> _productosBajoStock = [];
  List<PedidoProveedorProducto> _productosExtras = [];
  List<PedidoProveedorProducto> _resultadosBusqueda = [];

  List<PedidoProveedorProducto> get _productosVisibles => [
    ..._productosBajoStock,
    ..._productosExtras,
  ].where((p) => !_excluidos.contains(p.id)).toList();

  int get _totalBase =>
      _productosBajoStock.where((p) => !_excluidos.contains(p.id)).length;

  int get _totalExtras =>
      _productosExtras.where((p) => !_excluidos.contains(p.id)).length;

  int get _totalPedido {
    int total = 0;
    for (final producto in _productosVisibles) {
      total += _pedidoCantidad(producto.id);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    for (final controller in _cantidadControllers.values) {
      controller.dispose();
    }
    _buscadorController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });

    final response = await _service.obtenerProductosBajoStock();
    if (!mounted) return;

    if (!response.success) {
      setState(() {
        _error = response.message.isNotEmpty
            ? response.message
            : 'No se pudo cargar el pedido proveedor';
        _cargando = false;
      });
      return;
    }

    _sincronizarControllers(response.productos);
    setState(() {
      _productosBajoStock = response.productos
          .where((p) => p.stockBajo)
          .toList();
      _cargando = false;
    });
  }

  void _sincronizarControllers(List<PedidoProveedorProducto> productos) {
    for (final producto in productos) {
      _cantidadControllers.putIfAbsent(
        producto.id,
        () => TextEditingController(text: producto.cantidadSugerida.toString()),
      );
    }
  }

  Future<void> _buscarExtras(String value) async {
    final query = value.trim();
    if (query.length < 2) {
      if (!mounted) return;
      setState(() {
        _resultadosBusqueda = [];
        _errorBusqueda = null;
        _buscandoExtras = false;
      });
      return;
    }

    setState(() {
      _buscandoExtras = true;
      _errorBusqueda = null;
    });

    final response = await _service.buscarProductosParaAgregar(query);
    if (!mounted) return;

    if (!response.success) {
      setState(() {
        _resultadosBusqueda = [];
        _errorBusqueda = response.message.isNotEmpty
            ? response.message
            : 'No se pudo buscar productos';
        _buscandoExtras = false;
      });
      return;
    }

    final idsActuales = _productosVisibles
        .map((producto) => producto.id)
        .toSet();
    setState(() {
      _resultadosBusqueda = response.productos
          .where((producto) => !idsActuales.contains(producto.id))
          .toList();
      _buscandoExtras = false;
    });
  }

  void _agregarProductoExtra(PedidoProveedorProducto producto) {
    if (_productosVisibles.any((item) => item.id == producto.id)) {
      return;
    }

    _sincronizarControllers([producto.copyWith(agregadoManual: true)]);
    setState(() {
      _excluidos.remove(producto.id);
      _productosExtras = [
        ..._productosExtras,
        producto.copyWith(agregadoManual: true),
      ];
      _resultadosBusqueda = [];
      _errorBusqueda = null;
      _buscadorController.clear();
    });
  }

  void _quitarProducto(PedidoProveedorProducto producto) {
    setState(() {
      if (producto.agregadoManual) {
        _productosExtras = _productosExtras
            .where((item) => item.id != producto.id)
            .toList();
        _cantidadControllers.remove(producto.id)?.dispose();
      } else {
        _excluidos.add(producto.id);
      }
    });
  }

  int _pedidoCantidad(String productoId) {
    final raw = _cantidadControllers[productoId]?.text.trim() ?? '';
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _generarPdf() async {
    final productos = _productosVisibles
        .where((producto) => _pedidoCantidad(producto.id) > 0)
        .toList();

    if (productos.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa cantidades antes de generar el pedido'),
        ),
      );
      return;
    }

    setState(() => _exportandoPdf = true);
    try {
      final now = DateTime.now();
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(24),
          build: (_) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#9D2612'),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'VIDRIOBRAS',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Pedido al proveedor',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Fecha: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            ),
            pw.SizedBox(height: 6),
            pw.Text('Productos incluidos: ${productos.length}'),
            pw.Text(
              'Total de unidades a pedir: ${productos.fold<int>(0, (sum, p) => sum + _pedidoCantidad(p.id))}',
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#9D2612'),
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              headers: const ['Codigo', 'Producto', 'Cantidad'],
              data: productos
                  .map(
                    (producto) => [
                      producto.codigo ?? '-',
                      producto.nombre,
                      _pedidoCantidad(producto.id).toString(),
                    ],
                  )
                  .toList(),
            ),
          ],
        ),
      );

      final bytes = await doc.save();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar el PDF del pedido')),
      );
    } finally {
      if (mounted) {
        setState(() => _exportandoPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9D2612),
        title: const Text('Pedido', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _exportandoPdf ? null : _generarPdf,
            icon: _exportandoPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Generar PDF del pedido',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarProductos,
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 140),
                  const Icon(Icons.error_outline, color: Colors.red, size: 42),
                  const SizedBox(height: 12),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(_error!, textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: _cargarProductos,
                      child: const Text('Reintentar'),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _PedidoResumenCard(
                    totalProductos: _totalBase,
                    totalExtras: _totalExtras,
                    totalUnidades: _totalPedido,
                  ),
                  const SizedBox(height: 16),
                  _BuscadorAgregarProducto(
                    controller: _buscadorController,
                    buscando: _buscandoExtras,
                    error: _errorBusqueda,
                    resultados: _resultadosBusqueda,
                    onChanged: _buscarExtras,
                    onAgregar: _agregarProductoExtra,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Productos para proveedor',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (_productosVisibles.isEmpty)
                    const Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF1B8A4C),
                        ),
                        title: Text('No hay productos con stock bajo'),
                        subtitle: Text(
                          'Todos los productos están por encima de 10 unidades.',
                        ),
                      ),
                    ),
                  ..._productosVisibles.map(
                    (producto) => _PedidoProductoCard(
                      producto: producto,
                      controller: _cantidadControllers[producto.id]!,
                      onChanged: (_) => setState(() {}),
                      onEliminar: () => _quitarProducto(producto),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PedidoResumenCard extends StatelessWidget {
  const _PedidoResumenCard({
    required this.totalProductos,
    required this.totalExtras,
    required this.totalUnidades,
  });

  final int totalProductos;
  final int totalExtras;
  final int totalUnidades;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 14),
          _ResumenFila(
            label: 'Productos con stock bajo',
            value: totalProductos.toString(),
          ),
          const SizedBox(height: 8),
          _ResumenFila(
            label: 'Productos agregados manualmente',
            value: totalExtras.toString(),
          ),
          const SizedBox(height: 8),
          _ResumenFila(
            label: 'Unidades a pedir',
            value: totalUnidades.toString(),
          ),
          const SizedBox(height: 8),
          const _ResumenFila(label: 'Umbral de alerta', value: '<= 10'),
        ],
      ),
    );
  }
}

class _ResumenFila extends StatelessWidget {
  const _ResumenFila({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF5F6368), fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}

class _PedidoProductoCard extends StatelessWidget {
  const _PedidoProductoCard({
    required this.producto,
    required this.controller,
    required this.onChanged,
    required this.onEliminar,
  });

  final PedidoProveedorProducto producto;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final colorStock = producto.cantidadActual == 0
        ? const Color(0xFFC62828)
        : const Color(0xFFE65100);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorStock.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Stock: ${producto.cantidadActual}',
                        style: TextStyle(
                          color: colorStock,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((producto.codigo ?? '').isNotEmpty)
                      _DatoPill(label: 'Código ${producto.codigo}'),
                    if ((producto.grosor ?? '').isNotEmpty)
                      _DatoPill(label: 'Grosor ${producto.grosor}'),
                    if (producto.agregadoManual)
                      const _DatoPill(label: 'Agregado manualmente'),
                    _DatoPill(label: 'Sugerido ${producto.cantidadSugerida}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final limpio = value.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (limpio != value) {
                            controller.value = TextEditingValue(
                              text: limpio,
                              selection: TextSelection.collapsed(
                                offset: limpio.length,
                              ),
                            );
                          }
                          onChanged(limpio);
                        },
                        decoration: InputDecoration(
                          labelText: 'Cantidad a pedir',
                          hintText: math
                              .max(1, producto.cantidadSugerida)
                              .toString(),
                          filled: true,
                          fillColor: const Color(0xFFF7F9FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDE3EC),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDE3EC),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF9D2612),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: onEliminar,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        foregroundColor: const Color(0xFFC62828),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Quitar del pedido',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuscadorAgregarProducto extends StatelessWidget {
  const _BuscadorAgregarProducto({
    required this.controller,
    required this.buscando,
    required this.error,
    required this.resultados,
    required this.onChanged,
    required this.onAgregar,
  });

  final TextEditingController controller;
  final bool buscando;
  final String? error;
  final List<PedidoProveedorProducto> resultados;
  final ValueChanged<String> onChanged;
  final ValueChanged<PedidoProveedorProducto> onAgregar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agregar otros productos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Busca productos con stock mayor a 10 para sumarlos manualmente al pedido.',
            style: TextStyle(color: Color(0xFF5F6368), fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o código',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: buscando
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF9D2612),
                  width: 1.4,
                ),
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          if (!buscando && resultados.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...resultados.map(
              (producto) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE3EAF2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Código: ${producto.codigo ?? '-'} | Stock: ${producto.cantidadActual}',
                            style: const TextStyle(
                              color: Color(0xFF5F6368),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => onAgregar(producto),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9D2612),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DatoPill extends StatelessWidget {
  const _DatoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4F6B7A),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
