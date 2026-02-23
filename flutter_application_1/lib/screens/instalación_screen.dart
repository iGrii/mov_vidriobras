import 'package:flutter/material.dart';
import 'menu_operaciones_screen.dart';

class InstalacionScreen extends StatefulWidget {
  const InstalacionScreen({super.key});

  @override
  State<InstalacionScreen> createState() => _InstalacionScreenState();
}

class _InstalacionScreenState extends State<InstalacionScreen> {
  static const Color rojo = Color(0xFF9D2612);

  final fecha = TextEditingController();
  final tecnico = TextEditingController();
  final observacion = TextEditingController();

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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _input("Fecha instalación", fecha),
            const SizedBox(height: 10),
            _input("Técnico", tecnico),
            const SizedBox(height: 10),
            _fotoBox(),
            const SizedBox(height: 10),
            _input("Observaciones", observacion, max: 4),
            const SizedBox(height: 20),
            _guardar(),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c, {int max = 1}) {
    return TextField(
      controller: c,
      maxLines: max,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _fotoBox() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: rojo),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Text("Subir foto")),
    );
  }

  Widget _guardar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: rojo),
      onPressed: () {},
      child: const Text("Guardar", style: TextStyle(color: Colors.white)),
    );
  }
}
