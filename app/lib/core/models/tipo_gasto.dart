import 'package:freezed_annotation/freezed_annotation.dart';

part 'tipo_gasto.freezed.dart';
part 'tipo_gasto.g.dart';

@freezed
abstract class TipoGasto with _$TipoGasto {
  const factory TipoGasto({
    required String id,
    required String nombre,
    @Default(0) int orden,
    @Default(true) bool activo,
  }) = _TipoGasto;

  factory TipoGasto.fromJson(Map<String, dynamic> json) =>
      _$TipoGastoFromJson(json);
}
