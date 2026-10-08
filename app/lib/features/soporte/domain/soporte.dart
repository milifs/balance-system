import '../../../core/router/modules.dart';

/// Estado de un reclamo. Los tres valores del `check` de la tabla.
enum EstadoSoporte {
  abierto('abierto', 'Abiertos', 'Abierto'),
  enRevision('en_revision', 'En revisión', 'En revisión'),
  resuelto('resuelto', 'Resueltos', 'Resuelto');

  const EstadoSoporte(this.db, this.plural, this.singular);

  /// Valor tal como se guarda en la columna `estado`.
  final String db;

  /// Título del tab de la bandeja.
  final String plural;

  /// Etiqueta de un reclamo suelto.
  final String singular;

  static EstadoSoporte desdeDb(String? v) =>
      values.firstWhere((e) => e.db == v, orElse: () => abierto);
}

/// Opciones del dropdown "¿En qué parte del sistema?".
///
/// Se arma con los labels reales de la navegación para que no se desincronice
/// cuando se agrega o renombra un módulo. "Ingreso / contraseña" no es un
/// módulo del menú pero es por donde más se traba la gente, y "Otro" es la
/// salida para lo que no entra en ninguna.
List<String> get modulosSoporte => [
      for (final m in modulos) m.label,
      'Ingreso / contraseña',
      'Otro',
    ];

/// Un reclamo de soporte (fila de `soportes`).
///
/// Se escribe a mano en vez de con freezed porque el modelo no se serializa
/// entero: el insert omite las columnas que llena la base (ver [toInsertJson]).
class Soporte {
  const Soporte({
    this.id,
    this.numero = 0,
    required this.modulo,
    required this.descripcion,
    this.bloqueante = false,
    this.adjuntoPath,
    this.estado = EstadoSoporte.abierto,
    this.respuesta = '',
    this.reportadoPor,
    this.rol,
    this.appVersion,
    this.plataforma,
    this.creadoEn,
    this.resueltoEn,
    this.resueltoPor,
  });

  final String? id;

  /// Número de ticket. Lo asigna la secuencia de Postgres, nunca el cliente:
  /// vale 0 hasta que la base devuelve la fila insertada.
  final int numero;

  final String modulo;
  final String descripcion;

  /// "No puedo seguir trabajando". Es lo que ordena la cola de triage.
  final bool bloqueante;

  /// PATH del archivo en el bucket, no la URL. Los links se firman al usarlos.
  final String? adjuntoPath;

  final EstadoSoporte estado;

  /// Lo que soporte le contesta al cliente. Se ve en "Tus reclamos".
  final String respuesta;

  final String? reportadoPor;
  final String? rol;
  final String? appVersion;
  final String? plataforma;
  final DateTime? creadoEn;
  final DateTime? resueltoEn;
  final String? resueltoPor;

  /// Código visible del reclamo: `S-0001`.
  String get codigo => 'S-${numero.toString().padLeft(4, '0')}';

  bool get tieneAdjunto => (adjuntoPath ?? '').isNotEmpty;
  bool get tieneRespuesta => respuesta.trim().isNotEmpty;

  factory Soporte.fromJson(Map<String, dynamic> json) => Soporte(
        id: json['id'] as String?,
        numero: (json['numero'] as num?)?.toInt() ?? 0,
        modulo: (json['modulo'] as String?) ?? '',
        descripcion: (json['descripcion'] as String?) ?? '',
        bloqueante: (json['bloqueante'] as bool?) ?? false,
        adjuntoPath: json['adjunto_path'] as String?,
        estado: EstadoSoporte.desdeDb(json['estado'] as String?),
        respuesta: (json['respuesta'] as String?) ?? '',
        reportadoPor: json['reportado_por'] as String?,
        rol: json['rol'] as String?,
        appVersion: json['app_version'] as String?,
        plataforma: json['plataforma'] as String?,
        // Las columnas son `timestamptz`: llegan en UTC y hay que pasarlas a
        // hora local o el reclamo aparece 3 horas en el futuro.
        creadoEn: DateTime.tryParse((json['creado_en'] as String?) ?? '')
            ?.toLocal(),
        resueltoEn: DateTime.tryParse((json['resuelto_en'] as String?) ?? '')
            ?.toLocal(),
        resueltoPor: json['resuelto_por'] as String?,
      );

  /// Columnas que manda el cliente al crear el reclamo.
  ///
  /// `numero` se omite cuando vale 0 para que lo asigne la secuencia de
  /// Postgres. Mandarlo calculado desde el cliente (max+1, como se numeran
  /// otras cosas en este proyecto) abre una carrera: dos personas reportando
  /// al mismo tiempo pedirían el mismo número.
  Map<String, dynamic> toInsertJson() => {
        'modulo': modulo,
        'descripcion': descripcion,
        'bloqueante': bloqueante,
        'adjunto_path': adjuntoPath,
        'reportado_por': reportadoPor,
        'rol': rol,
        'app_version': appVersion,
        'plataforma': plataforma,
        if (numero != 0) 'numero': numero,
      };
}
