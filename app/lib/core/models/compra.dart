import 'package:freezed_annotation/freezed_annotation.dart';

part 'compra.freezed.dart';
part 'compra.g.dart';

/// Compra a proveedor para reponer stock durante el período.
///
/// `tipoCompra` guarda el **nombre** del tipo y no su id: es el nombre con el
/// que se cargó la compra, así renombrar o dar de baja un tipo en
/// Configuración no cambia lo que ya está registrado.
@freezed
abstract class Compra with _$Compra {
  const factory Compra({
    required String id,
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required String tipoCompra,
    @Default(0) double monto,
    String? proveedor,
    DateTime? creadoAt,
  }) = _Compra;

  factory Compra.fromJson(Map<String, dynamic> json) => _$CompraFromJson(json);
}
