import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';
import '../widgets/custom_button.dart';  // Asegúrate de que el archivo esté correctamente importado
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
    if (cedula.isEmpty) {
      _loadPatients();  // Si no hay cédula, carga todos los pacientes
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await PatientService.searchByCedula(cedula);
      setState(() {
        patients = result;
        // Ordenamos la lista de pacientes por ID
        patients.sort((a, b) => a.id.compareTo(b.id));
      });
    } catch (e)      {
      print('Error en búsqueda por cédula: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Método para buscar por nombre
  Future<void> _searchByNombre() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      _loadPatients();  // Si no hay nombre, carga todos los pacientes
      return;
    }

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

  // Método para mostrar una vista para agregar paciente (aquí puedes personalizar)
  void _onAddPatient() {
    print("Botón de agregar paciente presionado.");
    // Redirigir a la pantalla de agregar paciente si es necesario
    context.go('/agregar_paciente'); // Asegúrate de que esta ruta esté definida
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrar todo
          children: [
            const SizedBox(height: 20),
            const Text(
              "Búsqueda de Pacientes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Filtros de búsqueda en filas separadas
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSearchField(
                  "Buscar por Cédula",
                  _cedulaController,
                  _searchByCedula,
                ),
                const SizedBox(height: 10), // Espaciado entre los campos
                _buildSearchField(
                  "Buscar por Nombre",
                  _nombreController,
                  _searchByNombre,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botón de agregar paciente (con PrimaryButton)
            PrimaryButton(
              onPressed: _onAddPatient,  // Acción de agregar paciente
              label: 'Agregar Paciente',
              icon: Icons.add,
            ),

            // Tabla o cargando
            Expanded(
              child: isLoading
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
        ),
      ),
    );
  }

  // Widget personalizado para los campos de búsqueda
  Widget _buildSearchField(
    String label,
    TextEditingController controller,
    VoidCallback onSearch,
  ) {
    return SizedBox(
      width: 300,  // Puedes ajustar el tamaño
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
