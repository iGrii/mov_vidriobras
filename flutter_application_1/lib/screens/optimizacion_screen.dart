import 'package:flutter/material.dart';

class OptimizacionScreen extends StatelessWidget {
  const OptimizacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF79BDDD),
        elevation: 0,
        title: const Text(
          'Optimización',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications, size: 26, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B8FB0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Lista de Optimización',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _tarea(
              titulo: 'Optimización de Corte',
              detalle: 'Vidrio Templado 10mm · 15 unidades',
              proyecto: 'Proyecto Torre',
              estado: 'Alta',
              hora: '11:00 AM',
              urgente: false,
            ),
            _tarea(
              titulo: 'Corte de Aluminio',
              detalle: 'Perfil de Aluminio · 20 unidades',
              proyecto: 'Edificio Comercial',
              estado: 'Urgente',
              hora: '11:30 AM',
              urgente: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarea({
    required String titulo,
    required String detalle,
    required String proyecto,
    required String estado,
    required String hora,
    required bool urgente,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(detalle, style: const TextStyle(color: Colors.grey)),
          Text(proyecto, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: urgente ? const Color(0xFF9D2612) : Colors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: urgente ? Colors.white : Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(hora, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
