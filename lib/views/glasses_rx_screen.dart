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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {

      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no identificado')),
        );
        return;
      }

      final payload = {
        "consulta": {
          "IDpaciente": widget.pacienteId,
          "IDusuario": userId,
          "FConsulta": DateFormat('yyyy-MM-dd').format(_today),
          "Observaciones": _observacionesController.text.trim(),
          "Motivo": _motivoController.text.trim(),
        },
        "receta": {
          "TipoLente": 1,
          "Fecha": DateFormat('yyyy-MM-dd').format(_today),
        },
        "receta_armazones": {
          "OD_SPH": double.tryParse(_odSphController.text) ?? 0,
          "OD_CYL": double.tryParse(_odCylController.text) ?? 0,
          "OD_AXIS": double.tryParse(_odAxisController.text) ?? 0,
          "OD_ADD": double.tryParse(_odAddController.text) ?? 0,
          "OI_SPH": double.tryParse(_oiSphController.text) ?? 0,
          "OI_CYL": double.tryParse(_oiCylController.text) ?? 0,
          "OI_AXIS": double.tryParse(_oiAxisController.text) ?? 0,
          "OI_ADD": double.tryParse(_oiAddController.text) ?? 0,
          "DIP": double.tryParse(_dipController.text) ?? 0,
        },
        "receta_contacto": null,
        "evolucion": {
          "OD": snellenToDecimal[_selectedODVision] ?? 0,
          "OI": snellenToDecimal[_selectedOIVision] ?? 0,
          "Fecha": DateFormat('yyyy-MM-dd').format(_today),
        },
      };

      try {
        await ConsultaService.registrarConsultaCompleta(payload);

        if (context.mounted) {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder:
                (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/check.json',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 10),
                      const Text('Receta registrada correctamente.'),
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
      } catch (e) {
        if (context.mounted) {
          await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder:
                (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset('assets/fail.json', width: 100, height: 100),
                      const SizedBox(height: 10),
                      Text('Ocurrió un error: $e'),
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
          );
        }
      }
    }
  }

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
                  const Divider(height: 30),
                  const Text(
                    "Ojo Derecho",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildTextField("SPH", _odSphController, isNumber: true),
                  _buildTextField("CYL", _odCylController, isNumber: true),
                  _buildTextField("AXIS", _odAxisController, isNumber: true),
                  _buildTextField("ADD", _odAddController, isNumber: true),
                  _buildDropdown("OD", _selectedODVision, (val) {
                    setState(() => _selectedODVision = val);
                  }),
                  const Divider(height: 30),
                  const Text(
                    "Ojo Izquierdo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildTextField("SPH", _oiSphController, isNumber: true),
                  _buildTextField("CYL", _oiCylController, isNumber: true),
                  _buildTextField("AXIS", _oiAxisController, isNumber: true),
                  _buildTextField("ADD", _oiAddController, isNumber: true),
                  _buildDropdown("OI", _selectedOIVision, (val) {
                    setState(() => _selectedOIVision = val);
                  }),
                  
                  const Divider(height: 30),
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
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
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
            snellenToDecimal.keys.map((e) {
              return DropdownMenuItem(value: e, child: Text(e));
            }).toList(),
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
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }
}
