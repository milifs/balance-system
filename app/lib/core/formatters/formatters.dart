import 'package:intl/intl.dart';

/// Formateadores localizados es_AR: miles con punto, decimales con coma.
/// Ej: `$ 1.382.260,65`, `108,795 kg`, `19,74 %`.
class Fmt {
  const Fmt._();

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_AR',
    symbol: r'$ ',
    decimalDigits: 2,
  );

  static final NumberFormat _kg = NumberFormat('#,##0.000', 'es_AR');
  static final NumberFormat _pct = NumberFormat('#,##0.00', 'es_AR');
  static final NumberFormat _entero = NumberFormat('#,##0', 'es_AR');
  static final DateFormat _fecha = DateFormat('dd/MM/yyyy', 'es_AR');

  static String moneda(num? v) => _moneda.format(v ?? 0);
  static String kg(num? v) => '${_kg.format(v ?? 0)} kg';
  static String pct(num? v) => '${_pct.format(v ?? 0)} %';
  static String entero(num? v) => _entero.format(v ?? 0);
  static String fecha(DateTime? d) => d == null ? '—' : _fecha.format(d);
}
