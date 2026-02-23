import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'menu_operaciones_screen.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  static const Color rojo = Color(0xFF9D2612);
  static const Color grisFondo = Color(0xFFF4F6F8);

  List<String> clientes = [
    "Carlos",
    "María",
    "José",
    "Andrea",
    "Luis",
    "Sofía",
  ];

  String? clienteSeleccionado;
  String textoBusqueda = "";

  final Map<String, List<Map<String, String>>> tareasCliente = {
    "Carlos": [
      {
        "titulo": "Instalación de Ventanas",
        "detalle": "Ventana de vidrio · 4 unidades",
        "hora": "8:30 AM",
        "estado": "ENTREGA",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final clientesFiltrados = clientes
        .where((c) => c.toLowerCase().contains(textoBusqueda.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: grisFondo,
      body: Stack(
        children: [
          // =========================
          // FONDO SUPERIOR
          // =========================
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Image.asset("assets/images/celeste.png", fit: BoxFit.cover),
          ),

          // =========================
          // LOGO CENTRADO + MENU
          // =========================
          SafeArea(
            child: Stack(
              children: [
                // LOGO MÁS ARRIBA
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset("assets/images/rojo.png", height: 160),
                  ),
                ),

                // MENU BOTON
                Positioned(
                  top: 18,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    color: rojo,
                    iconSize: 30,
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black54,
                        builder: (_) => const MenuOperacionesScreen(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // =========================
          // CONTENIDO
          // =========================
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 200, 20, 20),
            children: [
              // SELECTOR CLIENTES
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: clientesFiltrados.map((cliente) {
                    final seleccionado = clienteSeleccionado == cliente;

                    return GestureDetector(
                      onTap: () {
                        setState(() => clienteSeleccionado = cliente);
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: seleccionado
                            ? rojo
                            : Colors.blue.shade200,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // BUSCADOR
              TextField(
                onChanged: (v) => setState(() => textoBusqueda = v),
                decoration: InputDecoration(
                  hintText: "Buscar cliente...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              if (clienteSeleccionado == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("Selecciona un cliente"),
                  ),
                )
              else
                Column(
                  children: (tareasCliente[clienteSeleccionado] ?? [])
                      .map((t) => _cardServicio(t))
                      .toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // TARJETA SERVICIO
  // =========================
  Widget _cardServicio(Map<String, String> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: rojo,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Text(
              t["titulo"]!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  t["detalle"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: rojo,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t["estado"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(t["hora"]!),
                  ],
                ),

                const SizedBox(height: 12),

                // BOTON REALIZAR
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black54,
                        builder: (_) => const MenuOperacionesScreen(),
                      );
                    },
                    child: const Text(
                      "REALIZAR",
                      style: TextStyle(color: Colors.white),
                    ),
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
