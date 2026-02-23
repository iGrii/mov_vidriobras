import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'menu_screen.dart';
import 'menu_operaciones_screen.dart';
=======
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
<<<<<<< HEAD
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
=======
  static const Color celeste = Color(0xFF79BDDD);
  static const Color rojo = Color(0xFF9D2612);
  static const Color amarillo = Color(0xFFF5C542);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: celeste,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/rojo.png', height: 35),
            const SizedBox(width: 10),
            const Text('Operaciones', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: amarillo,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('2', style: TextStyle(fontSize: 10)),
                ),
              ),
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
            ],
          ),
        ],
      ),
<<<<<<< HEAD
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
=======
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _resumen('Pendientes', '2 tareas', rojo, Icons.warning),
          _resumen('En Proceso', '0 tareas', celeste, Icons.access_time),
          _resumen('Completadas', '1 tarea', Colors.green, Icons.check_circle),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: celeste,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🔧 Servicios',
              style: TextStyle(
                color: Colors.black,
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
<<<<<<< HEAD

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
=======
          const SizedBox(height: 10),
          _servicio(
            titulo: 'Instalación de Ventana',
            detalle: 'Ventana de Aluminio · 4 unidades',
            lugar: 'Casa Residencial',
            estado: 'Urgente',
            hora: '08:30 AM',
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
=======

  Widget _resumen(String titulo, String tareas, Color color, IconData icono) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(tareas, style: TextStyle(color: color)),
            ],
          ),
          Icon(icono, color: color),
        ],
      ),
    );
  }

  Widget _servicio({
    required String titulo,
    required String detalle,
    required String lugar,
    required String estado,
    required String hora,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(detalle),
            Text(lugar, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: rojo,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estado,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Text(hora),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: amarillo),
                  onPressed: () {},
                  child: const Text(
                    'Realizar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
}
