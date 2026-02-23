import 'package:flutter/material.dart';
import 'remetreo_screen.dart';
import 'retazo_screen.dart';
import 'cortes_screen.dart';
import 'instalación_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const Color rojo = Color(0xFF9D2612);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // =====================================
          // CERRAR TOCANDO FUERA
          // =====================================
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),

          // =====================================
          // PANEL MENU
          // =====================================
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 120),
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: 320,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RemetreoScreen(),
                        ),
                      );
                    },
                    child: _item("REMETREO"),
                  ),
                  _linea(),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RetazoScreen()),
                      );
                    },
                    child: _item("RETAZO"),
                  ),
                  _linea(),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CortesScreen()),
                      );
                    },
                    child: _item("CORTES"),
                  ),
                  _linea(),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InstalacionScreen(),
                        ),
                      );
                    },
                    child: _itemRojo("INSTALACIÓN"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // ITEM NORMAL
  // =====================================
  Widget _item(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const CircleAvatar(radius: 16, backgroundColor: Colors.white),
        ],
      ),
    );
  }

  // =====================================
  // ITEM ACTIVO ROJO
  // =====================================
  Widget _itemRojo(String texto) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: rojo,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const CircleAvatar(radius: 16, backgroundColor: Colors.white),
        ],
      ),
    );
  }

  Widget _linea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: 1,
      color: Colors.white70,
    );
  }
}
