import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'notificacion_bell_widget.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  static const Color rojo = Color(0xFF9D2612);
  static const Color azulPrincipal = Color(0xFF79BDDD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AppBar con campana de notificaciones
      appBar: AppBar(
        backgroundColor: azulPrincipal,
        elevation: 0,
        title: const Text(
          'VIDRIOBRAS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // 🔔 Campana de notificaciones
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: NotificacionBell(
                clienteId: null, // Cambia con tu cliente_id si lo necesitas
                bellColor: Colors.white,
                badgeColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        selectedItemColor: rojo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Servicios'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Optimizar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Entrega',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Salir'),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // Si presionan "Salir" (índice 3), volvemos al inicio y no cambiamos de tab
    if (index == 3) {
      context.go('/');
    } else {
      // Para los otros índices, cambiamos a la rama correspondiente
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }
  }
}
