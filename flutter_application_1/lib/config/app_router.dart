import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/inicio_screen.dart';
import '../screens/login_screen.dart';
import '../screens/servicios_screen.dart';
import '../screens/optimizacion_screen.dart';
import '../screens/productos_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // PANTALLA DE INICIO (Con el nuevo diseño)
    GoRoute(path: '/', builder: (context, state) => const InicioScreen()),

    // LOGIN
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final origen = state.extra as String? ?? 'Operaciones';
        return LoginScreen(origen: origen);
      },
    ),

    // PRODUCTOS
    GoRoute(
      path: '/productos',
      builder: (context, state) => const ProductosPage(),
    ),

    // MENU INFERIOR (SHELL)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Rama 0: Servicios
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/servicios',
              builder: (context, state) => const ServiciosScreen(),
            ),
          ],
        ),
        // Rama 1: Optimización
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/optimizacion',
              builder: (context, state) => const OptimizacionScreen(),
            ),
          ],
        ),
        // Rama 2: Entrega (Placeholder)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/entrega',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text("Pantalla Entrega"))),
            ),
          ],
        ),
      ],
    ),
  ],
);
