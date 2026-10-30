/// Lado del cuadro de Patrimonio: lo que está a favor y lo que se debe.
enum LadoPatrimonio {
  haber,
  debe;

  static LadoPatrimonio fromJson(String v) =>
      v == 'debe' ? LadoPatrimonio.debe : LadoPatrimonio.haber;

  /// Etiqueta de la columna, tal como se lee en el cuadro y en el PDF.
  String get titulo => this == LadoPatrimonio.haber ? 'HABER' : 'DEBE';

  /// Etiqueta del total de la columna.
  String get totalLabel =>
      this == LadoPatrimonio.haber ? 'TOTAL A FAVOR' : 'TOTAL DEUDAS';
}

/// Una fila del cuadro: un concepto escrito a mano y su monto.
///
/// Hand-written (sin freezed), igual que `Precio`: PostgREST puede devolver
/// `numeric` como número o como string y el parser cubre los dos casos.
class PatrimonioItem {
  const PatrimonioItem({
    required this.lado,
    required this.orden,
    required this.concepto,
    required this.monto,
  });

  final LadoPatrimonio lado;

  /// Posición de la fila dentro de su columna. El cuadro se lee renglón
  /// contra renglón, así que se guarda el orden en el que se escribió.
  final int orden;
  final String concepto;
  final double monto;

  factory PatrimonioItem.fromJson(Map<String, dynamic> json) => PatrimonioItem(
        lado: LadoPatrimonio.fromJson(json['lado'] as String),
        orden: (json['orden'] as num?)?.toInt() ?? 0,
        concepto: (json['concepto'] as String?) ?? '',
        monto: _toDouble(json['monto']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'lado': lado.name,
        'orden': orden,
        'concepto': concepto,
        'monto': monto,
      };
}

/// La foto del patrimonio a una fecha: las dos columnas y sus totales.
class Patrimonio {
  const Patrimonio({
    required this.id,
    required this.fecha,
    required this.items,
  });

  final String id;
  final DateTime fecha;
  final List<PatrimonioItem> items;

  List<PatrimonioItem> get haber => _lado(LadoPatrimonio.haber);
  List<PatrimonioItem> get debe => _lado(LadoPatrimonio.debe);

  double get totalHaber => totalDe(haber);
  double get totalDebe => totalDe(debe);

  /// Lo que queda del negocio a la fecha. Negativo = se debe más de lo que
  /// hay (es el caso normal del cuadro cuando hay créditos abiertos).
  double get saldo => totalHaber - totalDebe;

  List<PatrimonioItem> _lado(LadoPatrimonio lado) =>
      items.where((i) => i.lado == lado).toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));

  factory Patrimonio.fromJson(Map<String, dynamic> json) {
    final filas = (json['patrimonio_items'] as List<dynamic>?) ?? const [];
    return Patrimonio(
      id: json['id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      items: [
        for (final f in filas)
          PatrimonioItem.fromJson(f as Map<String, dynamic>),
      ],
    );
  }
}

/// Suma de los montos de una columna. Única cuenta que hace el módulo.
double totalDe(Iterable<PatrimonioItem> items) =>
    items.fold<double>(0, (s, i) => s + i.monto);

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
