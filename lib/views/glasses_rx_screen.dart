import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/rx_service.dart';
import '../widgets/custom_button.dart';

class GlassesRxScreen extends StatefulWidget {
  final String pacienteId;

  const GlassesRxScreen({super.key, required this.pacienteId});

  @override
  State<GlassesRxScreen> createState() => _GlassesRxScreenState();
}

class _GlassesRxScreenState extends State<GlassesRxScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final _fechaController = TextEditingController();
  final _motivoController = TextEditingController();
  final _observacionesController = TextEditingController();

  final _odSphController = TextEditingController();
  final _odCylController = TextEditingController();
  final _odAxisController = TextEditingController();
  final _odAddController = TextEditingController();

  final _oiSphController = TextEditingController();
  final _oiCylController = TextEditingController();
  final _oiAxisController = TextEditingController();
  final _oiAddController = TextEditingController();

  final _dipController = TextEditingController();

  String? _selectedODVision;
  String? _selectedOIVision;

  DateTime _today = DateTime.now();

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
    _fechaController.text = DateFormat('yyyy-MM-dd').format(_today);
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _motivoController.dispose();
    _observacionesController.dispose();
    _odSphController.dispose();
    _odCylController.dispose();
    _odAxisController.dispose();
    _odAddController.dispose();
    _oiSphController.dispose();
    _oiCylController.dispose();
    _oiAxisController.dispose();
    _oiAddController.dispose();
    _dipController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.userId;

    if (userId == null) {
      _showSnackBar('Error: Usuario no identificado');
      return;
    }

    final payload = {
      "consulta": {
        "IDpaciente": widget.pacienteId,
        "IDusuario": userId,
        "FConsulta": _fechaController.text,
        "Observaciones": _observacionesController.text.trim(),
        "Motivo": _motivoController.text.trim(),
      },
      "receta": {
        "TipoLente": 1, 
        "Fecha": _fechaController.text
        },
      "receta_armazones": {
        "OD_SPH": _parseDouble(_odSphController.text),
        "OD_CYL": _parseDouble(_odCylController.text),
        "OD_AXIS": _parseDouble(_odAxisController.text),
        "OD_ADD": _parseDouble(_odAddController.text),
        "OI_SPH": _parseDouble(_oiSphController.text),
        "OI_CYL": _parseDouble(_oiCylController.text),
        "OI_AXIS": _parseDouble(_oiAxisController.text),
        "OI_ADD": _parseDouble(_oiAddController.text),
        "DIP": _parseDouble(_dipController.text),
      },
      "receta_contacto": null,
      "evolucion": {
        "OD": snellenToDecimal[_selectedODVision] ?? 0,
        "OI": snellenToDecimal[_selectedOIVision] ?? 0,
        "Fecha": _fechaController.text,
      },
    };

    try {
      await ConsultaService.registrarConsultaCompleta(payload);
      if (!context.mounted) return;
      final success = await _showLottieDialog(
        'check.json',
        'Receta registrada correctamente.',
      );
      if (success) context.pushReplacement('/paciente/${widget.pacienteId}');
    } catch (e) {
      await _showLottieDialog('fail.json', 'Ocurrió un error: $e');
    }
  }

  double _parseDouble(String value) => double.tryParse(value) ?? 0;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _showLottieDialog(String asset, String message) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder:
              (_) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/$asset', width: 100, height: 100),
                    const SizedBox(height: 10),
                    Text(message),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop(true),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Receta de Armazón')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildDatePickerField("Fecha de Consulta", _fechaController),
                  _buildTextField("Motivo de la consulta", _motivoController),
                  _buildTextField("Observaciones", _observacionesController),
                  const SizedBox(height: 20),
                  _buildEyeCard(
                    "Ojo Derecho",
                    _odSphController,
                    _odCylController,
                    _odAxisController,
                    _odAddController,
                    _selectedODVision,
                    (val) => setState(() => _selectedODVision = val),
                  ),
                  _buildEyeCard(
                    "Ojo Izquierdo",
                    _oiSphController,
                    _oiCylController,
                    _oiAxisController,
                    _oiAddController,
                    _selectedOIVision,
                    (val) => setState(() => _selectedOIVision = val),
                  ),
                  _buildTextField("DIP", _dipController, isNumber: true),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    onPressed: _submitForm,
                    icon: Icons.save,
                    label: "Guardar Receta",
                  ),
                  const SizedBox(height: 30),
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
    TextEditingController controller, {
    bool isNumber = false,
    String? fieldType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo es requerido';
          }

          if (isNumber) {
            final num? parsed = num.tryParse(value);
            if (parsed == null) {
              return 'Ingrese un número valido';
            }

            if (fieldType == 'sph' || fieldType == 'cyl') {
              if (parsed < -20 || parsed > 20) {
                return 'El valor no es válido';
              }
            }

            if (fieldType == 'add') {
              if (parsed < 0 || parsed > 3) {
                return 'El valor no es válido';
              }
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: 'Agudeza $label',
          border: const OutlineInputBorder(),
        ),
        items:
            snellenToDecimal.keys
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Selecciona una opción' : null,
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
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
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: _today,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              _today = pickedDate;
              controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
      ),
    );
  }

  Widget _buildEyeCard(
    String title,
    TextEditingController sph,
    TextEditingController cyl,
    TextEditingController axis,
    TextEditingController add,
    String? vision,
    void Function(String?) onVisionChanged,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _buildTextField("SPH", sph, isNumber: true, fieldType: 'sph'),
            _buildTextField("CYL", cyl, isNumber: true, fieldType: 'cyl'),
            _buildTextField("AXIS", axis, isNumber: true, fieldType: 'axis'),
            _buildTextField("ADD", add, isNumber: true, fieldType: 'add'),
            _buildDropdown(
              title.contains("Derecho") ? "OD" : "OI",
              vision,
              onVisionChanged,
            ),
          ],
        ),
      ),
    );
  }
}
