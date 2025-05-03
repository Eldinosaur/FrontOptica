import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';

String formatFechaNacimiento(DateTime fecha) {
  return DateFormat('dd-MM-yyyy').format(fecha);
}

class PatientDetailScreen extends StatefulWidget {
  final String pacienteId;

  

  const PatientDetailScreen({required this.pacienteId, super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<Patient> _futurePatient;

  @override
  void initState() {
    super.initState();
    _futurePatient = PatientService.getPatientById(widget.pacienteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Paciente"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pacientes'),
        ),
      ),
      body: FutureBuilder<Patient>(
        future: _futurePatient,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Paciente no encontrado"));
          }

          final patient = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              buildDetailRow("Cédula", patient.cedula),
              buildDetailRow("Nombre", patient.nombres),
              buildDetailRow("Apellido", patient.apellidos),
              buildDetailRow("Fecha de Nacimiento", formatFechaNacimiento(patient.fechaNacimiento)),
              buildDetailRow("Ocupación", patient.ocupacion),
              buildDetailRow("Teléfono", patient.telefono),
              buildDetailRow("Correo", patient.correo),
              buildDetailRow("Dirección", patient.direccion),
              buildDetailRow("Antecedentes", patient.antecedentes),
              buildDetailRow("Condiciones Médicas", patient.condicionesMedicas),
            ],
          );
        },
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
