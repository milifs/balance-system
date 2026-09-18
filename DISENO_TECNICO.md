# Sistema de Balance — Carnicerías Don Chacho
## Documento de Diseño Técnico

> **Metodología:** Spec Driven Development (SDD). Este documento es el **"cómo"**: traduce el análisis funcional (`ANALISIS_FUNCIONAL.md`, el "qué") en arquitectura, modelo de datos detallado y plan de implementación.
>
> **Estado:** v1.0 — para revisión
> **Fecha:** 2026-09-18
> **Stack confirmado:** Flutter + Dart (Web) · Supabase (PostgreSQL + Auth + Realtime) · deploy en Vercel

---

## 1. Arquitectura general

```
┌─────────────────────────────────────────────┐
│              Flutter Web (Dart)              │
│  UI (6 módulos)  ·  Riverpod  ·  go_router   │
│         supabase_flutter (cliente)           │
└───────────────────────┬─────────────────────┘
                        │  HTTPS / WebSocket
┌───────────────────────┴─────────────────────┐
│                  Supabase                    │
│  Postgres  ·  Auth  ·  RLS  ·  Realtime      │
│  Vistas + funciones (RPC) para cálculos      │
└──────────────────────────────────────────────┘
                        │
                     Vercel (hosting del build web)
```

- **Cliente Flutter Web**: toda la UI y la lógica de presentación. Habla con Supabase vía el SDK oficial `supabase_flutter`.
- **Supabase** actúa como backend completo: base de datos Postgres, autenticación, seguridad por fila (RLS) y realtime. Los cálculos pesados (valorización de stock, balance) viven en **vistas y funciones SQL** para tener una sola fuente de verdad; la simulación de rinde en vivo se calcula en el cliente.
- **Vercel** sirve el build estático de Flutter Web.

### 1.1 Decisiones técnicas

| Tema | Decisión | Por qué |
|---|---|---|
| **Gestión de estado** | **Riverpod** (v2, con code-gen) | Tipado fuerte, providers async para datos de Supabase, fácil de testear, recomputación reactiva ideal para el rinde en vivo. |
| **Ruteo** | **go_router** | Rutas declarativas, guards por rol/auth, soporta deep-linking en web. |
| **Cliente backend** | **supabase_flutter** | SDK oficial: Auth, Postgrest, Realtime en un paquete. |
| **Modelos** | Clases Dart inmutables con **freezed** + `fromJson/toJson` | Menos boilerplate, igualdad por valor, serialización segura. |
| **Cálculos de balance** | **Vistas / funciones SQL** en Postgres | Una sola definición de la fórmula, no se duplica en el cliente; el histórico queda consistente. |
| **Rinde en vivo** | **En el cliente** (Dart) mientras el admin edita precios | Recalcula al instante sin ir al servidor; recién al "Guardar precios" persiste. |
| **Formato de moneda/números** | `intl` con locale `es_AR` | Miles con punto, decimales con coma ($1.382.260,65). |

---

## 2. Modelo de datos (Postgres)

Se **reescribe la migración inicial** (`20260527000000_initial_schema.sql`) en una migración nueva que parte de lo bueno que ya existe y agrega lo que falta. Convención: `snake_case`, ids `uuid`, timestamps `timestamptz`.

### 2.1 Diagrama de entidades (resumen)

```
auth.users ──1:1── profiles ──*:1── sucursales
                       │
categorias ──1:*── cortes ──1:1── precios
     │                 │
     │                 └──*── (valoriza_a: venta | costo, costo_manual)
     │
periodos ──1:*── ventas        (medio_pago_id)
     │      ├──*── compras      (tipo_compra)
     │      ├──*── gastos       (tipo_gasto_id)
     │      └──*── pesajes ──1:*── pesaje_items
     │
medios_pago · tipos_gasto      (parametrización en Configuración)
```

### 2.2 Tablas

#### `profiles` *(ya existe — se agrega sucursal)*
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | = `auth.users.id` |
| nombre | text | |
| rol | text | `admin` \| `cajera` |
| **sucursal_id** | uuid FK → sucursales | **NUEVO**. Null para admin; obligatorio para cajera. |
| creado_at | timestamptz | |

> El trigger `handle_new_user()` se mantiene; se extiende para leer `sucursal_id` del `raw_user_meta_data`.

#### `sucursales` *(ya existe — se corrige el seed)*
| id | nombre | orden | activo |
|---|---|---|---|

Seed correcto: **Don Chacho 1, 2, 3, 4** (reemplaza "Chacho 1/2", "Cabaña del Valle").

#### `categorias` *(ya existe — se quita Pescado y se agrega pieza base + factor)*
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| nombre | text | Carne, Cerdo, Pollo (**sin Pescado**) |
| orden | int | |
| **pieza_base_nombre** | text | **NUEVO**. Media Res / Media Cerdo / Caja de Pollo |
| **pieza_base_kg** | decimal(10,3) | **NUEVO**. ej. 111 |
| **pieza_base_costo_kg** | decimal(12,2) | **NUEVO**. $/kg de compra, ej. 10400 |
| **factor_incremento** | decimal(6,4) | **NUEVO**. ej. 1.05 (+5%). Reemplaza la tabla `incrementos`. |

> `costo_pieza_base = pieza_base_kg × pieza_base_costo_kg` (columna generada o calculada en vista).

#### `cortes` *(ya existe — se agrega valorización costo/venta)*
| Columna | Tipo | Notas |
|---|---|---|
| id, categoria_id, nombre, kgr_rinde, activo, orden, creado_at | | igual que hoy |
| **valoriza_a** | text | **NUEVO**. `venta` (cortes individuales) \| `costo` (piezas enteras) |
| **costo_manual** | decimal(12,2) | **NUEVO**. Precio de costo para piezas enteras (Media Res, Octavo, Costillar, Pierna, Caja de Pollo). Se carga en Configuración. |

Seed: se **conservan** los cortes ya cargados del Excel (Carne 23, Cerdo 10, Pollo 5) y se marca `valoriza_a`.

#### `precios` *(ya existe — sin cambios)*
`corte_id` (único), `precio_actual`, `precio_ultimo`, `precio_penultimo`, `actualizado_at`.
Rotación al guardar: `nuevo → actual → ultimo → penultimo`.

#### `medios_pago` *(NUEVO — parametrización de ventas)*
| id | nombre | retencion_pct | orden | activo |
|---|---|---|---|---|

Seed: Efectivo `0`, Crédito `12`, Débito `12`, Transferencia `0` (provisorio, editable).

#### `tipos_gasto` *(NUEVO — parametrización de gastos)*
| id | nombre | orden | activo |

Seed: Rentas, Contador, Gastos varios, Saldos sueldos, Luz, Agua, Internet.

#### `periodos` *(NUEVO — el rango de fechas del balance)*
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| sucursal_id | uuid FK | |
| fecha_inicio | date | |
| fecha_fin | date | |
| estado | text | `abierto` \| `cerrado` |
| stock_inicial_manual | decimal(14,2) | solo primer período (sin pesaje anterior) |
| creado_at | timestamptz | |

#### `ventas` *(NUEVO)*
| id | periodo_id FK | sucursal_id FK | fecha | medio_pago_id FK | monto | creado_at |

#### `compras` *(NUEVO)*
| id | periodo_id FK | sucursal_id FK | fecha | tipo_compra (`Carne`\|`Cerdo`\|`Pollo`) | monto | proveedor (opcional) | creado_at |

#### `gastos` *(NUEVO)*
| id | periodo_id FK | sucursal_id FK | fecha | tipo_gasto_id FK | monto | creado_at |

#### `pesajes` *(ya existe — se liga al período y al momento)*
| Columna | Tipo | Notas |
|---|---|---|
| id, corte_id, sucursal_id, fecha, precio_snapshot, creado_at | | igual que hoy |
| **periodo_id** | uuid FK | **NUEVO** |
| **momento** | text | **NUEVO**. `apertura` (stock inicial) \| `cierre` (stock final) |

#### `pesaje_items` *(ya existe — sin cambios)*
`pesaje_id`, `kg`, `origen` ("cámara de frío", "batea"...).

### 2.3 Vistas y funciones (cálculos)

| Objeto | Tipo | Qué calcula |
|---|---|---|
| `v_valor_pesaje` | vista | Por pesaje: `Σ(kg) × precio` según `valoriza_a` (venta usa `precios.precio_actual`; costo usa `cortes.costo_manual`). Totales por corte/categoría/sucursal. |
| `v_rinde_actual` | vista *(ya existe, se ajusta)* | Por corte: `kgr_rinde × precio_actual`; agrega al pie **Ingreso del despiece**, **Costo pieza**, **Resultado $** y **% de rinde**. |
| `fn_balance_periodo(periodo_id)` | función/RPC | Ventas brutas y netas por medio, total compras, stock inicial y final (del pesaje encadenado), CMV, Σ gastos, Ganancia y Utilidad neta %. |
| `fn_consolidado(fecha_ini, fecha_fin)` | función/RPC | Suma los balances de las 4 sucursales para el rango. |

**Fórmulas implementadas** (idénticas al §5 del análisis funcional):
```
CMV               = stock_inicial + compras − stock_final
venta_neta_medio  = monto × (1 − retencion_pct/100)
ganancia          = Σ venta_neta − CMV − Σ gastos
utilidad_neta_pct = ganancia / Σ venta_neta
resultado_rinde   = Σ(kgr × precio_actual) − (pieza_base_kg × pieza_base_costo_kg)
pct_rinde         = resultado_rinde / costo_pieza_base
```

### 2.4 Seguridad (RLS) por rol

| Tabla | Cajera | Admin |
|---|---|---|
| categorias, cortes, precios, medios_pago, tipos_gasto, sucursales | **lee** | lee + escribe |
| ventas, compras, gastos | lee/escribe **solo su `sucursal_id`** | todo |
| periodos | lee/escribe su sucursal | todo |
| pesajes, pesaje_items | **lee todas** (requisito del módulo), escribe su sucursal | todo |
| balances (vistas/RPC), historial | **sin acceso** | acceso total |
| profiles | ve/edita el propio | ve todos |

Helper `is_admin()` ya existe. Se agrega `mi_sucursal()` → devuelve `profiles.sucursal_id` del usuario autenticado, para las policies de cajera.

---

## 3. Arquitectura de la app Flutter

### 3.1 Estructura de carpetas (feature-first)

```
lib/
├── main.dart                     # bootstrap: init Supabase, ProviderScope
├── app.dart                      # MaterialApp.router + tema
├── core/
│   ├── supabase/                 # cliente, config, extensiones
│   ├── router/                   # go_router + guards por rol
│   ├── theme/                    # colores (rojo carnicería), tipografía
│   ├── formatters/               # moneda es_AR, kg, %
│   └── widgets/                  # AppScaffold, DataTable base, inputs
├── auth/
│   ├── data/                     # repos de auth/profile
│   ├── application/              # providers de sesión y rol
│   └── presentation/             # login, splash
└── features/
    ├── carga/                    # Módulo de Carga
    ├── precios_rinde/            # Lista de Precios + Rinde (2 paneles)
    ├── pesaje/                   # Pesaje (pestaña por sucursal)
    ├── balance/                  # Balance por sucursal + consolidado
    ├── historial/                # Historial de balances cerrados
    └── configuracion/            # Roles, medios de pago, gastos, cortes, sucursales, rinde
```

Cada feature tiene 3 capas: `data/` (repositorios que hablan con Supabase) · `application/` (providers Riverpod con la lógica) · `presentation/` (pantallas y widgets).

### 3.2 Ruteo y navegación por rol

- `go_router` con un **redirect global** que:
  - Sin sesión → `/login`.
  - Con sesión, según `profiles.rol`:
    - **admin** → acceso a las 6 rutas.
    - **cajera** → solo `/carga`, `/precios-rinde`, `/pesaje`; cualquier otra ruta redirige a `/carga`.
- **Layout**: `NavigationRail` (o Drawer en pantallas chicas) que muestra únicamente los módulos permitidos por rol.

### 3.3 Mapa módulo → pantalla → datos

| Módulo | Pantalla principal | Lee | Escribe |
|---|---|---|---|
| Carga | Selector de período + 3 sub-formularios (ventas/compras/gastos como registros) | periodos, medios_pago, tipos_gasto | ventas, compras, gastos, periodos |
| Lista de Precios + Rinde | 2 paneles lado a lado, tabs por categoría | precios, cortes, categorias | precios (al Guardar) |
| Pesaje | Pestaña por sucursal → tabs categoría → grilla de cortes con campos de peso | cortes, precios/costo, pesajes | pesajes, pesaje_items |
| Balance | Tabla por sucursal (bruto/neto) + consolidado | `fn_balance_periodo`, `fn_consolidado` | cerrar período |
| Historial | Lista de períodos cerrados + detalle | periodos (cerrados), `fn_balance_periodo` | — |
| Configuración | Sub-secciones (usuarios, ventas, compras, gastos, cortes, sucursales, rinde) | todas las de catálogo | catálogos + costos manuales |

### 3.4 Rinde en vivo (detalle técnico)

1. Al abrir "Lista de Precios + Rinde", un provider carga cortes + precios de la categoría.
2. La columna **Nuevo precio** es estado local (Riverpod `StateNotifier`).
3. El provider del **Rinde** *depende* de ese estado: cada tecla recalcula `Σ(kgr × nuevo_precio)`, resultado y %.
4. Recién en **Guardar precios** se persiste (rota `nuevo → actual → ultimo → penultimo`) vía el repositorio.

---

## 4. Migraciones y datos

- Se crea una **migración nueva** (no se edita la vieja ya aplicada) que:
  1. `ALTER`/`UPDATE` sucursales a Don Chacho 1–4.
  2. Borra la categoría Pescado (y sus cortes, si hubiera).
  3. Agrega columnas a `categorias` (pieza base, factor) y `cortes` (valoriza_a, costo_manual).
  4. Crea `medios_pago`, `tipos_gasto`, `periodos`, `ventas`, `compras`, `gastos`.
  5. Agrega `sucursal_id` a `profiles`; `periodo_id`/`momento` a `pesajes`.
  6. Crea/reemplaza vistas y las funciones RPC de balance.
  7. Define las policies RLS de cajera (`mi_sucursal()`).
- Los **KGR y cortes reales** del Excel ya están cargados y se conservan.

---

## 5. Plan de implementación (fases)

| Fase | Entregable | Depende de |
|---|---|---|
| **F0** | Migración DB ajustada + seed correcto (Supabase local corriendo) | análisis cerrado ✓ |
| **F1** | Scaffold Flutter: proyecto, tema, Supabase, auth (login), routing por rol, layout con los 6 módulos vacíos | F0 |
| **F2** | Configuración (catálogos: sucursales, cortes, medios de pago, gastos, rinde/costos) | F1 |
| **F3** | Lista de Precios + Rinde (2 paneles, incremento, rinde en vivo) | F2 |
| **F4** | Pesaje (pestaña por sucursal, valorización) | F2 |
| **F5** | Carga (períodos + ventas/compras/gastos) | F2 |
| **F6** | Balance + consolidado (RPC) | F4, F5 |
| **F7** | Historial de balances | F6 |
| **F8** | Deploy en Vercel + pruebas con datos reales | F1–F7 |

> Cada fase se muestra funcionando antes de pasar a la siguiente (iterativo).

---

## 6. Pendientes menores (no bloquean)

- **% retención de transferencia**: queda configurable en `medios_pago` (arranca en 0).
- **Autenticación de cajeras**: definir si el admin las crea desde Configuración (invita por email) o alta manual en Supabase. Recomendado: alta desde la app con email + rol + sucursal.
- **Backups**: Supabase ya versiona; definir si se exporta el balance a Excel/PDF (posible feature futura).
