import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../application/auth_providers.dart';

/// Pantalla a la que cae el usuario cuando abre el link de recuperación.
/// En ese momento ya tiene sesión, pero el router no lo deja salir de acá
/// hasta que elija una contraseña nueva.
class NuevaPasswordPage extends ConsumerStatefulWidget {
  const NuevaPasswordPage({super.key});

  @override
  ConsumerState<NuevaPasswordPage> createState() => _NuevaPasswordPageState();
}

class _NuevaPasswordPageState extends ConsumerState<NuevaPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _repetirCtrl = TextEditingController();
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    _repetirCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).cambiarPassword(_passCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada.')),
      );
      // Libera el router: ahora navega al inicio con la sesión ya activa.
      ref.read(recuperandoPasswordProvider.notifier).completado();
    } catch (e) {
      setState(() => _error = 'No se pudo guardar la contraseña. Probá de nuevo.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Nueva contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.rojo,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Elegí la contraseña con la que vas a entrar de ahora en más.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.grisTexto),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña nueva',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) => (v == null || v.length < 8)
                            ? 'Mínimo 8 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _repetirCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Repetir contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        onFieldSubmitted: (_) => _guardar(),
                        validator: (v) =>
                            v != _passCtrl.text ? 'Las contraseñas no coinciden' : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: AppColors.rojoNegativo),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _guardando ? null : _guardar,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _guardando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Guardar'),
                        ),
                      ),
                      TextButton(
                        onPressed: _guardando
                            ? null
                            : () => ref.read(authRepositoryProvider).signOut(),
                        child: const Text('Cancelar y volver al login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
