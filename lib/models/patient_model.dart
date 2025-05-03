class Patient {
  final int id;
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
  final DateTime? ultimaConsulta;

  Patient({
    required this.id,
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
    this.ultimaConsulta,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['IDpaciente'],
      cedula: json['Cedula'],
      nombres: json['Nombre'],
      apellidos: json['Apellido'],
      fechaNacimiento: DateTime.parse(json['FNacimiento']),
      ocupacion: json['Ocupacion'],
      telefono: json['Telefono'],
      correo: json['Correo'],
      direccion: json['Direccion'],
      antecedentes: json['Antecedentes'],
      condicionesMedicas: json['CondicionesMedicas'],
      ultimaConsulta:
          json['ultima_consulta']?['ultima_consulta_fecha'] != null
              ? DateTime.parse(json['ultima_consulta']['ultima_consulta_fecha'])
              : null,
    );
  }
}
