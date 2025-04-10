import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Simulacion de cambio de clave
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Éxito'),
          content: const Text('La contraseña se cambió correctamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra solo el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ).then((_) {
        if (context.mounted) {
          context.go('/ajustes'); // Redirige a la página de ajustes
        }
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña Actual'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese su contraseña actual' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese una nueva contraseña' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Contraseña'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme su nueva contraseña';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
