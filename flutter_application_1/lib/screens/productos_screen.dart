import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/models/almacen_model.dart';
import 'package:flutter_application_1/services/almacen_service.dart';
import 'package:flutter_application_1/screens/agregar_producto_page.dart';
import 'package:flutter_application_1/screens/producto_detalle_page.dart';
import 'package:flutter_application_1/screens/reportes_screen.dart';
import 'package:flutter_application_1/services/categoria_service.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  static const Color rojo = Color(0xFF9D2612);
  final AlmacenService _almacenService = AlmacenService();
  final CategoriaService _categoriaService = CategoriaService();
  late Future<ProductoListResponse> _futureProductos;
  Map<String, String> _categoriaMap = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos'), elevation: 0),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomAction(
              icon: Icons.inventory_2,
              label: 'Inventario',
              active: _currentIndex == 0,
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                _cargarProductos();
              },
            ),
            _BottomAction(
              icon: Icons.add,
              label: 'Agregar',
              active: _currentIndex == 1,
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            _BottomAction(
              icon: Icons.bar_chart,
              label: 'Reportes',
              active: _currentIndex == 2,
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            _BottomAction(
              icon: Icons.logout,
              label: 'Salir',
              onTap: () {
                context.go('/');
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }
}

Widget _buildBody() {
  // This helper will be converted to an instance method by using a Builder in the widget tree.
  return Builder(
    builder: (context) {
      final state = context.findAncestorStateOfType<_ProductosPageState>();
      if (state == null) return const SizedBox.shrink();

      switch (state._currentIndex) {
        case 0: // Inventario
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

              final response = snapshot.data;
              final productos = response?.productos ?? [];

              // ensure categories loaded
              if (state._categoriaMap.isEmpty) {
                state._cargarCategorias();
              }

              if (productos.isEmpty) {
                return const Center(
                  child: Text('No hay productos disponibles'),
                );
              }

              return ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading:
                          (producto.imagen != null &&
                              producto.imagen!.startsWith('http'))
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                producto.imagen!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.inventory_2);
                                },
                              ),
                            )
                          : const Icon(Icons.inventory_2),
                      title: Text(
                        producto.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Text(
                        producto.precio != null
                            ? 'S/ ${producto.precio!.toStringAsFixed(2)}'
                            : 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () async {
                        final refreshed = await Navigator.of(context)
                            .push<bool>(
                              MaterialPageRoute(
                                builder: (_) => ProductoDetallePage(
                                  producto: producto,
                                  categoriaNombre:
                                      state._categoriaMap[producto.categoriaId],
                                ),
                              ),
                            );

                        if (refreshed == true) {
                          state._cargarProductos();
                        }
                      },
                    ),
                  );
                },
              );
            },
          );

        case 1: // Agregar
          return AgregarProductoUI(onProductoAgregado: state._cargarProductos);

        case 2: // Reportes
          return const ReportesScreen();

        default:
          return const SizedBox.shrink();
      }
    },
  );
}

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
