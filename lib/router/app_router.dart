import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../views/login_screen.dart';
import '../views/home_screen.dart';
import '../views/add_patient_screen.dart';
import '../views/patients_screen.dart';
import '../views/patient_detail_screen.dart';
import '../views/edit_patient_screen.dart';
import '../views/settings_screen.dart';
import '../views/change_password_screen.dart';
import '../views/rx_detail_screen.dart';
import '../shell/app_shell.dart';
import '../services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    // Ruta de login fuera del shell
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Rutas dentro del Shell (estructura común con Drawer, BottomNav, etc.)
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/pacientes',
          builder: (context, state) => PatientsScreen(),
        ),
        GoRoute(
          path: '/paciente/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PatientDetailScreen(pacienteId: id);
          },
        ),
        GoRoute(
          path: '/agregar_paciente',
          builder: (context, state) => AddPatientScreen(),
        ),
        GoRoute(
          path: '/editar_paciente/:id',
          builder: (context, state) {
            final pacienteId = state.pathParameters['id']!;
            return EditPatientScreen(pacienteId: pacienteId);
          },
        ),
        GoRoute(
          path: '/ajustes',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/cambioclave',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: '/consulta_detalle/:idPaciente/:idConsulta',
          builder: (context, state) {
            final paciente = state.pathParameters['idPaciente']!;
            final consulta = state.pathParameters['idConsulta']!;
            return RxDetailScreen(pacienteId: paciente, consultaId: consulta);
          },
        ),
      ],
    ),
  ],

  redirect: (BuildContext context, GoRouterState state) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isAuthenticated = authService.isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';

    // Si no está autenticado y no está en login, redirige a login
    if (!isAuthenticated && !isLoggingIn) {
      return '/login';
    }

    // Si está autenticado y está en login, redirige a home
    if (isAuthenticated && isLoggingIn) {
      return '/home';
    }

    return null; // No redirección necesaria
  },

  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Ruta no encontrada: ${state.error}')),
      ),
);
