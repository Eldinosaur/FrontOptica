import 'package:go_router/go_router.dart';
import '../views/login_screen.dart';
import '../views/home_screen.dart';
import '../views/patients_screen.dart';
import '../views/patient_detail_screen.dart';
import '../views/settings_screen.dart';
import '../views/change_password_screen.dart';
import '../shell/app_shell.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoginScreen()),
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
          path: '/ajustes',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/cambioclave',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
    ),
  ],
);
