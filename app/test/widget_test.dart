// Smoke test básico del scaffold.
// Los tests de comportamiento por módulo se agregan en fases siguientes.
import 'package:flutter_test/flutter_test.dart';

import 'package:balance_system/auth/domain/app_profile.dart';

void main() {
  test('AppProfile.fromJson mapea rol y sucursal', () {
    final admin = AppProfile.fromJson({
      'id': 'u1',
      'nombre': 'Admin',
      'rol': 'admin',
      'sucursal_id': null,
    });
    expect(admin.esAdmin, isTrue);
    expect(admin.sucursalId, isNull);

    final cajera = AppProfile.fromJson({
      'id': 'u2',
      'nombre': 'Cajera',
      'rol': 'cajera',
      'sucursal_id': 's1',
    });
    expect(cajera.esCajera, isTrue);
    expect(cajera.sucursalId, 's1');
  });
}
