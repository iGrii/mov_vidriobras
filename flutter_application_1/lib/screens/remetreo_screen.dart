import 'package:flutter/material.dart';
import 'menu_operaciones_screen.dart';

class RemetreoScreen extends StatefulWidget {
  const RemetreoScreen({super.key});

  @override
  State<RemetreoScreen> createState() => _RemetreoScreenState();
}

class _RemetreoScreenState extends State<RemetreoScreen> {
  static const Color rojo = Color(0xFF9D2612);

  final anchoController = TextEditingController();
  final altoController = TextEditingController();
  final descripcionController = TextEditingController();

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
            _header("REMETREO"),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _cardMedidas(),
                  const SizedBox(height: 20),
                  _cardDescripcion(),
                  const SizedBox(height: 25),
                  _botonGuardar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String titulo) {
    return Stack(
      children: [
        SizedBox(
          height: 120,
          width: double.infinity,
          child: Image.asset("assets/images/celeste.png", fit: BoxFit.cover),
        ),
        Container(
          height: 120,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
              color: rojo,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardMedidas() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardStyle(),
      child: Column(
        children: [
          Image.asset("assets/images/plano.png", height: 140),
          const SizedBox(height: 20),
          _inputMedida("Ancho (cm)", anchoController),
          const SizedBox(height: 10),
          _inputMedida("Alto (cm)", altoController),
        ],
      ),
    );
  }

  Widget _cardDescripcion() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardStyle(),
      child: TextField(
        controller: descripcionController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: "Descripción",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _inputMedida(String label, TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _botonGuardar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: rojo,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: () {},
      child: const Text("Guardar", style: TextStyle(color: Colors.white)),
    );
  }

  BoxDecoration _cardStyle() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
  );
}
