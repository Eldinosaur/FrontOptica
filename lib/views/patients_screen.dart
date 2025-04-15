import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/patient_model.dart';

class PatientsScreen extends StatelessWidget {
  final List<Patient> patients = [
    Patient(id: 1, cedula: '1804523174', nombres: 'Anahí de los Ángeles', apellidos: 'Naranjo López', ultimaConsulta: '16-marzo-2025'),
    // Puedes agregar más pacientes
  ];

  PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Búsqueda de Pacientes",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Filtros
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSearchField("Buscar por Cédula"),
            _buildSearchField("Buscar por Nombre"),
          ],
        ),
        const SizedBox(height: 20),

        // Tabla
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("N°")),
              DataColumn(label: Text("Cédula")),
              DataColumn(label: Text("Nombres")),
              DataColumn(label: Text("Apellidos")),
              DataColumn(label: Text("Última Consulta")),
            ],
            rows: patients.map((paciente) {
              return DataRow(
                cells: [
                  DataCell(Text(paciente.id.toString())),
                  DataCell(Text(paciente.cedula)),
                  DataCell(Text(paciente.nombres)),
                  DataCell(Text(paciente.apellidos)),
                  DataCell(Text(paciente.ultimaConsulta)),
                ],
                onSelectChanged: (_) {
                  context.go('/paciente/${paciente.id}');
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(String label) {
    return SizedBox(
      width: 200,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.search, color: Color(0xFF16548D)),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
