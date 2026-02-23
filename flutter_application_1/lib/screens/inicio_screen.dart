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
<<<<<<< HEAD
=======
          // 🖼️ Imagen de fondo
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
          Positioned.fill(
            child: Image.asset("assets/images/celeste.png", fit: BoxFit.cover),
          ),

<<<<<<< HEAD
=======
          // 🔴 Overlay rojo
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
          Positioned.fill(
            child: Container(color: const Color(0xFF941918).withOpacity(0.85)),
          ),

<<<<<<< HEAD
=======
          // 🧩 Contenido
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
          SafeArea(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
<<<<<<< HEAD
                  Image.asset('assets/images/rojo.png', height: 100),
                  const Spacer(),

                  // 🏬 BOTÓN ALMACÉN
                  _botonAlmacen(context),
=======

                  // LOGO
                  Image.asset('assets/images/rojo.png', height: 100),

                  const Spacer(),

                  // 🏬 BOTÓN ALMACÉN
                  _botonAlmacen(context, texto: "ALMACÉN"),
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04

                  const SizedBox(height: 20),

                  // 🧰 BOTÓN OPERACIONES
<<<<<<< HEAD
                  _botonOperaciones(context),
=======
                  _botonOperaciones(
                    context,
                    texto: "OPERACIONES",
                    origen: 'Operaciones',
                  ),
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04

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
<<<<<<< HEAD
  Widget _botonOperaciones(BuildContext context) {
=======
  Widget _botonOperaciones(
    BuildContext context, {
    required String texto,
    required String origen,
  }) {
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
    return SizedBox(
      width: 240,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
<<<<<<< HEAD
          context.push('/login'); // Va a LoginScreen (OPERACIONES)
=======
          context.push('/login', extra: origen);
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF80C2DC),
          foregroundColor: const Color(0xFF941918),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
<<<<<<< HEAD
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 22),
=======
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.build,
              size: 22,
              color: const Color(0xFF941918),
            ), // 🧰 service_toolbox
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
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
<<<<<<< HEAD
  Widget _botonAlmacen(BuildContext context) {
=======
  Widget _botonAlmacen(BuildContext context, {required String texto}) {
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
    return SizedBox(
      width: 240,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
<<<<<<< HEAD
          context.push('/login-almacen'); // Va a LoginAlmacenScreen (ALMACÉN)
=======
          context.push('/productos');
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF941918),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
<<<<<<< HEAD
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 22),
=======
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.store, size: 22), // 🏬 store_24
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
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
