import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart'; // Paquete de animaciones Lottie
import '../services/auth_service.dart'; // Importa AuthService
import 'package:provider/provider.dart'; // Usamos Provider para acceder al AuthService

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Obtener los datos del formulario
      String currentPassword = _currentPasswordController.text;
      String newPassword = _newPasswordController.text;

      // Llamamos al servicio de cambio de contraseña
      bool success = await context.read<AuthService>().cambiarClave(currentPassword, newPassword);

      // Mostrar el diálogo de acuerdo al resultado
      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/check.json', // Ruta de la animación
                  width: 100, // Tamaño del ícono
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                const Text('La contraseña se cambió correctamente.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el AlertDialog
                  context.go('/ajustes'); // Navega a la página de ajustes
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/fail.json', // Ruta de la animación de error
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                const Text('Hubo un error al cambiar la contraseña.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el AlertDialog
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Cambiar Contraseña',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 400, // Limita el ancho del formulario
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInputField(
                            icon: Icons.lock_outline,
                            hint: 'Contraseña Actual',
                            controller: _currentPasswordController,
                          ),
                          const SizedBox(height: 15),
                          _buildInputField(
                            icon: Icons.lock,
                            hint: 'Nueva Contraseña',
                            controller: _newPasswordController,
                          ),
                          const SizedBox(height: 15),
                          _buildInputField(
                            icon: Icons.lock_reset,
                            hint: 'Confirmar Contraseña',
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value != _newPasswordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16548D),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Este campo es obligatorio' : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF16548D)),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Color(0xFF16548D), width: 2),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
    );
  }
}
