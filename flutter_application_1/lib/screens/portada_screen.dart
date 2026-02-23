import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

<<<<<<< HEAD
class PortadaScreen extends StatefulWidget {
  const PortadaScreen({super.key});

  @override
  State<PortadaScreen> createState() => _PortadaScreenState();
}

class _PortadaScreenState extends State<PortadaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeFondo;
  late Animation<double> _scaleLogo;
  late Animation<Offset> _slideTexto;

  @override
  void initState() {
    super.initState();

    // CONTROLADOR PRINCIPAL
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // FONDO APARECE
    _fadeFondo = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // LOGO ZOOM SUAVE
    _scaleLogo = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // TEXTO SUBE DESDE ABAJO
    _slideTexto = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // CAMBIO AUTOMÁTICO DE PANTALLA
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _irInicio() {
    context.go('/');
  }

  @override
=======
class PortadaScreen extends StatelessWidget {
  const PortadaScreen({super.key});

  @override
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
<<<<<<< HEAD
        onTap: _irInicio,
        child: Stack(
          children: [
            // =====================================================
            // FONDO CON FADE
            // =====================================================
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeFondo,
                child: Image.asset(
                  'assets/images/celeste.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Overlay suave
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.26)),
            ),

            // =====================================================
            // LOGOS ANIMADOS
            // =====================================================
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO ROJO (MAS GRANDE + ZOOM)
                    ScaleTransition(
                      scale: _scaleLogo,
                      child: Image.asset(
                        'assets/images/rojo.png',
                        width: 180, // MÁS GRANDE
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TEXTO MARCA (SUBE DESDE ABAJO)
                    SlideTransition(
                      position: _slideTexto,
                      child: Image.asset(
                        'assets/images/bras_rojo.png',
                        width: 240, // MÁS GRANDE
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
=======
        onTap: () => context.go('/'),
        child: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Image.asset(
              'assets/images/portada.png',
              fit: BoxFit.contain,
            ),
          ),
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
        ),
      ),
    );
  }
}
