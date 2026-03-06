import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/almacen_model.dart';
import 'package:flutter_application_1/services/producto_action_service.dart';
import 'package:flutter_application_1/screens/agregar_producto_page.dart';

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
    final deleted =
        await _actionService.confirmarYEliminarProducto(context, widget.producto);
    setState(() => _deleting = false);
    if (deleted && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _editar() async {
    // push AgregarProductoUI in edit mode
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AgregarProductoUI(
          onProductoAgregado: () {},
          producto: widget.producto,
        ),
      ),
    );

    if (refreshed == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (p.imagen != null && p.imagen!.startsWith('http'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      p.imagen!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Icon(Icons.inventory_2, size: 96),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.categoriaNombre ?? p.categoriaId ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.precio != null
                            ? 'S/ ${p.precio!.toStringAsFixed(2)}'
                            : 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (p.descripcion != null) Text(p.descripcion!),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _deleting ? null : _confirmEliminar,
                    child: _deleting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Eliminar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _editar,
                    child: const Text('Editar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
