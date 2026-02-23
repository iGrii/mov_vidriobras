import 'package:flutter/material.dart';

class OptimizacionScreen extends StatelessWidget {
  const OptimizacionScreen({super.key});

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
  Widget _tarea({
    required String titulo,
    required String detalle,
    required String proyecto,
    required String estado,
    required String hora,
    required bool urgente,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: urgente ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // HORA
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(hora, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
