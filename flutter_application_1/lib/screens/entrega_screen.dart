import 'package:flutter/material.dart';

class EntregaScreen extends StatelessWidget {
  const EntregaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      // APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF79BDDD),
        elevation: 0,
        title: const Text(
          'Entregas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ),

      // CONTENIDO
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF79BDDD), Color(0xFF5AA9CC)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Lista de Productos a Entregar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // TARJETAS DE PRODUCTOS
            _producto(
              producto: 'Ventana de Vidrio',
              cantidad: '4 unidades',
              cliente: 'Cliente: Constructora Lima',
              estado: 'En Ruta',
              hora: '08:30 AM',
              urgente: false,
            ),

            _producto(
              producto: 'Puerta de Aluminio',
              cantidad: '2 unidades',
              cliente: 'Cliente: Edificio Central',
              estado: 'Urgente',
              hora: '09:15 AM',
              urgente: true,
            ),

            _producto(
              producto: 'Mampara de Vidrio',
              cantidad: '1 unidad',
              cliente: 'Cliente: Residencial Sol',
              estado: 'Pendiente',
              hora: '10:00 AM',
              urgente: false,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // TARJETA DE PRODUCTO
  // =====================================================
  Widget _producto({
    required String producto,
    required String cantidad,
    required String cliente,
    required String estado,
    required String hora,
    required bool urgente,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOMBRE PRODUCTO
          Text(
            producto,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2A2A2A),
            ),
          ),

          const SizedBox(height: 6),

          Text(cantidad, style: const TextStyle(color: Colors.grey)),

          Text(cliente, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          // ESTADO + HORA
          Row(
            children: [
              // BADGE ESTADO
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: urgente
                      ? const Color(0xFF9D2612)
                      : const Color(0xFFE0F2F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: urgente ? Colors.white : const Color(0xFF0B8FB0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // HORA
              Row(
                children: const [
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                ],
              ),

              Text(hora, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
