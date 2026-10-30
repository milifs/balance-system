import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/patrimonio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../carga/presentation/widgets/carga_ui.dart';
import '../../application/patrimonio_providers.dart';
import '../patrimonio_pdf.dart';
import '../widgets/patrimonio_ui.dart';

/// Pestaña Carga: el cuadro de patrimonio a una fecha, en dos columnas de
/// texto libre. Nada de esto sale de las tablas del sistema ni entra en el
/// balance de los períodos: es una planilla aparte que se guarda por fecha.
class CargaPatrimonioSection extends ConsumerStatefulWidget {
  const CargaPatrimonioSection({super.key});

  @override
  ConsumerState<CargaPatrimonioSection> createState() =>
      _CargaPatrimonioSectionState();
}

/// Cuántos renglones en blanco se ofrecen cuando la fecha todavía no tiene
/// cuadro. Alcanzan para empezar a escribir sin tener que apretar "Agregar
/// fila" en cada renglón.
const _filasIniciales = 8;

class _CargaPatrimonioSectionState extends ConsumerState<CargaPatrimonioSection>
    with AutomaticKeepAliveClientMixin {
  // El cuadro a medio escribir no se pierde al pasar a Consulta y volver:
  // sin esto, `TabBarView` tira el estado de la pestaña que no se ve.
  @override
  bool get wantKeepAlive => true;

  DateTime _fecha = _hoy();
  final List<_Fila> _haber = [];
  final List<_Fila> _debe = [];

  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  /// Si la fecha elegida ya tenía un cuadro guardado. Se avisa en pantalla:
  /// guardar lo reemplaza.
  bool _existia = false;

  static DateTime _hoy() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _cargarFecha(_fecha);
  }

  @override
  void dispose() {
    for (final f in [..._haber, ..._debe]) {
      f.dispose();
    }
    super.dispose();
  }

  /// Trae el cuadro de esa fecha (o deja renglones en blanco si no hay) y
  /// arma los controllers de cero.
  Future<void> _cargarFecha(DateTime fecha) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final guardado =
          await ref.read(patrimonioRepositoryProvider).porFecha(fecha);
      if (!mounted) return;
      setState(() {
        for (final f in [..._haber, ..._debe]) {
          f.dispose();
        }
        _haber
          ..clear()
          ..addAll(_filasDe(guardado?.haber));
        _debe
          ..clear()
          ..addAll(_filasDe(guardado?.debe));
        _existia = guardado != null;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _cargando = false;
      });
    }
  }

  List<_Fila> _filasDe(List<PatrimonioItem>? items) {
    final filas = [
      for (final i in items ?? const <PatrimonioItem>[])
        _Fila.desde(i, _recalcular),
    ];
    while (filas.length < _filasIniciales) {
      filas.add(_Fila.vacia(_recalcular));
    }
    return filas;
  }

  /// Los totales se leen de los campos mientras se tipea, así que cualquier
  /// cambio de monto repinta la sección.
  void _recalcular() => setState(() {});

  double _total(List<_Fila> filas) =>
      filas.fold<double>(0, (s, f) => s + (parseMonto(f.monto.text) ?? 0));

  /// Las filas que tienen algo escrito, numeradas en el orden en que están
  /// en pantalla. Las vacías no se guardan.
  List<PatrimonioItem> _items(List<_Fila> filas, LadoPatrimonio lado) {
    final items = <PatrimonioItem>[];
    for (final f in filas) {
      final concepto = f.concepto.text.trim();
      final monto = parseMonto(f.monto.text);
      if (concepto.isEmpty && monto == null) continue;
      items.add(PatrimonioItem(
        lado: lado,
        orden: items.length,
        concepto: concepto,
        monto: monto ?? 0,
      ));
    }
    return items;
  }

  /// Un monto tipeado que no se entiende (letras, dos comas) frenaría el
  /// guardado dejando ese renglón en cero sin que nadie se entere.
  bool _montosValidos() {
    for (final f in [..._haber, ..._debe]) {
      final txt = f.monto.text.trim();
      if (txt.isNotEmpty && parseMonto(txt) == null) return false;
    }
    return true;
  }

  Future<void> _elegirFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5, 12, 31),
    );
    if (picked == null) return;
    final fecha = DateTime(picked.year, picked.month, picked.day);
    setState(() => _fecha = fecha);
    await _cargarFecha(fecha);
  }

  Future<void> _guardar() async {
    if (!_montosValidos()) {
      mostrarMensaje(context, 'Hay un monto que no se entiende. Revisalo.',
          error: true);
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref.read(patrimonioRepositoryProvider).guardar(
        fecha: _fecha,
        items: [
          ..._items(_haber, LadoPatrimonio.haber),
          ..._items(_debe, LadoPatrimonio.debe),
        ],
      );
      ref.invalidate(patrimoniosProvider);
      if (!mounted) return;
      setState(() => _existia = true);
      mostrarMensaje(context, 'Patrimonio guardado.');
    } catch (e) {
      if (mounted) mostrarMensaje(context, 'No se pudo guardar: $e', error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  /// Exporta lo que está en pantalla (incluso sin guardar): el PDF es una
  /// foto de lo que se está mirando.
  Future<void> _exportar() async {
    try {
      await exportarPatrimonioPdf(
        fecha: _fecha,
        haber: _items(_haber, LadoPatrimonio.haber),
        debe: _items(_debe, LadoPatrimonio.debe),
      );
    } catch (e) {
      if (mounted) {
        mostrarMensaje(context, 'No se pudo exportar el PDF: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error al cargar el patrimonio: $_error',
              style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      );
    }

    final totalHaber = _total(_haber);
    final totalDebe = _total(_debe);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Barra(
          fecha: _fecha,
          existia: _existia,
          guardando: _guardando,
          onFecha: _elegirFecha,
          onGuardar: _guardar,
          onExportar: _exportar,
        ),
        const Divider(height: 1),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, c) {
                    final columnas = [
                      _Columna(
                        lado: LadoPatrimonio.haber,
                        filas: _haber,
                        total: totalHaber,
                        onAgregar: () =>
                            setState(() => _haber.add(_Fila.vacia(_recalcular))),
                        onBorrar: (i) => setState(() {
                          _haber.removeAt(i).dispose();
                        }),
                      ),
                      _Columna(
                        lado: LadoPatrimonio.debe,
                        filas: _debe,
                        total: totalDebe,
                        onAgregar: () =>
                            setState(() => _debe.add(_Fila.vacia(_recalcular))),
                        onBorrar: (i) => setState(() {
                          _debe.removeAt(i).dispose();
                        }),
                      ),
                    ];
                    // En pantalla angosta las columnas no entran al lado:
                    // se apilan y el cuadro se lee de arriba abajo.
                    if (c.maxWidth < 900) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(height: 420, child: columnas[0]),
                            const SizedBox(height: 16),
                            SizedBox(height: 420, child: columnas[1]),
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: columnas[0]),
                          const SizedBox(width: 16),
                          Expanded(child: columnas[1]),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SaldoBar(fecha: _fecha, saldo: totalHaber - totalDebe),
      ],
    );
  }
}

/// Fecha del cuadro + guardar + exportar.
class _Barra extends StatelessWidget {
  const _Barra({
    required this.fecha,
    required this.existia,
    required this.guardando,
    required this.onFecha,
    required this.onGuardar,
    required this.onExportar,
  });

  final DateTime fecha;
  final bool existia;
  final bool guardando;
  final VoidCallback onFecha;
  final VoidCallback onGuardar;
  final Future<void> Function() onExportar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FechaField(fecha: fecha, onTap: onFecha, width: 170),
          if (existia)
            const Chip(
              avatar: Icon(Icons.history, size: 16, color: AppColors.grisTexto),
              label: Text('Esta fecha ya tiene un cuadro: guardar lo reemplaza'),
              backgroundColor: Color(0x11000000),
              side: BorderSide(color: Color(0x22000000)),
            ),
          ExportarPdfBoton(onExportar: onExportar),
          FilledButton.icon(
            onPressed: guardando ? null : onGuardar,
            icon: guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

/// Una de las dos columnas del cuadro, editable.
class _Columna extends StatelessWidget {
  const _Columna({
    required this.lado,
    required this.filas,
    required this.total,
    required this.onAgregar,
    required this.onBorrar,
  });

  final LadoPatrimonio lado;
  final List<_Fila> filas;
  final double total;
  final VoidCallback onAgregar;
  final ValueChanged<int> onBorrar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColumnaHeader(lado: lado),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              itemCount: filas.length + 1,
              itemBuilder: (context, i) {
                if (i == filas.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextButton.icon(
                        onPressed: onAgregar,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar fila'),
                      ),
                    ),
                  );
                }
                return _FilaEditor(
                  key: ObjectKey(filas[i]),
                  fila: filas[i],
                  onBorrar: () => onBorrar(i),
                );
              },
            ),
          ),
          ColumnaTotal(lado: lado, total: total),
        ],
      ),
    );
  }
}

/// Un renglón: concepto a la izquierda, monto a la derecha.
class _FilaEditor extends StatelessWidget {
  const _FilaEditor({super.key, required this.fila, required this.onBorrar});

  final _Fila fila;
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: fila.concepto,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Concepto',
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 150,
            child: TextField(
              controller: fila.monto,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                isDense: true,
                prefixText: r'$ ',
                hintText: '0',
              ),
            ),
          ),
          IconButton(
            tooltip: 'Quitar fila',
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.grisTexto,
            onPressed: onBorrar,
          ),
        ],
      ),
    );
  }
}

/// Los dos campos de un renglón mientras se edita.
class _Fila {
  _Fila._(this.concepto, this.monto, this._onMonto) {
    monto.addListener(_onMonto);
  }

  factory _Fila.vacia(VoidCallback onMonto) => _Fila._(
        TextEditingController(),
        TextEditingController(),
        onMonto,
      );

  factory _Fila.desde(PatrimonioItem item, VoidCallback onMonto) => _Fila._(
        TextEditingController(text: item.concepto),
        // Sin formato de miles: el campo se vuelve a tipear a mano y el
        // separador que meta el formateador se pelea con lo que escribe
        // la persona. `parseMonto` acepta las dos notaciones al leerlo.
        TextEditingController(
            text: item.monto == 0 ? '' : _sinCerosSobrantes(item.monto)),
        onMonto,
      );

  final TextEditingController concepto;
  final TextEditingController monto;
  final VoidCallback _onMonto;

  void dispose() {
    monto.removeListener(_onMonto);
    concepto.dispose();
    monto.dispose();
  }

  static String _sinCerosSobrantes(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
