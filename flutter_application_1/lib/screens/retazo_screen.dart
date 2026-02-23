import 'package:flutter/material.dart';
import 'menu_operaciones_screen.dart';
import '../services/productos_service.dart';

class RetazoScreen extends StatefulWidget {
  const RetazoScreen({super.key});

  @override
  State<RetazoScreen> createState() => _RetazoScreenState();
}

class _RetazoScreenState extends State<RetazoScreen> {
  static const Color rojo = Color(0xFF9D2612);
  final ProductosService _productosService = ProductosService();
  late Future<List<Map<String, dynamic>>> productosMatriz;

  @override
  void initState() {
    super.initState();
    productosMatriz = _productosService.listarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Retazos"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: rojo,
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.black54,
              builder: (_) => const MenuOperacionesScreen(),
            );
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: productosMatriz,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final productos = snapshot.data ?? [];

          if (productos.isEmpty) {
            return const Center(child: Text('No hay retazos disponibles'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productos.length,
            itemBuilder: (_, i) {
              final p = productos[i];
              return Card(
                child: ListTile(
                  title: Text(
                    p['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Medida: ${p['medida'] ?? 'N/A'}'),
                  trailing: p['imagen'] != null
                      ? Image.network(
                          p['imagen'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(Icons.image_not_supported);
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
