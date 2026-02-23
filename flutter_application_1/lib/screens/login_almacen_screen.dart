import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/selector_service.dart';

class LoginAlmacenScreen extends StatefulWidget {
  const LoginAlmacenScreen({super.key});

  @override
  State<LoginAlmacenScreen> createState() => _LoginAlmacenScreenState();
}

class _LoginAlmacenScreenState extends State<LoginAlmacenScreen> {
  static const Color celesteBase = Color(0xFF79BDDD);
  static const Color rojoBoton = Color(0xFF9D2612);

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController empresaController = TextEditingController();
  final SelectorService _selectorService = SelectorService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: celesteBase),

          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
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
                      Image.asset("assets/images/rojo.png", height: 95),

                      const SizedBox(height: 20),

                      const Text(
                        "INICIAR SESIÓN - ALMACÉN",
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
                          onPressed: _isLoading ? null : _loginAlmacen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rojoBoton,
                            foregroundColor: Colors.white,
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
                                      Colors.white,
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

  Future<void> _loginAlmacen() async {
    if (nombreController.text.isEmpty || empresaController.text.isEmpty) {
      _mostrarError("Por favor completa todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resultado = await _selectorService.loginAlmacen(
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

        context.go('/productos');
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

  @override
  void dispose() {
    nombreController.dispose();
    empresaController.dispose();
    super.dispose();
  }

  Future<void> _guardarToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } catch (_) {}
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
