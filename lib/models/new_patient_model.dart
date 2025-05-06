class NewPatient {
  final String cedula;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;
  final String ocupacion;
  final String telefono;
  final String correo;
  final String direccion;
  final String antecedentes;
  final String condicionesMedicas;

  NewPatient({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.ocupacion,
    required this.telefono,
    required this.correo,
    required this.direccion,
    required this.antecedentes,
    required this.condicionesMedicas,
  });

  Map<String, dynamic> toJson() {
    return {
      'Cedula': cedula,
      'Nombre': nombres,
      'Apellido': apellidos,
      'FNacimiento': fechaNacimiento.toIso8601String().split('T').first,
      'Ocupacion': ocupacion,
      'Telefono': telefono,
      'Correo': correo,
      'Direccion': direccion,
      'Antecedentes': antecedentes,
      'CondicionesMedicas': condicionesMedicas,
    };
  }
}
