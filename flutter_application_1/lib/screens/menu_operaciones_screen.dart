import 'package:flutter/material.dart';
import 'servicios_screen.dart';
import 'remetreo_screen.dart';
import 'retazo_screen.dart';
import 'cortes_screen.dart';
import 'instalación_screen.dart';
import 'inicio_screen.dart';

class MenuOperacionesScreen extends StatelessWidget {
  const MenuOperacionesScreen({super.key});

  static const Color rojo = Color(0xFF9D2612);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),

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
                  _item(context, "INICIO", () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServiciosScreen(),
                      ),
                    );
                  }),
                  _linea(),

                  _item(context, "REMETREO", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RemetreoScreen()),
                    );
                  }),
                  _linea(),

                  _item(context, "RETAZO", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RetazoScreen()),
                    );
                  }),
                  _linea(),

                  _item(context, "CORTES", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CortesScreen()),
                    );
                  }),
                  _linea(),

                  _item(context, "INSTALACIÓN", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InstalacionScreen(),
                      ),
                    );
                  }),
                  _linea(),

                  _item(context, "SALIR", () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const InicioScreen()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
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
