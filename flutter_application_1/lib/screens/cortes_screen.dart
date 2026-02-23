import 'package:flutter/material.dart';
import 'menu_operaciones_screen.dart';

class CortesScreen extends StatefulWidget {
  const CortesScreen({super.key});

  @override
  State<CortesScreen> createState() => _CortesScreenState();
}

class _CortesScreenState extends State<CortesScreen> {
  static const Color rojo = Color(0xFF9D2612);

  final anchoBase = TextEditingController();
  final altoBase = TextEditingController();
  final anchoPieza = TextEditingController();
  final altoPieza = TextEditingController();

  bool mostrarResultado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
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
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _materialBase(),
                  const SizedBox(height: 20),
                  _pieza(),
                  const SizedBox(height: 20),
                  _botonOptimizar(),
                  const SizedBox(height: 20),
                  if (mostrarResultado) _resultadoCortes(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    height: 120,
    alignment: Alignment.center,
    child: const Text(
      "CORTES Y OPTIMIZACIÓN",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );

  Widget _materialBase() {
    return _card(
      child: Column(
        children: [
          const Text(
            "Material base",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: anchoBase,
            decoration: const InputDecoration(labelText: "Ancho base"),
          ),
          TextField(
            controller: altoBase,
            decoration: const InputDecoration(labelText: "Alto base"),
          ),
        ],
      ),
    );
  }

  Widget _pieza() {
    return _card(
      child: Column(
        children: [
          const Text(
            "Pieza a cortar",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: anchoPieza,
            decoration: const InputDecoration(labelText: "Ancho"),
          ),
          TextField(
            controller: altoPieza,
            decoration: const InputDecoration(labelText: "Alto"),
          ),
        ],
      ),
    );
  }

  Widget _botonOptimizar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: rojo),
      onPressed: () => setState(() => mostrarResultado = true),
      child: const Text("Optimizar", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _resultadoCortes() {
    return _card(
      child: Column(
        children: [
          const Text("Resultado"),
          Container(
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(child: Text("Simulación de cortes")),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}
