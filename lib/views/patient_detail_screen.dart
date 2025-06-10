import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../models/rx_model.dart';
import '../services/patient_service.dart';
import '../services/rx_service.dart';
import '../widgets/custom_button.dart';

String formatFecha(String fecha) {
  try {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(fecha));
  } catch (_) {
    return fecha;
  }
}

class PatientDetailScreen extends StatefulWidget {
  final String pacienteId;

  const PatientDetailScreen({required this.pacienteId, super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<Patient> _futurePatient;
  late Future<List<ConsultaCompleta>> _futureArmazon;
  late Future<List<ConsultaCompleta>> _futureContacto;

  final ScrollController _horizontalScrollController = ScrollController();

  List<ConsultaCompleta> consultasArmazon = [];
  List<ConsultaCompleta> consultasContacto = [];
  bool showEvolutionButton = false;

  @override
  void initState() {
    super.initState();
    _futurePatient = PatientService.getPatientById(widget.pacienteId);
    _futureArmazon = ConsultaService.getConsultasArmazon(widget.pacienteId);
    _futureContacto = ConsultaService.getConsultasContacto(widget.pacienteId);

    _loadConsultas();
  }

  Future<void> _loadConsultas() async {
    try {
      final armazon = await _futureArmazon;
      final contacto = await _futureContacto;
      setState(() {
        consultasArmazon = armazon;
        consultasContacto = contacto;
        final totalConsultas = armazon.length + contacto.length;
        showEvolutionButton = totalConsultas >= 3;
      });
    } catch (e) {
      setState(() {
        showEvolutionButton = false;
      });
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildPatientCard(patient),
                const SizedBox(height: 24),
                buildActionButtons(),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Consultas Realizadas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<ConsultaCompleta>>(
                  future: _futureArmazon,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final consultasMap =
                          snapshot.data!
                              .map((consulta) => consulta.toJson())
                              .toList()
                            ..sort(
                              (a, b) => DateTime.parse(
                                b['FConsulta'],
                              ).compareTo(DateTime.parse(a['FConsulta'])),
                            );
                      return buildExpansionArmazon(consultasMap);
                    } else {
                      return const Center(
                        child: Text("No se encontraron consultas de armazón"),
                      );
                    }
                  },
                ),
                FutureBuilder<List<ConsultaCompleta>>(
                  future: _futureContacto,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final consultasMap =
                          snapshot.data!
                              .map((consulta) => consulta.toJson())
                              .toList()
                            ..sort(
                              (a, b) => DateTime.parse(
                                b['FConsulta'],
                              ).compareTo(DateTime.parse(a['FConsulta'])),
                            );
                      return buildExpansionContacto(consultasMap);
                    } else {
                      return const Center(
                        child: Text("No se encontraron consultas de contacto"),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildPatientCard(Patient patient) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Información del Paciente",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                buildDetailRow("Cédula", patient.cedula),
                buildDetailRow("Nombre", patient.nombres),
                buildDetailRow("Apellido", patient.apellidos),
                buildDetailRow(
                  "Fecha de Nacimiento",
                  formatFecha(patient.fechaNacimiento.toString()),
                ),
                buildDetailRow("Ocupación", patient.ocupacion),
                buildDetailRow("Teléfono", patient.telefono),
                buildDetailRow("Correo", patient.correo),
                buildDetailRow("Dirección", patient.direccion),
                buildDetailRow("Antecedentes", patient.antecedentes),
                buildDetailRow(
                  "Condiciones Médicas",
                  patient.condicionesMedicas,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value.isNotEmpty ? value : "No especificado"),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        PrimaryButton(
          label: "Editar Datos",
          icon: Icons.edit,
          onPressed:
              () => context.push('/editar_paciente/${widget.pacienteId}'),
        ),
        PrimaryButton(
          label: "Consulta Lentes de Armazón",
          icon: Icons.remove_red_eye,
          onPressed:
              () => context.push(
                '/registrar_consulta/armazon/${widget.pacienteId}',
              ),
        ),
        PrimaryButton(
          label: "Consulta Lentes de Contacto",
          icon: Icons.visibility,
          onPressed:
              () => context.push(
                '/registrar_consulta/contacto/${widget.pacienteId}',
              ),
        ),
        PrimaryButton(
          label: "Reporte de Evolucion Visual",
          icon: Icons.auto_graph,
          onPressed:
              showEvolutionButton
                  ? () => context.push("/evolucion/${widget.pacienteId}")
                  : null,
        ),
      ],
    );
  }

  Widget buildExpansionArmazon(List<Map<String, dynamic>> consultas) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ExpansionTile(
            title: const Text("Consultas de Lentes de Armazón"),
            leading: const Icon(Icons.remove_red_eye),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('OD (SPH/CYL/EJE/ADD)')),
                    DataColumn(label: Text('OI (SPH/CYL/EJE/ADD)')),
                    DataColumn(label: Text('Observaciones')),
                  ],
                  rows:
                      consultas.map((consulta) {
                        final receta = consulta['receta']?['receta_armazones'];
                        return DataRow(
                          onSelectChanged: (_) {
                            final idConsulta = consulta['IDconsulta'];
                            context.push(
                              '/consulta_detalle/${widget.pacienteId}/$idConsulta',
                            );
                          },
                          cells: [
                            DataCell(Text(formatFecha(consulta['FConsulta']))),
                            DataCell(
                              Text(
                                receta != null
                                    ? '${receta['OD_SPH']} / ${receta['OD_CYL']} / ${receta['OD_AXIS']} / ${receta['OD_ADD']}'
                                    : 'No disponible',
                              ),
                            ),
                            DataCell(
                              Text(
                                receta != null
                                    ? '${receta['OI_SPH']} / ${receta['OI_CYL']} / ${receta['OI_AXIS']} / ${receta['OI_ADD']}'
                                    : 'No disponible',
                              ),
                            ),
                            DataCell(
                              Text(
                                consulta['Observaciones'] ??
                                    'Sin observaciones',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpansionContacto(List<Map<String, dynamic>> consultas) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ExpansionTile(
            title: const Text("Consultas de Lentes de Contacto"),
            leading: const Icon(Icons.visibility),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('OD (SPH/CYL/EJE/ADD/BC/DIA)')),
                    DataColumn(label: Text('OI (SPH/CYL/EJE/ADD/BC/DIA)')),
                    DataColumn(label: Text('Marca')),
                    DataColumn(label: Text('Tiempo de Uso')),
                  ],
                  rows:
                      consultas.map((consulta) {
                        final receta = consulta['receta']?['receta_contacto'];
                        return DataRow(
                          onSelectChanged: (_) {
                            final idConsulta = consulta['IDconsulta'];
                            context.push(
                              '/consulta_detalle/${widget.pacienteId}/$idConsulta',
                            );
                          },
                          cells: [
                            DataCell(Text(formatFecha(consulta['FConsulta']))),
                            DataCell(
                              Text(
                                receta != null
                                    ? '${receta['OD_SPH']} / ${receta['OD_CYL']} / ${receta['OD_AXIS']} / ${receta['OD_ADD']} / ${receta['OD_BC']} / ${receta['OD_DIA']}'
                                    : 'No disponible',
                              ),
                            ),
                            DataCell(
                              Text(
                                receta != null
                                    ? '${receta['OI_SPH']} / ${receta['OI_CYL']} / ${receta['OI_AXIS']} / ${receta['OI_ADD']} / ${receta['OI_BC']} / ${receta['OI_DIA']}'
                                    : 'No disponible',
                              ),
                            ),
                            DataCell(Text(receta?['Marca'] ?? 'No disponible')),
                            DataCell(
                              Text(receta?['TiempoUso'] ?? 'No disponible'),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
