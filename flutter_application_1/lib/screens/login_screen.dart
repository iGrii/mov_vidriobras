import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/selector_service.dart';

class LoginScreen extends StatefulWidget {
  final String origen;

  const LoginScreen({super.key, required this.origen});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color rojo1 = Color(0xFF8E1E12);
  static const Color rojo2 = Color(0xFFB43A2A);
  static const Color azulBoton = Color(0xFF6EC1E4);

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController empresaController = TextEditingController();
  final SelectorService _selectorService = SelectorService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [rojo1, rojo2],
              ),
            ),
          ),

          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                "assets/images/celeste.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/vceleste.png", height: 95),
                      const SizedBox(height: 20),

                      const Text(
                        "INICIAR SESIÓN - OPERACIONES",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      _inputBlanco(
                        controller: nombreController,
                        hint: "NOMBRE",
                      ),

                      const SizedBox(height: 20),

                      _inputBlanco(
                        controller: empresaController,
                        hint: "CÓDIGO DE EMPRESA",
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginOperaciones,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulBoton,
                            foregroundColor: Colors.red.shade900,
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF8E1E12),
                                    ),
                                  ),
                                )
                              : const Text(
                                  "INGRESAR",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
      ),
    );
  }

  Future<void> _loginOperaciones() async {
    if (nombreController.text.isEmpty || empresaController.text.isEmpty) {
      _mostrarError("Por favor completa todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resultado = await _selectorService.loginOperaciones(
        nombreController.text,
        empresaController.text,
      );

      if (!mounted) return;

      if (resultado.success) {
        // Login exitoso: intentar extraer y guardar token si viene en la respuesta
        final dynamic data = resultado.data;
        String? token;
          if (nombreController.text.isEmpty || empresaController.text.isEmpty) {
            _mostrarError("Por favor completa todos los campos");
            return;
          }

          setState(() => _isLoading = true);

          try {
            final resultado = await _selectorService.loginOperaciones(
              nombreController.text,
              empresaController.text,
            );

            if (!mounted) return;

            if (resultado.success) {
              // Login exitoso: intentar extraer y guardar token si viene en la respuesta
              final dynamic data = resultado.data;
              String? token;
              if (data is Map) {
                token = data['token']?.toString() ?? data['access_token']?.toString();
              } else if (data is String) {
                token = data;
              }

              if (token != null && token.isNotEmpty) {
                await _guardarToken(token);
              }

              context.go('/servicios');
            } else {
              // Error específico del servidor
              _mostrarError(resultado.message);
            }
          } catch (e) {
            if (mounted) {
              _mostrarError("Error inesperado: $e");
            }
          } finally {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
        }

        void _mostrarError(String mensaje) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }

        Future<void> _guardarToken(String token) async {
          try {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
          } catch (_) {}
        }

        @override
        void dispose() {
          nombreController.dispose();
          empresaController.dispose();
          super.dispose();
        }

        Widget _inputBlanco({
          required String hint,
          required TextEditingController controller,
        }) {
          return TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          );
        }
      }
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white, width: 2),
=======
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
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
        ),
      ),
    );
  }
}
