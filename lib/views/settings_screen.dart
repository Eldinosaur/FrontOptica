import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400), // Límite de ancho máximo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/user.png'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Anahi Naranjo',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),

                // Opciones de configuración
                _buildOption(
                  context: context,
                  icon: Icons.lock,
                  title: 'Cambiar contraseña',
                  onTap: () => context.go('/cambioclave'),
                ),
                const SizedBox(height: 16),
                _buildOption(
                  context: context,
                  icon: Icons.logout,
                  title: 'Cerrar sesión',
                  onTap: () => context.go('/'), // Cambia según tu lógica de logout
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para cada opción en la lista
  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF16548D), // Consistente con otras vistas
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black, // Consistente con otras vistas
              ),
            ),
          ],
        ),
      ),
    );
  }
}
