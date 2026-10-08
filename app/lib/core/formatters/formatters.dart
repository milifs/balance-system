import 'package:intl/intl.dart';

/// Formateadores localizados es_AR: miles con punto, decimales con coma.
/// Los montos se muestran como enteros (sin decimales). Los porcentajes
/// muestran hasta 2 decimales pero recortan los ceros sobrantes (ej. la
/// retención 6,2 % se ve con decimal, pero 12 % queda entero). Los kilos
/// conservan decimales porque hay cortes de menos de 1 kg.
/// El símbolo `$` va al final sin espacio sobrante para que los montos
/// alineados a la derecha queden a ras del borde de la columna.
/// Ej: `1.382.261 $`, `108,795 kg`, `6,2 %`, `12 %`.
class Fmt {
  const Fmt._();

  static final NumberFormat _kg = NumberFormat('#,##0.000', 'es_AR');
  static final NumberFormat _pct = NumberFormat('#,##0.##', 'es_AR');
  static final NumberFormat _entero = NumberFormat('#,##0', 'es_AR');
  static final DateFormat _fecha = DateFormat('dd/MM/yyyy', 'es_AR');
  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm', 'es_AR');

  static String moneda(num? v) => '${_entero.format(v ?? 0)} \$';
  static String kg(num? v) => '${_kg.format(v ?? 0)} kg';
  static String pct(num? v) => '${_pct.format(v ?? 0)} %';
  static String entero(num? v) => _entero.format(v ?? 0);
  static String fecha(DateTime? d) => d == null ? '—' : _fecha.format(d);
  static String fechaHora(DateTime? d) =>
      d == null ? '—' : _fechaHora.format(d);
}
