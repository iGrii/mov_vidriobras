import 'package:flutter/material.dart';
import 'config/app_router.dart'; // Asegúrate de importar tu router

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'App Flutter',
      // CONFIGURACIÓN DEL TEMA SOLICITADA
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF79BDDD)),
      ),
      routerConfig: appRouter,
    );
  }
}
