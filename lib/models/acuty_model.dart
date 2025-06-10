class EvolucionVisual {
  final int idRegistro;
  final DateTime fecha;
  final double od;
  final double oi;

  EvolucionVisual({
    required this.idRegistro,
    required this.fecha,
    required this.od,
    required this.oi,
  });

  factory EvolucionVisual.fromJson(Map<String, dynamic> json) {
    return EvolucionVisual(
      idRegistro: json['IDregistro'],
      fecha: DateTime.parse(json['Fecha']),
      od: (json['OD'] as num).toDouble(),
      oi: (json['OI'] as num).toDouble(),
    );
  }
}
