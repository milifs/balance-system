/// Precio de un corte: guarda los últimos 3 valores (actual, último, penúltimo).
///
/// Hand-written (sin freezed): PostgREST puede devolver `numeric`/`decimal`
/// como número o como string; el parser cubre ambos casos para no perder plata.
class Precio {
  const Precio({
    required this.corteId,
    this.actual,
    this.ultimo,
    this.penultimo,
  });

  final String corteId;
  final double? actual;
  final double? ultimo;
  final double? penultimo;

  factory Precio.fromJson(Map<String, dynamic> json) => Precio(
        corteId: json['corte_id'] as String,
        actual: _toDouble(json['precio_actual']),
        ultimo: _toDouble(json['precio_ultimo']),
        penultimo: _toDouble(json['precio_penultimo']),
      );
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
