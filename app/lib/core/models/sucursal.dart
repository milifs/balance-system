import 'package:freezed_annotation/freezed_annotation.dart';

part 'sucursal.freezed.dart';
part 'sucursal.g.dart';

@freezed
abstract class Sucursal with _$Sucursal {
  const factory Sucursal({
    required String id,
    required String nombre,
    required int orden,
    @Default(true) bool activo,
  }) = _Sucursal;

  factory Sucursal.fromJson(Map<String, dynamic> json) =>
      _$SucursalFromJson(json);
}
