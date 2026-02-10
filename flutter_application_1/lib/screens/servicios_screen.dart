import 'package:flutter/material.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
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
            ],
          ),
        ],
      ),
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _servicio(
            titulo: 'Instalación de Ventana',
            detalle: 'Ventana de Aluminio · 4 unidades',
            lugar: 'Casa Residencial',
            estado: 'Urgente',
            hora: '08:30 AM',
          ),
        ],
      ),
    );
  }

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
}
