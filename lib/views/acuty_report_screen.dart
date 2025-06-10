import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/patient_model.dart';
import '../services/patient_service.dart';
import '../models/acuty_model.dart';
import '../services/acuty_service.dart';

String formatFecha(String fecha) {
  try {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(fecha));
  } catch (_) {
    return fecha;
  }
}

class VisualEvolutionScreen extends StatefulWidget {
  final String pacienteId;

  const VisualEvolutionScreen({super.key, required this.pacienteId});

  @override
  State<VisualEvolutionScreen> createState() => _VisualEvolutionScreenState();
}

class _VisualEvolutionScreenState extends State<VisualEvolutionScreen> {
  bool isLoading = true;
  List<EvolucionVisual> evoluciones = [];
  late Future<Patient> _futurePatient;

  final Map<String, double> snellenToDecimal = {
    '20/10': 2.0,
    '20/15': 1.5,
    '20/20': 1.0,
    '20/25': 0.8,
    '20/30': 0.6,
    '20/40': 0.5,
    '20/50': 0.4,
    '20/60': 0.3,
    '20/80': 0.25,
    '20/100': 0.2,
    '20/200': 0.1,
  };

  @override
  void initState() {
    super.initState();
    _fetchEvolucion();
    _futurePatient = PatientService.getPatientById(widget.pacienteId);
  }

  Future<void> _fetchEvolucion() async {
    try {
      final data = await EvolucionService.getEvolucionPorPaciente(widget.pacienteId);
      setState(() {
        evoluciones = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar evolución: $e');
      setState(() => isLoading = false);
    }
  }

  List<FlSpot> _buildSpots({required bool isOD}) {
    return evoluciones.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = isOD ? entry.value.od : entry.value.oi;
      return FlSpot(index, value);
    }).toList();
  }

  List<String> _buildLabels() {
    return evoluciones.map((e) => DateFormat('dd/MM').format(e.fecha)).toList();
  }

  String _snellenFromDecimal(double value) {
    final sortedEntries = snellenToDecimal.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      if (value >= entry.value) return entry.key;
    }
    return '20/200';
  }

  Widget _buildPatientCard(Patient patient) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Información del Paciente",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDetailRow("Cédula", patient.cedula),
                _buildDetailRow("Nombre", patient.nombres),
                _buildDetailRow("Apellido", patient.apellidos),
                _buildDetailRow("Fecha de Nacimiento", formatFecha(patient.fechaNacimiento.toIso8601String())),
                _buildDetailRow("Ocupación", patient.ocupacion),
                _buildDetailRow("Teléfono", patient.telefono),
                _buildDetailRow("Correo", patient.correo),
                _buildDetailRow("Dirección", patient.direccion),
                _buildDetailRow("Antecedentes", patient.antecedentes),
                _buildDetailRow("Condiciones Médicas", patient.condicionesMedicas),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calcula la altura dinámica del gráfico: 60 por cada dato, mínimo 200 y máximo 400
    final double chartHeight = (evoluciones.length * 60).clamp(200, 400).toDouble();

    // Define un ancho para el gráfico menor que el total para no ocupar todo el ancho de pantalla (p.ej. 90%)
    final double chartWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(title: const Text('Evolución Visual')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Patient>(
              future: _futurePatient,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar paciente: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Paciente no encontrado'));
                }

                final patient = snapshot.data!;

                if (evoluciones.isEmpty) {
                  return const Center(child: Text('No hay evolución registrada.'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPatientCard(patient),
                      const SizedBox(height: 16),
                      const Text(
                        'Evolución Visual - Escala Snellen',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Contenedor con scroll horizontal y vertical para el gráfico
                      SizedBox(
                        height: chartHeight,
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: chartWidth,
                              height: chartHeight,
                              child: LineChart(
                                LineChartData(
                                  minY: 0.1,
                                  maxY: 2.0,
                                  titlesData: FlTitlesData(
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 0.1,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, _) {
                                          if (value < 0.1 || value > 2.0) return const SizedBox();
                                          return Text(_snellenFromDecimal(value), style: const TextStyle(fontSize: 10));
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, _) {
                                          final index = value.toInt();
                                          final labels = _buildLabels();
                                          return index >= 0 && index < labels.length
                                              ? Text(labels[index], style: const TextStyle(fontSize: 10))
                                              : const SizedBox();
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    horizontalInterval: 0.1,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.grey.withOpacity(0.2),
                                      strokeWidth: 1,
                                    ),
                                    getDrawingVerticalLine: (value) => FlLine(
                                      color: Colors.grey.withOpacity(0.2),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: const Border(
                                      left: BorderSide(color: Colors.black, width: 1),
                                      bottom: BorderSide(color: Colors.black, width: 1),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _buildSpots(isOD: true),
                                      isCurved: true,
                                      color: Colors.blue,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      belowBarData: BarAreaData(show: false),
                                      dotData: FlDotData(show: true),
                                    ),
                                    LineChartBarData(
                                      spots: _buildSpots(isOD: false),
                                      isCurved: true,
                                      color: Colors.green,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      belowBarData: BarAreaData(show: false),
                                      dotData: FlDotData(show: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.remove, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Ojo Derecho'),
                              SizedBox(width: 20),
                              Icon(Icons.remove, color: Colors.green),
                              SizedBox(width: 4),
                              Text('Ojo Izquierdo'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
