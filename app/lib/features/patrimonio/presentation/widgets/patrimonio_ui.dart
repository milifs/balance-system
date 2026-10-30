import 'package:flutter/material.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/patrimonio.dart';
import '../../../../core/theme/app_theme.dart';

/// Encabezado de una de las dos columnas del cuadro (HABER / DEBE).
class ColumnaHeader extends StatelessWidget {
  const ColumnaHeader({super.key, required this.lado});

  final LadoPatrimonio lado;

  @override
  Widget build(BuildContext context) {
    final esHaber = lado == LadoPatrimonio.haber;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.rojo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Text(lado.titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(width: 8),
          Text(esHaber ? '(a favor)' : '(deudas)',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Pie de una columna con su total.
class ColumnaTotal extends StatelessWidget {
  const ColumnaTotal({super.key, required this.lado, required this.total});

  final LadoPatrimonio lado;
  final double total;

  @override
  Widget build(BuildContext context) {
    final color = lado == LadoPatrimonio.haber
        ? AppColors.verde
        : AppColors.rojoNegativo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.crema,
        border: Border(top: BorderSide(color: Color(0x22000000))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(lado.totalLabel,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.grisTexto)),
          Text(Fmt.moneda(total),
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }
}

/// Barra del saldo del negocio a la fecha: la resta entre las dos columnas.
/// Negativo (se debe más de lo que hay) en rojo, igual que en el balance.
class SaldoBar extends StatelessWidget {
  const SaldoBar({super.key, required this.fecha, required this.saldo});

  final DateTime fecha;
  final double saldo;

  @override
  Widget build(BuildContext context) {
    final color = saldo < 0 ? AppColors.rojoNegativo : AppColors.verde;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border(top: BorderSide(color: color.withValues(alpha: 0.35))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'SALDO BALANCE NEGOCIO AL ${Fmt.fecha(fecha)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.grisTexto),
            ),
          ),
          Text(Fmt.moneda(saldo),
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: color)),
        ],
      ),
    );
  }
}

/// Botón "Exportar PDF" con su spinner. Lo usan Carga (lo que está en
/// pantalla) y Consulta (lo guardado), cada una con su propio armado.
class ExportarPdfBoton extends StatefulWidget {
  const ExportarPdfBoton({super.key, required this.onExportar});

  final Future<void> Function() onExportar;

  @override
  State<ExportarPdfBoton> createState() => _ExportarPdfBotonState();
}

class _ExportarPdfBotonState extends State<ExportarPdfBoton> {
  bool _generando = false;

  Future<void> _exportar() async {
    setState(() => _generando = true);
    try {
      await widget.onExportar();
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _generando ? null : _exportar,
      icon: _generando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf, size: 18),
      label: const Text('Exportar PDF'),
    );
  }
}
