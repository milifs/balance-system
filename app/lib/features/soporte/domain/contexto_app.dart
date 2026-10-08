import 'dart:ui' show Size;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

/// Plataforma y dispositivo desde donde se reportó el problema.
///
/// Lo captura la app sola: al usuario no se le pregunta nada de esto. El
/// tamaño de pantalla va porque la mitad de los problemas de la app son de
/// layout y saber si estaba en una tablet o en un monitor ahorra una ida y
/// vuelta.
///
/// En web `defaultTargetPlatform` devuelve el sistema operativo que el
/// navegador declara, así que queda, p. ej., `Web · macOS · 1512x857`.
String plataformaActual(Size pantalla) {
  final donde = kIsWeb ? 'Web' : 'App';
  final so = defaultTargetPlatform.name;
  return '$donde · $so · ${pantalla.width.round()}x${pantalla.height.round()}';
}
