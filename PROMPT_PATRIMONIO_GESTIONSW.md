# Prompt: migrar el módulo Patrimonio a GestionSW

> Para pegar en una sesión de Claude abierta en `~/Projects/GestionSW`.
> El código fuente a portar está en `~/Projects/balance-system`.

---

Quiero portar el módulo **Patrimonio** desde `~/Projects/balance-system` a este
sistema. Es el último módulo que quedó afuera de la unificación: se construyó
en `balance-system` el 30/10/2026, después de que se decidiera que la
unificación arranca de cero, así que nunca entró en la spec de
`unificacion-balance.md`. No hay datos que migrar — es código nuevo acá.

**Antes de escribir una línea, leé el origen completo** (son ~650 líneas de
Dart y 120 de SQL):

```
~/Projects/balance-system/supabase/migrations/20261030000000_patrimonio.sql
~/Projects/balance-system/app/lib/core/models/patrimonio.dart
~/Projects/balance-system/app/lib/features/patrimonio/
~/Projects/balance-system/app/test/patrimonio_test.dart
~/Projects/balance-system/app/test/patrimonio_widget_test.dart
```

y la sección **§4.6 "Módulo de Patrimonio (solo admin)"** de
`~/Projects/balance-system/ANALISIS_FUNCIONAL.md`, más las filas de
`patrimonios` / `patrimonio_items` en `DISENO_TECNICO.md`.

---

## 1. Qué hace el módulo

Reemplaza una planilla de Excel que el dueño llevaba aparte: la foto del
patrimonio del negocio a una fecha, en dos columnas enfrentadas.

- **HABER** (lo que está a favor): efectivo, cuentas bancarias, lo que le
  deben los clientes mayoristas, stock, vehículos.
- **DEBE** (lo que se debe): proveedores, sueldos y aportes, tarjetas,
  crédito hipotecario, préstamos de la familia, cheques emitidos.

Reglas que definen el módulo y **no hay que "mejorar"**:

1. **Texto libre, sin vinculación a ninguna tabla del sistema.** Los conceptos
   se escriben a mano; no son `tipos_gasto`, ni `clientes`, ni `productos`. El
   cuadro mezcla el negocio con lo personal del dueño (la hipoteca de la casa,
   los préstamos de los padres), así que no hay catálogo que lo cubra y no
   tiene que haberlo.
2. **El único cálculo es la suma.** Total del HABER, total del DEBE, y
   `saldo = totalHaber - totalDebe`. Nada se deriva de períodos, ventas,
   compras ni pesajes, y el patrimonio no entra en ningún balance ni
   consolidado.
3. **El saldo normalmente es negativo** (en la planilla original:
   $80.909.533 a favor contra $112.970.072 de deudas = −$32.060.539). No es un
   error a validar: es el estado del negocio con créditos abiertos.
4. **Los montos pueden ser negativos.** La tabla del origen NO tiene
   `check (monto >= 0)` y eso es deliberado — mantenelo así.
5. **Una foto por fecha.** Guardar sobre una fecha que ya tiene cuadro lo
   reemplaza entero (borra los ítems y los vuelve a insertar), y la pantalla
   avisa antes con un chip: "Esta fecha ya tiene un cuadro: guardar lo
   reemplaza".
6. **El orden de los renglones se guarda.** El cuadro se lee renglón contra
   renglón, así que `patrimonio_items.orden` fija la posición dentro de su
   columna y la UI respeta el orden en que se escribió.

### Las dos pestañas

- **Carga** — la fecha (date picker), dos tarjetas lado a lado (HABER y DEBE)
  con 8 renglones en blanco al abrir, cada renglón concepto + monto. Los
  totales y el saldo se recalculan mientras se tipea. Botones Guardar y
  Exportar PDF (el PDF exporta lo que está en pantalla, guardado o no).
  Cambiar la fecha trae lo que ya estuviera guardado para esa fecha. Los
  renglones en blanco no se guardan. Un monto que no se puede parsear frena
  el guardado con un mensaje, no lo guarda como 0.
- **Consulta** — lista de fechas guardadas (más nueva primero) con el saldo de
  cada una al costado, y a la derecha el cuadro en solo lectura con Exportar
  PDF y Eliminar (con confirmación). Para corregir un cuadro se vuelve a
  Carga con esa fecha.
- Las dos pestañas se apilan en vertical por debajo de 900px (Carga) y 760px
  (Consulta).

---

## 2. Lo que hay que ADAPTAR (acá está el trabajo real)

El origen es mono-negocio y sin roles finos. **No copies el SQL ni el PDF tal
cual.** Estas son las diferencias, de la más peligrosa a la más cosmética:

### 2.1 `tenant_id` — y el índice único es una trampa

`patrimonios` y `patrimonio_items` llevan `tenant_id uuid not null references
public.tenants (id) on delete cascade`, como todas las tablas que entraron en
`20261028000005_u1_balance_tablas.sql`.

**El origen tiene `create unique index idx_patrimonios_fecha on patrimonios
(fecha)`. Copiarlo así rompe el multi-tenant**: la primera carnicería que
guarde el cuadro del 04/12 le bloquea esa fecha a todas las demás. Tiene que
ser **único por `(tenant_id, fecha)`**.

El cuadro es **tenant-wide, sin `sucursal_id`**: es el patrimonio del negocio
entero, no de una sucursal. Mismo criterio que las tablas del Balance — está
explicado en la cabecera de `20261028000008_u1_balance_rls.sql`.

Enganchá el trigger genérico de coherencia si corresponde
(`public.fila_mismo_tenant()`), siguiendo lo que hacen las tablas de esa
migración.

### 2.2 RLS escrita de cero, con los helpers de este repo

El origen usa `is_admin()` y policies de un solo negocio. Acá son
`public.current_tenant_id()`, `public.es_admin()`, `public.es_superadmin()` y
`public.permiso_cajero(ruta)`. Seguí el patrón de
`20261028000008_u1_balance_rls.sql`, incluido el `to authenticated` en las de
escritura (la anon key va compilada en el bundle web).

Patrimonio es **solo del admin del tenant**, sin switch de permiso para el
cajero (ver 2.3), así que las policies piden
`tenant_id = current_tenant_id() and es_admin()`, más `es_superadmin()` donde
el repo lo contemple.

### 2.3 El acceso: `Acceso.soloAdmin`, no un permiso del cajero

En el origen era `exclusivoAdmin: true`. Acá el equivalente es
**`Acceso.soloAdmin`** en `lib/core/router/modules.dart`.

El motivo de fondo (vale la pena dejarlo escrito en el comentario del módulo):
el cuadro mezcla el negocio con lo personal del dueño, así que no es algo que
se delegue en el mostrador ni que tenga sentido ofrecer como switch en
Configuración > Permisos del cajero. **Y no basta con sacarlo del menú**: la
RLS de `patrimonios` ya pide `es_admin()`.

Ojo con dos cosas al tocar `modules.dart`:

- `modulosPara` trata `soloAdmin` como caso especial para que Configuración
  aparezca si el cajero tiene alguna sección adentro. Verificá que el módulo
  nuevo **no** quede colado ahí: el cajero no tiene que verlo nunca, ni con
  permisos puestos a mano.
- `test/modulos_test.dart` afirma `hasLength(10)` y el comentario del archivo
  dice "Los 10 módulos". Pasan a ser **11**.
- Patrimonio **no** va en `modulosConfigurables` y **no** lleva fila en
  `permisos_cajero`, así que no hace falta sembrar nada en
  `permisos_cajero_por_defecto`.

Registrá la ruta `/patrimonio` en `lib/core/router/app_router.dart` y
confirmá que el guard del router rechaza la ruta para el cajero (no solo que
no se la muestre).

### 2.4 El PDF usa el helper compartido y el color del tenant

El origen tiene el rojo de Don Chacho clavado
(`const _rojo = PdfColor.fromInt(0xFF8B1E1E)`) y se arma su propio encabezado
y su propio pie. **Acá nada de eso.** Usá `lib/core/pdf/reporte_pdf.dart`:

- `MarcaReporte(negocio:, colorPrimario:)` desde `appProvider.tenantConfig`,
  igual que el call site de `lib/features/carga/presentation/carga_page.dart`.
- `encabezadoReporte(marca:, titulo:, subtitulo:, emitido:)` y
  `pieDePagina(ctx)`.
- La firma devuelve **`Future<Uint8List>`** y la pantalla descarga con
  `Printing.layoutPdf`, como `armarPdfCarga`. El origen llamaba a
  `Printing.sharePdf` adentro de la función de armado; acá se separa para que
  el test pueda armar el PDF sin plataforma.
- `AppColors.crema`, `grisTexto`, `verde` y `rojoNegativo` existen acá con los
  mismos valores, así que el recuadro verde/rojo del saldo porta tal cual. El
  único color que cambia es el de marca: sale de `marca.primario`.

**Una decisión que te dejo:** el origen arma el cuadro como **una sola
`pw.Table` de 4 columnas** (concepto|monto por lado) y no dos tablas lado a
lado, para que los renglones queden enfrentados como en la planilla y la tabla
se corte entre páginas sin partir el cuadro al medio. Mirá si `tablaReporte()`
te sirve para eso (encabezados `['HABER','','DEBE','']`, `anchos` con Flex(3)
/ Fixed(85), `alineacionDerecha: {1, 3}`) o si conviene una `pw.Table` propia
porque la fila de totales en negrita y el recuadro del saldo no entran en ese
helper. Elegí y dejá dicho por qué.

### 2.5 Convenciones de código de este repo

- **Los modelos van en `lib/models/`** (barrel `models.dart` /
  `balance_models.dart`), no en `lib/core/models/`. Decidí en cuál de los dos
  y dejalo dicho: Patrimonio no es del Balance (no entra en ningún cálculo del
  balance), así que probablemente sea `models.dart`.
- **`fromMap`, no `fromJson`** — es la convención de acá (`Perfil.fromMap`,
  `Periodo.fromMap`, `BalancePeriodo.fromMap`).
- **Enum de Postgres en vez de `text` + check.** El origen usa
  `lado text not null check (lado in ('haber','debe'))`; acá las tablas de
  U1 usan enums propios (`public.estado_periodo`) con `fromDb` / `.db` del
  lado Dart. Seguí eso.
- **`creado_en`**, no `creado_at`.
- Mantené `PatrimonioItem` y `Patrimonio` **escritos a mano, sin freezed**: el
  motivo original sigue valiendo (PostgREST devuelve `numeric` como número o
  como string y el parser cubre los dos casos, igual que `Precio`).
- `Fmt.moneda` y `Fmt.fecha` de `lib/core/formatters/formatters.dart` tienen la
  misma API que en el origen, así que la UI porta sin tocar el formateo.
- La función `guardar_patrimonio(p_fecha, p_items jsonb)` del origen hace
  `on conflict (fecha)`: pasa a `on conflict (tenant_id, fecha)` y el
  `tenant_id` lo resuelve adentro con `current_tenant_id()`. **No la hagas
  `security definer`** — que la RLS del invocador siga aplicando, igual que
  `fn_balance_periodo`.
- Migración nueva con el nombre que sigue la convención del repo (la última es
  `20261105000002_f12_ingresos_brutos_inicio_actividades.sql`), **idempotente**,
  con la cabecera explicando el porqué como el resto.

---

## 3. Archivos

**A crear** (siguiendo la estructura `data/` `application/` `presentation/`):

```
supabase/migrations/<ts>_<fase>_patrimonio.sql
lib/models/  → los modelos Patrimonio / PatrimonioItem / LadoPatrimonio
lib/features/patrimonio/data/patrimonio_repository.dart
lib/features/patrimonio/application/patrimonio_providers.dart
lib/features/patrimonio/presentation/patrimonio_page.dart          (TabBar Carga | Consulta)
lib/features/patrimonio/presentation/patrimonio_pdf.dart
lib/features/patrimonio/presentation/sections/carga_patrimonio_section.dart
lib/features/patrimonio/presentation/sections/consulta_patrimonio_section.dart
lib/features/patrimonio/presentation/widgets/patrimonio_ui.dart
```

**A modificar:**

```
lib/core/router/modules.dart        (el módulo nuevo + el comentario de "los 10")
lib/core/router/app_router.dart     (la ruta /patrimonio)
test/modulos_test.dart              (10 → 11)
```

---

## 4. Tests

Portá los 15 del origen (`patrimonio_test.dart` y
`patrimonio_widget_test.dart`) adaptados a las convenciones de acá —
el widget test usa un `_RepoFalso implements PatrimonioRepository` y
`setSurfaceSize(1400x900)`:

- totales y saldo; saldo negativo
- `numeric` que llega como string
- `orden` respetado cuando las filas vienen desordenadas
- cuadro vacío
- la forma del `toMap` que se manda a la RPC
- el admin ve el módulo / el cajero no lo ve **ni con el permiso puesto a
  mano** / no está en `modulosConfigurables`
- Carga abre con lo guardado; los totales se recalculan al tipear; guarda solo
  los renglones escritos y en orden; un monto inválido frena el guardado; una
  fecha sin cuadro arranca en tres `0 $`
- el PDF se arma con las dos columnas de distinto largo y los bytes empiezan
  con `%PDF`

**Y agregá el que el origen no podía tener: aislamiento por tenant.** Seguí
`test/aislamiento_balance_test.dart` y su fixture `supabase/fixtures/12_balance.sql`
— dos tenants, control positivo primero (los números exactos del tenant
propio) y después las ausencias: el vecino no ve ningún cuadro, no puede
insertar uno con el `tenant_id` ajeno, y los dos tenants pueden tener un
cuadro de la MISMA fecha sin pisarse (ese es el test que atrapa el índice
único mal portado del punto 2.1). Sin mocks: lo que aísla es la policy.

---

## 5. Cómo trabajar en este checkout

`~/Projects/GestionSW` lo trabajan **varias sesiones de Claude en paralelo
sobre el mismo working tree**:

- **Commiteá siempre por path explícito.** Nunca `git add -A` ni `git commit -a`:
  te llevás trabajo a medio terminar de otra sesión.
- **Chequeá `git branch --show-current` justo antes de commitear** — la rama
  pudo cambiar desde el último chequeo.
- **No crees ni cambies de rama** para aislarte: el checkout es uno solo y
  moverías también a la otra sesión.
- Cambios ajenos sin commitear que aparecen de la nada **no son basura**:
  preguntame antes de tocarlos o revertirlos.
- En el reporte final, listá qué quedó sin commitear aclarando que es de otra
  sesión.

Mirá también si el repo pide spec antes de código (`.kiro/specs/`): si la fase
va documentada, escribila primero y decime en qué archivo.

---

## 6. Listo cuando

- La migración aplica limpia y **de nuevo sin error** (es idempotente).
- Dos tenants guardan un cuadro de la misma fecha sin pisarse.
- Un cajero no ve el módulo y no puede leer ni escribir `patrimonios`, aunque
  le metan el permiso a mano.
- `flutter analyze` sin issues y `flutter test` en verde, incluido el de
  aislamiento.
- El PDF sale con el nombre y el color del tenant, no con el rojo de
  Don Chacho.
