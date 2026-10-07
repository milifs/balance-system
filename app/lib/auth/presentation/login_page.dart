import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/env.dart';
import '../../core/theme/app_theme.dart';
import '../application/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      // El redirect del router se encarga de navegar al inicio.
    } catch (e) {
      setState(() => _error = 'No se pudo iniciar sesión. Verificá email y contraseña.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _recuperar() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => _RecuperarDialog(emailInicial: _emailCtrl.text.trim()),
    );
    if (email == null || !mounted) return;
    try {
      await ref.read(authRepositoryProvider).enviarRecuperacion(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te mandamos un mail a $email con el link.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el mail. Probá en un rato.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorLink = ref.watch(authLinkErrorProvider);
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
                        'Don Chacho',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.rojo,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sistema de Balance',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.grisTexto),
                      ),
                      if (errorLink != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          '$errorLink\nPedí un link nuevo con "¿Olvidaste tu contraseña?".',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.rojoNegativo,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Email inválido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        onFieldSubmitted: (_) => _ingresar(),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Ingresá tu contraseña' : null,
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
                        onPressed: _cargando ? null : _ingresar,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _cargando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Ingresar'),
                        ),
                      ),
                      TextButton(
                        onPressed: _cargando ? null : _recuperar,
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                      if (!Env.hasAnonKey) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Falta configurar SUPABASE_ANON_KEY (--dart-define).',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.rojoNegativo, fontSize: 12),
                        ),
                      ],
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

class _RecuperarDialog extends StatefulWidget {
  const _RecuperarDialog({required this.emailInicial});

  final String emailInicial;

  @override
  State<_RecuperarDialog> createState() => _RecuperarDialogState();
}

class _RecuperarDialogState extends State<_RecuperarDialog> {
  late final _ctrl = TextEditingController(text: widget.emailInicial);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Te mandamos un link por mail. Abrilo en este mismo navegador.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ctrl,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              onFieldSubmitted: (_) => _enviar(),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Email inválido' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _enviar, child: const Text('Enviar link')),
      ],
    );
  }
}
