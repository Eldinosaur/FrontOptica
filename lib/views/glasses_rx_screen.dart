import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../services/rx_service.dart';
import '../widgets/custom_button.dart';

class GlassesRxScreen extends StatefulWidget{
  final String pacienteId;

  const GlassesRxScreen({super.key, required this.pacienteId});

  @override
  State<GlassesRxScreen> createState() => _GlassesRxScreenState();
}

class _GlassesRxScreenState extends State<GlassesRxScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );
  final TextEditingController _observacionesController = TextEditingController();

  // Receta OD
  final TextEditingController _odSph = TextEditingController();
  final TextEditingController _odCyl = TextEditingController();
  final TextEditingController _odAxis = TextEditingController();
  final TextEditingController _odAdd = TextEditingController();

  // Receta OI
  final TextEditingController _oiSph = TextEditingController();
  final TextEditingController _oiCyl = TextEditingController();
  final TextEditingController _oiAxis = TextEditingController();
  final TextEditingController _oiAdd = TextEditingController();

  @override
  void dispose() {
    _fechaController.dispose();
    _observacionesController.dispose();
    _odSph.dispose();
    _odCyl.dispose();
    _odAxis.dispose();
    _odAdd.dispose();
    _oiSph.dispose();
    _oiCyl.dispose();
    _oiAxis.dispose();
    _oiAdd.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final consulta = {
        'pacienteId': widget.pacienteId,
        'fecha': _fechaController.text,
        'observaciones': _observacionesController.text,
        'receta_armazon': {
          'OD_SPH': _odSph.text,
          'OD_CYL': _odCyl.text,
          'OD_AXIS': _odAxis.text,
          'OD_ADD': _odAdd.text,
          'OI_SPH': _oiSph.text,
          'OI_CYL': _oiCyl.text,
          'OI_AXIS': _oiAxis.text,
          'OI_ADD': _oiAdd.text,
        }
      };

      // Aquí deberías llamar al servicio para guardar la consulta
      print("Consulta registrada: $consulta");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Consulta registrada correctamente")),
      );

      Navigator.pop(context); // O redirigir a otra vista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Consulta - Armazón"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: 'Fecha de Consulta'),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _fechaController.text = DateFormat('dd-MM-yyyy').format(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text("Receta - OD", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _odSph, decoration: const InputDecoration(labelText: 'SPH'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _odCyl, decoration: const InputDecoration(labelText: 'CYL'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _odAxis, decoration: const InputDecoration(labelText: 'EJE'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _odAdd, decoration: const InputDecoration(labelText: 'ADD'))),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Receta - OI", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _oiSph, decoration: const InputDecoration(labelText: 'SPH'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _oiCyl, decoration: const InputDecoration(labelText: 'CYL'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _oiAxis, decoration: const InputDecoration(labelText: 'EJE'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _oiAdd, decoration: const InputDecoration(labelText: 'ADD'))),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(labelText: 'Observaciones'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _submitForm,
                icon: Icons.save,
                label: "Guardar Consulta",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
