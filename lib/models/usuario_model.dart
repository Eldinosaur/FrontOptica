class Usuario {
  final int id;
  final String nombre;
  final String apellido;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['IDusuario'],
      nombre: json['Nombre'],
      apellido: json['Apellido'],
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}
