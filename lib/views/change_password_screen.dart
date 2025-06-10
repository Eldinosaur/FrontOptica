import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';

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
  String? _errorMessage;

  // Método para detectar inyección SQL
  bool _containsSQLInjection(String input) {
    final pattern = RegExp(
      r"(?:')|(?:--)|(/\*(?:.|[\n\r])*?\*/)|"
      r"\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE)?|INSERT|MERGE|SELECT|UPDATE|UNION|USE)\b",
      caseSensitive: false,
    );
    return pattern.hasMatch(input);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String currentPassword = _currentPasswordController.text;
      String newPassword = _newPasswordController.text;

      // Validación contra inyección SQL
      if (_containsSQLInjection(currentPassword) || _containsSQLInjection(newPassword)) {
        setState(() {
          _errorMessage = "Entrada inválida detectada. Revise su contraseña.";
        });
        return;
      }

      bool success = await context.read<AuthService>().cambiarClave(
        currentPassword,
        newPassword,
      );

      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                success ? 'assets/check.json' : 'assets/fail.json',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Text(
                success
                    ? 'La contraseña se cambió correctamente.'
                    : 'Hubo un error al cambiar la contraseña.',
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (success && context.mounted) {
        context.go('/ajustes');
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
                    constraints: const BoxConstraints(maxWidth: 400),
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
                              if (value == null || value.isEmpty) {
                                return 'Este campo es obligatorio';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            onPressed: _submit,
                            label: 'Guardar Cambios',
                            icon: Icons.save,
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
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            if (_containsSQLInjection(value)) {
              return 'Entrada inválida detectada';
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF16548D)),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Color(0xFF16548D)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
