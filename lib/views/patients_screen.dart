import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';
import 'package:intl/intl.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<Patient> patients = [];
  bool isLoading = true;

  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients(); // Cargar todos los pacientes al inicio
  }

  // Método que obtiene todos los pacientes
  Future<void> _loadPatients() async {
    setState(() => isLoading = true);
    try {
      final result = await PatientService.getAllPatients();
      setState(() {
        patients = result;
        // Ordenamos la lista de pacientes por ID
        patients.sort((a, b) => a.id.compareTo(b.id));
      });
    } catch (e) {
      print('Error al cargar pacientes: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Método para buscar por cédula
  Future<void> _searchByCedula() async {
    final cedula = _cedulaController.text.trim();
    if (cedula.isEmpty) return; // No hace nada si el campo está vacío

    setState(() => isLoading = true);
    try {
      final result = await PatientService.searchByCedula(cedula);
      setState(() {
        patients = result;
        // Ordenamos la lista de pacientes por ID
        patients.sort((a, b) => a.id.compareTo(b.id));
      });
    } catch (e) {
      print('Error en búsqueda por cédula: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Método para buscar por nombre
  Future<void> _searchByNombre() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) return; // No hace nada si el campo está vacío

    setState(() => isLoading = true);
    try {
      final result = await PatientService.searchByNombre(nombre);
      setState(() {
        patients = result;
        // Ordenamos la lista de pacientes por ID
        patients.sort((a, b) => a.id.compareTo(b.id));
      });
    } catch (e) {
      print('Error en búsqueda por nombre: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

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

        // Filtros de búsqueda
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSearchField(
              "Buscar por Cédula",
              _cedulaController,
              _searchByCedula,
            ),
            _buildSearchField(
              "Buscar por Nombre",
              _nombreController,
              _searchByNombre,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Tabla o cargando
        Expanded(
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false, // Eliminar checkboxes
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
                              DataCell(
                                Text(
                                  paciente.ultimaConsulta != null
                                      ? DateFormat("dd-MM-yyyy")
                                          .format(paciente.ultimaConsulta!)
                                      : "Sin datos",
                                ),
                              ),
                            ],
                            onSelectChanged: (_) {
                              context.go('/paciente/${paciente.id}');
                            },
                          );
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }

  // Widget personalizado para los campos de búsqueda
  Widget _buildSearchField(
    String label,
    TextEditingController controller,
    VoidCallback onSearch,
  ) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF16548D)),
            onPressed: onSearch,
          ),
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => onSearch(), // También busca al presionar Enter
      ),
    );
  }
}
