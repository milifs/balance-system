import 'package:freezed_annotation/freezed_annotation.dart';

part 'compra.freezed.dart';
part 'compra.g.dart';

/// Tipo de mercadería comprada (coincide con las categorías valorizables).
enum TipoCompra {
  @JsonValue('Carne')
  carne,
  @JsonValue('Cerdo')
  cerdo,
  @JsonValue('Pollo')
  pollo,
}

extension TipoCompraX on TipoCompra {
  String get label => switch (this) {
        TipoCompra.carne => 'Carne',
        TipoCompra.cerdo => 'Cerdo',
        TipoCompra.pollo => 'Pollo',
      };
}

/// Compra a proveedor para reponer stock durante el período.
@freezed
abstract class Compra with _$Compra {
  const factory Compra({
    required String id,
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required TipoCompra tipoCompra,
    @Default(0) double monto,
    String? proveedor,
    DateTime? creadoAt,
  }) = _Compra;

  factory Compra.fromJson(Map<String, dynamic> json) => _$CompraFromJson(json);
}
