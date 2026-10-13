import 'package:freezed_annotation/freezed_annotation.dart';

part 'tipo_compra.freezed.dart';
part 'tipo_compra.g.dart';

/// Tipo de mercadería que se compra a proveedores (Carne, Cerdo, Pollo,
/// Carbón, Condimentos...). Se administra en Configuración.
@freezed
abstract class TipoCompra with _$TipoCompra {
  const factory TipoCompra({
    required String id,
    required String nombre,
    @Default(0) int orden,
    @Default(true) bool activo,
  }) = _TipoCompra;

  factory TipoCompra.fromJson(Map<String, dynamic> json) =>
      _$TipoCompraFromJson(json);
}
