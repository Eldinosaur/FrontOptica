import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool isLoading = false;

  bool _containsSQLInjection(String input) {
    final pattern = RegExp(
      r"(?:')|(?:--)|(/\*(?:.|[\n\r])*?\*/)|"
      r"\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE)?|INSERT|MERGE|SELECT|UPDATE|UNION|USE)\b",
      caseSensitive: false,
    );
    return pattern.hasMatch(input);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      if (_containsSQLInjection(currentPassword) || _containsSQLInjection(newPassword)) {
        setState(() => _errorMessage = "Entrada inválida detectada. Revise su contraseña.");
        return;
      }

      setState(() => isLoading = true);

      final success = await context.read<AuthService>().cambiarClave(
            currentPassword,
            newPassword,
          );

      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                success ? 'assets/check.json' : 'assets/fail.json',
                width: 100,
                height: 100,
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
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (success) context.go('/ajustes');

      setState(() => isLoading = false);
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
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ajustes'),
        ),
        ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
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
                      const SizedBox(height: 25),
                      PrimaryButton(
                        onPressed: _submit,
                        label: 'Guardar Cambios',
                        icon: Icons.save,
                      ),
                    ],
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
            if (value == null || value.isEmpty) return 'Este campo es obligatorio';
            if (_containsSQLInjection(value)) return 'Entrada inválida detectada';
            return null;
          },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF16548D)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF16548D)),
        ),
      ),
    );
  }
}
