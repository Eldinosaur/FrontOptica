import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../services/patient_service.dart';
import '../widgets/custom_button.dart'; // Tu botón personalizado

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _fnacimientoController = TextEditingController();
  final _ocupacionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _antecedentesController = TextEditingController();
  final _condicionesController = TextEditingController();
  DateTime? _selectedDate;
  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    final nuevoPaciente = {
      'Cedula': _cedulaController.text.trim(),
      'Nombre': _nombreController.text.trim(),
      'Apellido': _apellidoController.text.trim(),
      'FNacimiento': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'Ocupacion': _ocupacionController.text.trim(),
      'Telefono': _telefonoController.text.trim(),
      'Correo': _correoController.text.trim(),
      'Direccion': _direccionController.text.trim(),
      'Antecedentes': _antecedentesController.text.trim(),
      'CondicionesMedicas': _condicionesController.text.trim(),
    };

    setState(() => isLoading = true);

    try {
      final response = await PatientService.createPatient(nuevoPaciente);
      final pacienteId = response['IDpaciente'];

      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/check.json', width: 100, height: 100),
                    const SizedBox(height: 10),
                    const Text('Paciente agregado exitosamente.'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pop(); // cerrar modal principal
                      Future.delayed(Duration(milliseconds: 100), () {
                        if (context.mounted) {
                          context.go(
                            '/paciente/$pacienteId',
                          ); // navegación segura después de cerrar el diálogo
                        }
                      });
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/fail.json', width: 100, height: 100),
                    const SizedBox(height: 10),
                    Text('Error al agregar paciente: $e'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _fnacimientoController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _fnacimientoController.dispose();
    _ocupacionController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _antecedentesController.dispose();
    _condicionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Paciente')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField("Cédula", _cedulaController),
                          _buildTextField("Nombre", _nombreController),
                          _buildTextField("Apellido", _apellidoController),
                          _buildDateField(
                            "Fecha de Nacimiento",
                            _fnacimientoController,
                          ),
                          _buildTextField("Ocupación", _ocupacionController),
                          _buildTextField("Teléfono", _telefonoController),
                          _buildTextField("Correo", _correoController),
                          _buildTextField("Dirección", _direccionController),
                          _buildTextField(
                            "Antecedentes",
                            _antecedentesController,
                          ),
                          _buildTextField(
                            "Condiciones Médicas",
                            _condicionesController,
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            onPressed: _submit,
                            label: 'Guardar Paciente',
                            icon: Icons.save,
                          ),
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => _selectDate(context),
        validator:
            (_) => _selectedDate == null ? 'Selecciona una fecha válida' : null,
      ),
    );
  }
}
