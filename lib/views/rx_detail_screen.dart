import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../models/rx_model.dart';
import '../services/patient_service.dart';
import '../services/rx_service.dart';

String formatFecha(String fecha) {
  try {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(fecha));
  } catch (_) {
    return fecha;
  }
}

class RxDetailScreen extends StatefulWidget {
  final String pacienteId;
  final String consultaId;

  const RxDetailScreen({
    required this.pacienteId,
    required this.consultaId,
    super.key,
  });

  @override
  State<RxDetailScreen> createState() => _RxDetailScreenState();
}

class _RxDetailScreenState extends State<RxDetailScreen> {
  late Future<Patient> _futurePatient;
  late Future<ConsultaCompleta> _futureConsulta;

  @override
  void initState() {
    super.initState();
    _futurePatient = PatientService.getPatientById(widget.pacienteId);
    _futureConsulta = ConsultaService.getConsultaId(widget.consultaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Consulta"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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

          return FutureBuilder<ConsultaCompleta>(
            future: _futureConsulta,
            builder: (context, consultaSnapshot) {
              if (consultaSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (consultaSnapshot.hasError) {
                return Center(child: Text("Error: ${consultaSnapshot.error}"));
              } else if (!consultaSnapshot.hasData) {
                return const Center(child: Text("Consulta no encontrada"));
              }

              final consulta = consultaSnapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPatientCard(patient),
                    const SizedBox(height: 24),
                    buildConsultaDetailCard(consulta),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildPatientCard(Patient patient) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            buildDetailRow("Condiciones Médicas", patient.condicionesMedicas),
          ],
        ),
      ),
    );
  }

  Widget buildConsultaDetailCard(ConsultaCompleta consulta) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Detalle de la Consulta",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildDetailRow("Motivo", consulta.motivo),
            buildDetailRow("Observaciones", consulta.observaciones),
            buildDetailRow(
              "Fecha de Consulta",
              formatFecha(consulta.fConsulta.toString()),
            ),
            if (consulta.receta != null) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Receta",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              buildRecetaCard(consulta.receta!),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildRecetaCard(RecetaBaseOut receta) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildDetailRow(
              "Tipo de Lente",
              receta.tipoLente == 1 ? "Armazón" : "Contacto",
            ),
            buildDetailRow(
              "Fecha de Receta",
              formatFecha(receta.fecha.toString()),
            ),
            if (receta.recetaArmazones != null) ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Receta de Armazón",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              buildDetailRow(
                "OD SPH",
                receta.recetaArmazones!.odSph.toString(),
              ),
              buildDetailRow(
                "OD CYL",
                receta.recetaArmazones!.odCyl.toString(),
              ),
              buildDetailRow(
                "OD AXIS",
                receta.recetaArmazones!.odAxis.toString(),
              ),
              buildDetailRow(
                "OD ADD",
                receta.recetaArmazones!.odAdd.toString(),
              ),
              buildDetailRow(
                "OI SPH",
                receta.recetaArmazones!.oiSph.toString(),
              ),
              buildDetailRow(
                "OI CYL",
                receta.recetaArmazones!.oiCyl.toString(),
              ),
              buildDetailRow(
                "OI AXIS",
                receta.recetaArmazones!.oiAxis.toString(),
              ),
              buildDetailRow(
                "OI ADD",
                receta.recetaArmazones!.oiAdd.toString(),
              ),
              buildDetailRow("DIP", receta.recetaArmazones!.dip.toString()),
            ],
            if (receta.recetaContacto != null) ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Receta de Contacto",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              buildDetailRow("OD SPH", receta.recetaContacto!.odSph.toString()),
              buildDetailRow("OD CYL", receta.recetaContacto!.odCyl.toString()),
              buildDetailRow(
                "OD AXIS",
                receta.recetaContacto!.odAxis.toString(),
              ),
              buildDetailRow("OD ADD", receta.recetaContacto!.odAdd.toString()),
              buildDetailRow("OD BC", receta.recetaContacto!.odBc.toString()),
              buildDetailRow("OD DIA", receta.recetaContacto!.odDia.toString()),
              buildDetailRow("OI SPH", receta.recetaContacto!.oiSph.toString()),
              buildDetailRow("OI CYL", receta.recetaContacto!.oiCyl.toString()),
              buildDetailRow(
                "OI AXIS",
                receta.recetaContacto!.oiAxis.toString(),
              ),
              buildDetailRow("OI ADD", receta.recetaContacto!.oiAdd.toString()),
              buildDetailRow("OI BC", receta.recetaContacto!.oiBc.toString()),
              buildDetailRow("OI DIA", receta.recetaContacto!.oiDia.toString()),
              buildDetailRow(
                "Marca Lente",
                receta.recetaContacto!.marcaLente ?? "N/A",
              ),
              buildDetailRow(
                "Tiempo de Uso",
                receta.recetaContacto!.tiempoUso ?? "N/A",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
