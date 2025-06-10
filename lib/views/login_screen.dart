import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
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

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Por favor ingrese usuario y contraseña";
      });
      return;
    }

    // Validación contra inyección SQL
    if (_containsSQLInjection(username) || _containsSQLInjection(password)) {
      setState(() {
        _errorMessage =
            "Entrada inválida detectada. Revise su usuario o contraseña.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    bool success = await authService.login(username, password);

    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      setState(() => _errorMessage = "Usuario o contraseña incorrectos");
    }
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
                SvgPicture.asset(
                  'assets/logooptica.svg',
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Inicio de Sesión",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInputField(
                        Icons.person,
                        "Usuario",
                        _usernameController,
                        false,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        Icons.lock,
                        "Contraseña",
                        _passwordController,
                        true,
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16548D),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: const Text(
                                  "Ingresar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para los campos de texto
  Widget _buildInputField(
    IconData icon,
    String hint,
    TextEditingController controller,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      onSubmitted: isPassword ? (_) => _login() : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF16548D)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF16548D),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }
}
