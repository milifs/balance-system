import '../../../core/formatters/formatters.dart';

/// Merma máxima que se considera normal en un despiece, en %. Por encima de
/// esto el cuadro avisa: no es que esté prohibido, es que a esa altura lo más
/// probable es que haya un KGR mal cargado (un 10 donde iba un 100).
const double mermaMaximaPct = 15;

/// Merma del despiece: los kilos de la pieza base que no quedaron repartidos
/// entre los cortes (hueso, grasa, recorte). Null si la categoría no tiene
/// cargados los kilos de su pieza base.
double? mermaKg({required double kgRindeTotal, required double? piezaBaseKg}) =>
    piezaBaseKg == null ? null : piezaBaseKg - kgRindeTotal;

/// La merma como % de la pieza base. Null si no hay pieza base o está en 0.
double? mermaPct({required double kgRindeTotal, required double? piezaBaseKg}) {
  if (piezaBaseKg == null || piezaBaseKg == 0) return null;
  return (piezaBaseKg - kgRindeTotal) / piezaBaseKg * 100;
}

/// Aviso para el pie del cuadro de rinde cuando los KGR no cierran contra la
/// pieza base, o null si no hay nada que decir.
///
/// El rinde compara el ingreso del despiece contra el costo de la pieza
/// entera, así que si los KGR no corresponden a esa pieza el % de rinde no
/// significa nada, y nada lo delataba.
String? avisoDeKgr({
  required double kgRindeTotal,
  required double? piezaBaseKg,
}) {
  if (piezaBaseKg == null || piezaBaseKg == 0) return null;
  if (kgRindeTotal == 0) return null;

  if (kgRindeTotal > piezaBaseKg) {
    return 'Los cortes suman ${Fmt.kg(kgRindeTotal)}, más que los '
        '${Fmt.kg(piezaBaseKg)} de la pieza base. El % de rinde no cierra.';
  }

  final merma = mermaPct(kgRindeTotal: kgRindeTotal, piezaBaseKg: piezaBaseKg)!;
  if (merma > mermaMaximaPct) {
    return 'Los cortes suman ${Fmt.kg(kgRindeTotal)} de los '
        '${Fmt.kg(piezaBaseKg)} de la pieza base: una merma del '
        '${Fmt.pct(merma.roundToDouble())}. Revisá los KGR.';
  }

  return null;
}
