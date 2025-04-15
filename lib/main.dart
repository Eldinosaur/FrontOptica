import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'router/app_router.dart'; // Archivo de rutas

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crea una instancia del servicio de autenticación
  final authService = AuthService();

  // Verifica si hay un token guardado y si es válido
  await authService.checkAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => authService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EyeMedix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter, // Usamos la instancia importada
    );
  }
}
