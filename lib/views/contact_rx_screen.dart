import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../services/rx_service.dart';
import '../widgets/custom_button.dart';

class ContactRxScreen extends StatefulWidget {
  final String pacienteId;

  const ContactRxScreen({super.key, required this.pacienteId});

  @override
  State<ContactRxScreen> createState() => _ContactRxScreenState();
}

class _ContactRxScreenState extends State<ContactRxScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final TextEditingController _observacionesController = TextEditingController();

  // OD
  final _odSph = TextEditingController();
  final _odCyl = TextEditingController();
  final _odAxis = TextEditingController();
  final _odBc = TextEditingController();
  final _odDia = TextEditingController();
  final _odMarca = TextEditingController();

  // OI
  final _oiSph = TextEditingController();
  final _oiCyl = TextEditingController();
  final _oiAxis = TextEditingController();
  final _oiBc = TextEditingController();
  final _oiDia = TextEditingController();
  final _oiMarca = TextEditingController();

  @override
  void dispose() {
    _fechaController.dispose();
    _observacionesController.dispose();
    _odSph.dispose();
    _odCyl.dispose();
    _odAxis.dispose();
    _odBc.dispose();
    _odDia.dispose();
    _odMarca.dispose();
    _oiSph.dispose();
    _oiCyl.dispose();
    _oiAxis.dispose();
    _oiBc.dispose();
    _oiDia.dispose();
    _oiMarca.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final receta = {
        'pacienteId': widget.pacienteId,
        'fecha': _fechaController.text,
        'observaciones': _observacionesController.text,
        'receta_contacto': {
          'OD': {
            'SPH': _odSph.text,
            'CYL': _odCyl.text,
            'AXIS': _odAxis.text,
            'BC': _odBc.text,
            'DIA': _odDia.text,
            'MARCA': _odMarca.text,
          },
          'OI': {
            'SPH': _oiSph.text,
            'CYL': _oiCyl.text,
            'AXIS': _oiAxis.text,
            'BC': _oiBc.text,
            'DIA': _oiDia.text,
            'MARCA': _oiMarca.text,
          },
        }
      };

      // Aquí llamas al servicio de guardado
      print("Receta de contacto: $receta");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receta de contacto guardada")),
      );

      Navigator.pop(context);
    }
  }

  Widget buildEyeForm(String title, TextEditingController sph, cyl, axis, bc, dia, marca) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(child: TextFormField(controller: sph, decoration: const InputDecoration(labelText: 'SPH'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: cyl, decoration: const InputDecoration(labelText: 'CYL'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: axis, decoration: const InputDecoration(labelText: 'EJE'))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextFormField(controller: bc, decoration: const InputDecoration(labelText: 'BC'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: dia, decoration: const InputDecoration(labelText: 'DIA'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: marca, decoration: const InputDecoration(labelText: 'Marca'))),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Receta - Lentes de Contacto")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: 'Fecha de Receta'),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _fechaController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              buildEyeForm("OD (Ojo Derecho)", _odSph, _odCyl, _odAxis, _odBc, _odDia, _odMarca),
              buildEyeForm("OI (Ojo Izquierdo)", _oiSph, _oiCyl, _oiAxis, _oiBc, _oiDia, _oiMarca),
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(labelText: 'Observaciones'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _submitForm,
                icon: Icons.save,
                label: "Guardar Receta",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
