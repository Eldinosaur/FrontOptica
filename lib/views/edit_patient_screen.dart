import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../services/patient_service.dart';
import '../widgets/custom_button.dart';

class EditPatientScreen extends StatefulWidget {
  final String pacienteId;
  const EditPatientScreen({super.key, required this.pacienteId});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
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
  bool isLoading = true;

  String? _validateOnlyLetters(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    return regex.hasMatch(value) ? null : 'Solo letras y espacios';
  }

  String? _validateOnlyNumbers(String? value, int length) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(value)) return 'Solo números';
    if (value.length != length) return 'Debe tener $length dígitos';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value) ? null : 'Correo no válido';
  }

  String? _validateAddress(String? value) {
  if (value == null || value.isEmpty) return 'Campo requerido';
  final regex = RegExp(r'^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\-]+$');
  return regex.hasMatch(value) ? null : 'Caracteres inválidos en la dirección';
}


  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      final patient = await PatientService.getPatientById(widget.pacienteId);

      _cedulaController.text = patient.cedula;
      _nombreController.text = patient.nombres;
      _apellidoController.text = patient.apellidos;
      _selectedDate = patient.fechaNacimiento;
      _fnacimientoController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(patient.fechaNacimiento);
      _ocupacionController.text = patient.ocupacion;
      _telefonoController.text = patient.telefono;
      _correoController.text = patient.correo;
      _direccionController.text = patient.direccion;
      _antecedentesController.text = patient.antecedentes;
      _condicionesController.text = patient.condicionesMedicas;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al cargar paciente: $e")));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    final data = {
      "Cedula": _cedulaController.text.trim(),
      "Nombre": _nombreController.text.trim(),
      "Apellido": _apellidoController.text.trim(),
      "FNacimiento": DateFormat('yyyy-MM-dd').format(_selectedDate!),
      "Ocupacion": _ocupacionController.text.trim(),
      "Telefono": _telefonoController.text.trim(),
      "Correo": _correoController.text.trim(),
      "Direccion": _direccionController.text.trim(),
      "Antecedentes": _antecedentesController.text.trim(),
      "CondicionesMedicas": _condicionesController.text.trim(),
    };

    setState(() => isLoading = true);

    try {
      await PatientService.updatePatient(widget.pacienteId, data);

      if (context.mounted) {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: true, // permite cerrar tocando fuera
          builder:
              (_) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/check.json', width: 100, height: 100),
                    const SizedBox(height: 10),
                    const Text('Paciente actualizado correctamente.'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(true);
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
        );

        // Si el usuario cerró tocando fuera o aceptó
        if (result != false) {
          context.pushReplacement('/paciente/${widget.pacienteId}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder:
              (_) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/fail.json', width: 100, height: 100),
                    const SizedBox(height: 10),
                    Text('Error al actualizar paciente: $e'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(true);
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
        );

        if (result != false) {
          context.pushReplacement('/paciente/${widget.pacienteId}');
        }
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _fnacimientoController.text = DateFormat('dd-MM-yyyy').format(picked);
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
      appBar: AppBar(
        title: const Text('Editar Paciente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/paciente/${widget.pacienteId}'),
        ),
      ),
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
                          _buildTextField(
                            "Cédula",
                            _cedulaController,
                            10,
                            TextInputType.number,
                            (val) => _validateOnlyNumbers(val, 10),
                          ),
                          _buildTextField(
                            "Nombre",
                            _nombreController,
                            50,
                            TextInputType.text,
                            (val) => _validateOnlyLetters(val),
                          ),
                          _buildTextField(
                            "Apellido",
                            _apellidoController,
                            50,
                            TextInputType.text,
                            (val) => _validateOnlyLetters(val),
                          ),
                          _buildDateField(
                            "Fecha de Nacimiento",
                            _fnacimientoController,
                          ),
                          _buildTextField(
                            "Ocupación",
                            _ocupacionController,
                            100,
                            TextInputType.text,
                            (val) => _validateOnlyLetters(val),
                          ),
                          _buildTextField(
                            "Teléfono",
                            _telefonoController,
                            10,
                            TextInputType.number,
                            (val) => _validateOnlyNumbers(val, 10),
                          ),
                          _buildTextField(
                            "Correo",
                            _correoController,
                            100,
                            TextInputType.emailAddress,
                            (val) => _validateEmail(val),
                          ),
                          _buildTextField(
                            "Dirección",
                            _direccionController,
                            100,
                            TextInputType.text,
                            (val) => _validateAddress(val),
                          ),
                          _buildTextField(
                            "Antecedentes",
                            _antecedentesController,
                            100,
                            TextInputType.text,
                            (val) => _validateOnlyLetters(val),
                          ),
                          _buildTextField(
                            "Condiciones Médicas",
                            _condicionesController,
                            100,
                            TextInputType.text,
                            (val) => _validateOnlyLetters(val),
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            onPressed: _submit,
                            label: 'Actualizar Datos',
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? customValidator,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            customValidator ??
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
