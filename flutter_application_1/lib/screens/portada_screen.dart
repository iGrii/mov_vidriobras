import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PortadaScreen extends StatelessWidget {
  const PortadaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
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
        ),
      ),
    );
  }
}
