import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/almacen_model.dart';
import 'package:flutter_application_1/screens/agregar_producto_page.dart';
import 'package:flutter_application_1/services/producto_action_service.dart';

class ProductoDetallePage extends StatefulWidget {
  final Producto producto;
  final String? categoriaNombre;

  const ProductoDetallePage({
    super.key,
    required this.producto,
    this.categoriaNombre,
  });

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  final ProductoActionService _actionService = ProductoActionService();
  bool _deleting = false;

  Future<void> _confirmEliminar() async {
    setState(() => _deleting = true);
    final deleted = await _actionService.confirmarYEliminarProducto(
      context,
      widget.producto,
    );
    if (!mounted) return;
    setState(() => _deleting = false);
    if (deleted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _editar() async {
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AgregarProductoUI(
          onProductoAgregado: () {},
          producto: widget.producto,
        ),
      ),
    );

    if (!mounted) return;
    if (refreshed == true) {
      Navigator.of(context).pop(true);
    }
  }

  String _safeText(dynamic value, {String fallback = 'No especificado'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  String _money(double value) => 'S/ ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    final imageUrl = p.imagen?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        actions: [
          IconButton(
            onPressed: _deleting ? null : _editar,
            tooltip: 'Editar producto',
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: _deleting ? null : _confirmEliminar,
            tooltip: 'Eliminar producto',
            icon: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: SizedBox(
                      height: 240,
                      child: hasImage
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                            )
                          : _imageFallback(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _safeText(p.nombre, fallback: 'Producto sin nombre'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _chipDato(
                              icon: Icons.qr_code_2,
                              texto: _safeText(p.codigo),
                            ),
                            _chipDato(
                              icon: Icons.category_outlined,
                              texto: _safeText(widget.categoriaNombre),
                            ),
                            _chipDato(
                              icon: Icons.straighten,
                              texto: _safeText(p.grosor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _resumenDato(
                                titulo: 'Precio',
                                valor: p.precio != null
                                    ? _money(p.precio!)
                                    : 'No especificado',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _resumenDato(
                                titulo: 'Cantidad',
                                valor:
                                    p.cantidad?.toString() ?? 'No especificado',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Informacion general',
              children: [
                _infoTile('Nombre', _safeText(p.nombre)),
                _infoTile('Codigo', _safeText(p.codigo)),
                _infoTile('Categoria', _safeText(widget.categoriaNombre)),
                _infoTile('Grosor', _safeText(p.grosor)),
                _infoTile(
                  'Precio unitario',
                  p.precio != null ? _money(p.precio!) : 'No especificado',
                ),
                _infoTile(
                  'Cantidad',
                  p.cantidad?.toString() ?? 'No especificado',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Descripcion',
              children: [
                Text(
                  _safeText(p.descripcion),
                  style: const TextStyle(fontSize: 14.5, height: 1.45),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _deleting ? null : _editar,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar producto'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _deleting ? null : _confirmEliminar,
              icon: const Icon(Icons.delete_outline),
              label: Text(_deleting ? 'Eliminando...' : 'Eliminar producto'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF0F1F5),
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 72,
        color: Colors.grey,
      ),
    );
  }

  Widget _chipDato({required IconData icon, required String texto}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9D2612)),
          const SizedBox(width: 8),
          Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _resumenDato({required String titulo, required String valor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 155,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
