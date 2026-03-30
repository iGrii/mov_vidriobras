import 'package:flutter/material.dart';
import '../models/entrega_notificacion_model.dart';

class NotificacionEntregaWidget extends StatelessWidget {
  final EntregaNotificacion notificacion;
  final VoidCallback onRealizar;
  final VoidCallback onEliminar;

  const NotificacionEntregaWidget({
    required this.notificacion,
    required this.onRealizar,
    required this.onEliminar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _getColorByTipo(), width: 4)),
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
          // Título
          Text(
            notificacion.titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 8),
          // Mensaje
          Text(
            notificacion.mensaje,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // Estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _getColorByTipo().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              notificacion.estado,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getColorByTipo(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRealizar,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Realizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorByTipo() {
    switch (notificacion.tipo) {
      case 'entrega_registrada':
        return Colors.green;
      case 'en_camino':
        return Colors.blue;
      case 'problema':
      case 'error':
        return Colors.red;
      case 'optimizacion':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
