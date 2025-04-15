import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientDetailScreen extends StatelessWidget {
  final String pacienteId;

  const PatientDetailScreen({required this.pacienteId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Paciente"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pacientes'), // Regresa a la pantalla anterior
        ),
      ),
      body: Center(
        child: Text(
          "Detalles del paciente ID: $pacienteId",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
