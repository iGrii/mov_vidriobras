import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  static const Color rojo = Color(0xFF9D2612);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        selectedItemColor: rojo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType
            .fixed, // Para que se vean los labels siempre
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Servicios'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
<<<<<<< HEAD
            label: 'Optimizar',
=======
            label: 'Optimización',
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
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
