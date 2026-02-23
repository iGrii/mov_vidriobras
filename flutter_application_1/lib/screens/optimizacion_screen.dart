import 'package:flutter/material.dart';

class OptimizacionScreen extends StatelessWidget {
  const OptimizacionScreen({super.key});

<<<<<<< HEAD
  static const Color rojo = Color(0xFF9D2612);
  static const Color celeste = Color(0xFF79BDDD);
  static const Color fondo = Color(0xFFF4F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: Column(
        children: [
          // =====================================================
          // HEADER SUPERIOR MODERNO
          // =====================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
            decoration: const BoxDecoration(
              color: celeste,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Optimización",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.tune, color: Colors.white, size: 26),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // CONTENIDO
          // =====================================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // =========================================
                // ETIQUETA SECCIÓN
                // =========================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: celeste,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    "Lista de Optimización",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                _tarea(
                  titulo: "Optimización de Corte",
                  detalle: "Vidrio templado 10mm · 15 unidades",
                  proyecto: "Proyecto Torre",
                  estado: "ALTA",
                  hora: "11:00 AM",
                  urgente: false,
                ),

                _tarea(
                  titulo: "Corte de Aluminio",
                  detalle: "Perfil de aluminio · 20 unidades",
                  proyecto: "Edificio Comercial",
                  estado: "URGENTE",
                  hora: "11:30 AM",
                  urgente: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TARJETA TAREA MODERNA
  // =====================================================
=======
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

>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
  Widget _tarea({
    required String titulo,
    required String detalle,
    required String proyecto,
    required String estado,
    required String hora,
    required bool urgente,
  }) {
    return Container(
<<<<<<< HEAD
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
=======
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          // TITULO
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 6),

          Text(detalle, style: const TextStyle(color: Colors.black54)),
          Text(proyecto, style: const TextStyle(color: Colors.black45)),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CHIP ESTADO
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: urgente ? rojo : Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(25),
=======
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
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: urgente ? Colors.white : Colors.black,
<<<<<<< HEAD
                    fontWeight: FontWeight.bold,
=======
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
                    fontSize: 12,
                  ),
                ),
              ),
<<<<<<< HEAD

              // HORA
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(hora, style: const TextStyle(color: Colors.grey)),
                ],
              ),
=======
              const SizedBox(width: 10),
              Text(hora, style: const TextStyle(color: Colors.grey)),
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
            ],
          ),
        ],
      ),
    );
  }
}
