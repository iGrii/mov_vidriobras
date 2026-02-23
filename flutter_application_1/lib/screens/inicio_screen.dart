import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/celeste.png", fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Container(color: const Color(0xFF941918).withOpacity(0.85)),
          ),

          SafeArea(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset('assets/images/rojo.png', height: 100),
                  const Spacer(),

                  // 🏬 BOTÓN ALMACÉN
                  _botonAlmacen(context),

                  const SizedBox(height: 20),

                  // 🧰 BOTÓN OPERACIONES
                  _botonOperaciones(context),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧰 BOTÓN OPERACIONES
  Widget _botonOperaciones(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          context.push('/login'); // Va a LoginScreen (OPERACIONES)
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF80C2DC),
          foregroundColor: const Color(0xFF941918),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 22),
            SizedBox(width: 10),
            Text(
              "OPERACIONES",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏬 BOTÓN ALMACÉN
  Widget _botonAlmacen(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          context.push('/login-almacen'); // Va a LoginAlmacenScreen (ALMACÉN)
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF941918),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 22),
            SizedBox(width: 10),
            Text(
              "ALMACÉN",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
