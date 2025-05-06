import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';
import '../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

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
      _loadPatients(); // Si no hay cédula, carga todos los pacientes
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
    } catch (e) {
      print('Error en búsqueda por cédula: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Método para buscar por nombre
  Future<void> _searchByNombre() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      _loadPatients(); // Si no hay nombre, carga todos los pacientes
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
    // Redirigir a la pantalla de agregar paciente si es necesario
    context.go('/agregar_paciente'); // Asegúrate de que esta ruta esté definida
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Búsqueda de Pacientes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Filtros
                  _buildSearchField(
                    "Buscar por Cédula",
                    _cedulaController,
                    _searchByCedula,
                  ),
                  const SizedBox(height: 10),
                  _buildSearchField(
                    "Buscar por Nombre",
                    _nombreController,
                    _searchByNombre,
                  ),
                  const SizedBox(height: 20),

                  // Botón
                  PrimaryButton(
                    onPressed: _onAddPatient,
                    label: 'Agregar Paciente',
                    icon: Icons.add,
                  ),
                  const SizedBox(height: 20),

                  // Tabla (con altura dinámica calculada)
                  Expanded(
                    child: Column(
                      children: [
                        // Encabezado
                        Container(
                          color: const Color(0xFF16548D),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          child: Row(
                            children: const [
                              _TableHeader("N°"),
                              _TableHeader("Cédula"),
                              _TableHeader("Nombres"),
                              _TableHeader("Apellidos"),
                              _TableHeader("Última Consulta"),
                            ],
                          ),
                        ),

                        // Lista scrolleable
                        Expanded(
                          child:
                              isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : ListView.builder(
                                    itemCount: patients.length,
                                    itemBuilder: (context, index) {
                                      final paciente = patients[index];
                                      return InkWell(
                                        onTap:
                                            () => context.go(
                                              '/paciente/${paciente.id}',
                                            ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              _TableCell(
                                                paciente.id.toString(),
                                              ),
                                              _TableCell(paciente.cedula),
                                              _TableCell(paciente.nombres),
                                              _TableCell(paciente.apellidos),
                                              _TableCell(
                                                paciente.ultimaConsulta != null
                                                    ? DateFormat(
                                                      "dd-MM-yyyy",
                                                    ).format(
                                                      paciente.ultimaConsulta!,
                                                    )
                                                    : "Sin datos",
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
      width: 300,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón para borrar el campo
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                    });
                    _loadPatients(); // Recargar todos los pacientes
                  },
                ),
              // Botón de búsqueda
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF16548D)),
                onPressed: onSearch,
              ),
            ],
          ),
          border: const OutlineInputBorder(),
        ),
        onChanged:
            (_) => setState(() {}), // Para que se actualice el botón de clear
        onSubmitted: (_) => onSearch(),
      ),
    );
  }
}
