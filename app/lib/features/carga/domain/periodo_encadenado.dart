import '../../../core/formatters/formatters.dart';
import '../../../core/models/periodo.dart';

/// Los períodos de una sucursal van pegados: el siguiente arranca el día
/// posterior al cierre del anterior. Ni se pisan ni dejan huecos.
///
/// Importa para el balance: el stock inicial de un período es el cierre del
/// anterior, así que si dos se pisan no hay forma de saber cuál es "el
/// anterior", y si queda un hueco los movimientos de esos días no entran en
/// ningún período.
///
/// La base lo garantiza con el trigger `trg_periodos_encadenados`; esto es
/// para avisar antes, con un mensaje que se entienda.

/// Fecha sin hora, para comparar días y no milisegundos.
DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

/// El día siguiente a [d].
DateTime diaSiguiente(DateTime d) =>
    DateTime(d.year, d.month, d.day).add(const Duration(days: 1));

/// El día anterior a [d].
DateTime diaAnterior(DateTime d) =>
    DateTime(d.year, d.month, d.day).subtract(const Duration(days: 1));

/// Valida el rango de un período contra [otros], los de la misma sucursal sin
/// contar el que se está editando. Devuelve el mensaje a mostrar, o null si
/// está bien.
String? errorDeEncadenado({
  required List<Periodo> otros,
  required DateTime inicio,
  required DateTime fin,
}) {
  final ini = soloFecha(inicio);
  final f = soloFecha(fin);
  if (f.isBefore(ini)) {
    return 'La fecha de cierre no puede ser anterior al inicio.';
  }

  for (final p in otros) {
    final pIni = soloFecha(p.fechaInicio);
    final pFin = soloFecha(p.fechaFin);
    if (!ini.isAfter(pFin) && !f.isBefore(pIni)) {
      return 'Se pisa con el período ${Fmt.fecha(pIni)} – ${Fmt.fecha(pFin)}.';
    }
  }

  final anterior = periodoAnterior(otros, ini);
  if (anterior != null) {
    final esperado = diaSiguiente(anterior.fechaFin);
    if (ini != esperado) {
      return 'Tiene que empezar el ${Fmt.fecha(esperado)}, el día siguiente al '
          'cierre del período anterior.';
    }
  }

  final siguiente = periodoSiguiente(otros, f);
  if (siguiente != null) {
    final esperado = diaAnterior(siguiente.fechaInicio);
    if (f != esperado) {
      return 'Tiene que cerrar el ${Fmt.fecha(esperado)}, el día anterior al '
          'inicio del período que sigue.';
    }
  }

  return null;
}

/// El período de [otros] que termina más cerca, antes de [inicio].
Periodo? periodoAnterior(List<Periodo> otros, DateTime inicio) {
  final ini = soloFecha(inicio);
  Periodo? mejor;
  for (final p in otros) {
    if (soloFecha(p.fechaFin).isBefore(ini) &&
        (mejor == null || p.fechaFin.isAfter(mejor.fechaFin))) {
      mejor = p;
    }
  }
  return mejor;
}

/// El período de [otros] que empieza más cerca, después de [fin].
Periodo? periodoSiguiente(List<Periodo> otros, DateTime fin) {
  final f = soloFecha(fin);
  Periodo? mejor;
  for (final p in otros) {
    if (soloFecha(p.fechaInicio).isAfter(f) &&
        (mejor == null || p.fechaInicio.isBefore(mejor.fechaInicio))) {
      mejor = p;
    }
  }
  return mejor;
}
