import 'dart:math'
    as math; // <--- IMPORTANTE: Agrega esto para que funcione la rotación
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  final String origen;

  const LoginScreen({super.key, required this.origen});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color rojoOscuro = Color(0xFF9D2612);
  static const Color azulCielo = Color(0xFF4DB6E3);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            // ---------------------------------------------
            // 1. IMAGEN ESQUINA INFERIOR IZQUIERDA (Tu código)
            // ---------------------------------------------
            Positioned(
              bottom: -160,
              left: 0,
              child: Transform.rotate(
                angle: -50 * (math.pi / 180), // Rotación de -50 grados
                child: Image.asset(
                  "assets/images/celeste.png",
                  width: 250, // Tamaño fijo como pediste
                ),
              ),
            ),

            // ---------------------------------------------
            // 2. CONTENIDO (Cabecera + Formulario)
            // ---------------------------------------------
            SingleChildScrollView(
              child: Column(
                children: [
                  // === CABECERA ===
                  Container(
                    height: size.height * 0.35,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/vidrio_rojo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // LOGO
                        Positioned(
                          top: 50,
                          left: 20,
                          child: Image.asset(
                            'assets/images/rojo.png',
                            height: 60,
                          ),
                        ),

                        // TEXTO BIENVENIDA
                        const Positioned(
                          bottom: 30,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Hola!',
                                style: TextStyle(
                                  color: azulCielo,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Bienvenido a Vidriobras',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === FORMULARIO ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: rojoOscuro,
                          ),
                        ),

                        const SizedBox(height: 30),

                        _inputPersonalizado(
                          hint: 'Email',
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 20),

                        _inputPersonalizado(
                          hint: 'Contraseña',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),

                        const SizedBox(height: 40),

                        // Botón
                        SizedBox(
                          width: 220,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              context.go('/servicios');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: rojoOscuro,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shadowColor: Colors.black45,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Ingresar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputPersonalizado({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
