class ConsultaCompleta {
  final int idConsulta;
  final int idPaciente;
  final int idUsuario;
  final DateTime fConsulta;
  final String observaciones;
  final String motivo;
  final RecetaBaseOut? receta;

  ConsultaCompleta({
    required this.idConsulta,
    required this.idPaciente,
    required this.idUsuario,
    required this.fConsulta,
    required this.observaciones,
    required this.motivo,
    this.receta,
  });

  factory ConsultaCompleta.fromJson(Map<String, dynamic> json) {
    return ConsultaCompleta(
      idConsulta: json['IDconsulta'],
      idPaciente: json['IDpaciente'],
      idUsuario: json['IDusuario'],
      fConsulta: DateTime.parse(json['FConsulta']),
      observaciones: json['Observaciones'],
      motivo: json['Motivo'],
      receta: json['receta'] != null ? RecetaBaseOut.fromJson(json['receta']) : null,
    );
  }

  // Método para convertir ConsultaCompleta a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'IDconsulta': idConsulta,
      'IDpaciente': idPaciente,
      'IDusuario': idUsuario,
      'FConsulta': fConsulta.toIso8601String(),
      'Observaciones': observaciones,
      'Motivo': motivo,
      'receta': receta?.toJson(),
    };
  }
}

class RecetaBaseOut {
  final int idReceta;
  final int tipoLente;
  final DateTime fecha;
  final RecetaArmazones? recetaArmazones;
  final RecetaContacto? recetaContacto;

  RecetaBaseOut({
    required this.idReceta,
    required this.tipoLente,
    required this.fecha,
    this.recetaArmazones,
    this.recetaContacto,
  });

  factory RecetaBaseOut.fromJson(Map<String, dynamic> json) {
    return RecetaBaseOut(
      idReceta: json['IDreceta'],
      tipoLente: json['TipoLente'],
      fecha: DateTime.parse(json['Fecha']),
      recetaArmazones: json['receta_armazones'] != null
          ? RecetaArmazones.fromJson(json['receta_armazones'])
          : null,
      recetaContacto: json['receta_contacto'] != null
          ? RecetaContacto.fromJson(json['receta_contacto'])
          : null,
    );
  }

  // Método para convertir RecetaBaseOut a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'IDreceta': idReceta,
      'TipoLente': tipoLente,
      'Fecha': fecha.toIso8601String(),
      'receta_armazones': recetaArmazones?.toJson(),
      'receta_contacto': recetaContacto?.toJson(),
    };
  }
}

class RecetaArmazones {
  final double? odSph, odCyl, odAxis, odAdd;
  final double? oiSph, oiCyl, oiAxis, oiAdd;
  final double? dip;

  RecetaArmazones({
    this.odSph,
    this.odCyl,
    this.odAxis,
    this.odAdd,
    this.oiSph,
    this.oiCyl,
    this.oiAxis,
    this.oiAdd,
    this.dip,
  });

  factory RecetaArmazones.fromJson(Map<String, dynamic> json) {
    return RecetaArmazones(
      odSph: (json['OD_SPH'] as num?)?.toDouble(),
      odCyl: (json['OD_CYL'] as num?)?.toDouble(),
      odAxis: (json['OD_AXIS'] as num?)?.toDouble(),
      odAdd: (json['OD_ADD'] as num?)?.toDouble(),
      oiSph: (json['OI_SPH'] as num?)?.toDouble(),
      oiCyl: (json['OI_CYL'] as num?)?.toDouble(),
      oiAxis: (json['OI_AXIS'] as num?)?.toDouble(),
      oiAdd: (json['OI_ADD'] as num?)?.toDouble(),
      dip: (json['DIP'] as num?)?.toDouble(),
    );
  }

  // Método para convertir RecetaArmazones a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'OD_SPH': odSph,
      'OD_CYL': odCyl,
      'OD_AXIS': odAxis,
      'OD_ADD': odAdd,
      'OI_SPH': oiSph,
      'OI_CYL': oiCyl,
      'OI_AXIS': oiAxis,
      'OI_ADD': oiAdd,
      'DIP': dip,
    };
  }
}

class RecetaContacto {
  final double? odSph, odCyl, odAxis, odAdd, odBc, odDia;
  final double? oiSph, oiCyl, oiAxis, oiAdd, oiBc, oiDia;
  final String? marcaLente;
  final String? tiempoUso;

  RecetaContacto({
    this.odSph,
    this.odCyl,
    this.odAxis,
    this.odAdd,
    this.odBc,
    this.odDia,
    this.oiSph,
    this.oiCyl,
    this.oiAxis,
    this.oiAdd,
    this.oiBc,
    this.oiDia,
    this.marcaLente,
    this.tiempoUso,
  });

  factory RecetaContacto.fromJson(Map<String, dynamic> json) {
    return RecetaContacto(
      odSph: (json['OD_SPH'] as num?)?.toDouble(),
      odCyl: (json['OD_CYL'] as num?)?.toDouble(),
      odAxis: (json['OD_AXIS'] as num?)?.toDouble(),
      odAdd: (json['OD_ADD'] as num?)?.toDouble(),
      odBc: (json['OD_BC'] as num?)?.toDouble(),
      odDia: (json['OD_DIA'] as num?)?.toDouble(),
      oiSph: (json['OI_SPH'] as num?)?.toDouble(),
      oiCyl: (json['OI_CYL'] as num?)?.toDouble(),
      oiAxis: (json['OI_AXIS'] as num?)?.toDouble(),
      oiAdd: (json['OI_ADD'] as num?)?.toDouble(),
      oiBc: (json['OI_BC'] as num?)?.toDouble(),
      oiDia: (json['OI_DIA'] as num?)?.toDouble(),
      marcaLente: json['MarcaLente'],
      tiempoUso: json['TiempoUso'],
    );
  }

  // Método para convertir RecetaContacto a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'OD_SPH': odSph,
      'OD_CYL': odCyl,
      'OD_AXIS': odAxis,
      'OD_ADD': odAdd,
      'OD_BC': odBc,
      'OD_DIA': odDia,
      'OI_SPH': oiSph,
      'OI_CYL': oiCyl,
      'OI_AXIS': oiAxis,
      'OI_ADD': oiAdd,
      'OI_BC': oiBc,
      'OI_DIA': oiDia,
      'MarcaLente': marcaLente,
      'TiempoUso': tiempoUso,
    };
  }
}
