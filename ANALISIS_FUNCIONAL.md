# Sistema de Balance — Carnicerías Don Chacho
## Análisis Funcional Completo

> **Estado:** v1.0 — consolidado
> **Fecha:** 2026-09-10
> **Autor:** Mili (con asistencia de Claude)
>
> Este documento **consolida y reemplaza** los borradores previos (`ANALISIS_FUNCIONAL.md` Fase 1 del 27-05 y `Balance System/01-especificacion-funcional.md` del 26-06). La fuente de verdad de datos, precios, rinde y pesajes es el Excel `LISTA PRECIOS Y RINDE CHACHO Y CABAÑA.xlsx`.

---

## 1. Visión general

Cadena de carnicerías **Don Chacho** con **4 sucursales**. Hoy el balance se lleva en Excel: por cada sucursal se pesan todos los cortes, se valorizan por su precio por kilo y, combinado con ventas, compras y gastos, se obtiene el rendimiento de cada sucursal. El objetivo es reemplazar ese Excel por una **aplicación web** que:

- Mantenga la lista de precios con histórico y cálculo de incremento.
- Calcule el **rinde** (rentabilidad estimada del despiece de cada animal).
- Registre **pesajes** de stock por sucursal y los valorice automáticamente.
- Registre **ventas, compras y gastos** por sucursal y período.
- Calcule el **balance/rendimiento por sucursal** y guarde su **historial**.

**Stack:** Flutter Web + Supabase (PostgreSQL, Realtime, Auth) + deploy en Vercel.

---

## 2. Roles y accesos

| Rol | Acceso |
|---|---|
| **Administrador** | Todos los módulos: Carga, Lista de Precios + Rinde, Pesaje, Balance, Historial de Balance y Configuración. Ve las 4 sucursales. |
| **Cajera** | Solo **3 módulos**: Carga, Lista de Precios + Rinde y Pesaje. **No** ve Balance, Historial ni Configuración. Opera únicamente sobre su sucursal asignada. |

---

## 3. Sucursales y categorías

- **Sucursales:** Don Chacho 1, Don Chacho 2, Don Chacho 3, Don Chacho 4.
  *(Los nombres "Chacho 1/2" y "Cabaña del Valle" de versiones previas quedan sin efecto.)*
- **Categorías de producto:** Carne, Cerdo, Pollo.
  *(Pescado queda fuera de alcance por ahora.)*

Cada categoría es independiente en precios, incremento y rinde.

---

## 4. Módulos del sistema

### 4.1 Módulo de Carga

Permite cargar los datos económicos de un período por sucursal. Todos los montos se ingresan como **registros individuales** (cada uno con su fecha y monto); el sistema los suma dentro del rango.

- **Rango de fechas:** el período de balance se define **manualmente** (fecha de inicio y fecha de fin). Ventas, compras, gastos y pesajes se asocian a ese rango.
- **Ventas ($):** cada venta se carga por **medio de pago** (efectivo, crédito, débito, transferencia) con su monto y fecha.
- **Compras ($):** cada compra a proveedor se carga por **tipo** (Carne, Cerdo, Pollo) con monto y fecha.
- **Gastos ($):** cada gasto se carga por **tipo** (luz, agua, internet, etc.) con monto y fecha.

> La cajera carga los datos de **su** sucursal. El administrador puede cargar los de cualquiera.

### 4.2 Módulo de Lista de Precios + Rinde

Pantalla de **dos paneles lado a lado** (igual que el Excel): Lista de Precios a la izquierda y Rinde a la derecha, visibles simultáneamente. Tabs por categoría (Carne | Cerdo | Pollo).

**Panel izquierdo — Lista de Precios.** Por cada corte:

| Columna | Editable | Descripción |
|---|---|---|
| Corte | No | Nombre del corte |
| $ Penúltimo | No | Precio 2 períodos atrás |
| $ Último | No | Precio 1 período atrás |
| $ Actual | No | Precio vigente (base del cálculo; alimenta el pesaje) |
| Calc. con incremento | No | `$ Actual × (1 + incremento%)`, se llena al presionar **Calcular** |
| **Nuevo precio** | **Sí** | Pre-cargado con el valor calculado; el admin lo ajusta a criterio (sube/baja/redondea). Al guardar, pasa a ser el nuevo `$ Actual`. |

**Flujo de incremento:**
1. Arriba de la tabla: campo **Incremento [%]** + botón **Calcular** (aplica a toda la categoría).
2. Al presionar **Calcular**, se llena la columna *Calc. con incremento* = `$ Actual × (1 + %)`.
3. La columna **Nuevo precio** se pre-carga con esos valores y queda **editable**: el admin sube, baja o redondea cada precio según su criterio.
4. La columna **Nuevo precio** alimenta el **Rinde en tiempo real** (simula la rentabilidad antes de confirmar).
5. Al presionar **Guardar precios**: `Nuevo precio → $ Actual`, `$ Actual → $ Último`, `$ Último → $ Penúltimo`. Se conservan siempre los últimos 3 precios.

- El **incremento sugerido por categoría** se puede parametrizar en Configuración (ej. Carne +5%, Pollo +7%), pero el admin puede ingresar cualquier % en el momento.

**Panel derecho — Rinde.** Un rinde por categoría, que simula la rentabilidad del despiece del animal:

- Cada categoría define una **pieza base** con su **costo**: `kg de la pieza × $/kg de compra` (ej. Media Res 111 kg × $10.400).
  - Carne → **Media Res**; Cerdo → **Media Cerdo**; Pollo → **Caja de Pollo**.
- Cada corte tiene un **KGR** (kg que rinde del animal) y un **Precio** tomado en vivo del `$ Actual` de la lista.
- `Total del corte = KGR × Precio`.
- Pie del cuadro (4 valores):
  - **Kg Rinde total** = Σ KGR (kilos totales que rindió el despiece; ej. 108,795 kg).
  - **Ingreso del despiece** = Σ (KGR × Precio) (lo que se recauda vendiendo todos los cortes; ej. $1.382.260,65).
  - **Resultado del rinde ($)** = Ingreso del despiece − Costo de la pieza (ej. $1.382.260,65 − $1.154.400 = $227.860,65).
  - **% de rinde** = Resultado del rinde / Costo de la pieza (ej. 19,74 %).

> **Tiempo real:** al editar `$ Actual` en la lista, el rinde se recalcula instantáneamente (permite simular rentabilidad antes de confirmar precios).

### 4.3 Módulo de Pesaje

Registra el stock físico de cada sucursal y lo valoriza. Se hace **dentro de un período** (rango de fechas):

- Al **inicio** del período (ej. 10 de septiembre), los carniceros de cada sucursal pesan cada corte → **stock inicial**.
- Al **cierre** del período (ej. 8 de octubre), se vuelve a pesar → **stock final**, que es a su vez el **stock inicial del período siguiente** (encadenado).
- Es decir, hay **2 pesajes por período** (apertura y cierre), y el pesaje de cierre sirve de apertura del próximo.

**Contenido de la pantalla:**

- **Layout:** una **pestaña por sucursal** (Don Chacho 1..4); dentro, tabs por categoría (Carne | Cerdo | Pollo). La **cajera puede ver todas las sucursales**.
- Cada corte × sucursal admite **varios campos de peso** (ej. cámara de frío + batea); botón para **agregar peso**. `Total kg del corte = Σ pesos`.
- **Precio:** se toma automáticamente de la lista (`$ Actual`), no editable acá.
  - Los **cortes individuales** se valorizan a **precio de venta** de la lista.
  - Las **piezas enteras** (Media Res, Octavo, Costillar, Caja de Pollo, Pierna) se valorizan a **precio de costo**, que se **carga manualmente** en Configuración.
- `Total por corte = Total kg × Precio`.
- **Totales:** por categoría, por sucursal (**valor de stock de la sucursal**) y total general de todas las sucursales.

> El valor de stock de un pesaje es el insumo para el CMV del balance (stock inicial y stock final del período).

### 4.4 Módulo de Balance

Calcula el resultado de cada sucursal en el período (rango de fechas). **Todos los campos se completan automáticamente** con lo registrado en el Módulo de Carga (ventas, compras, gastos) y el Módulo de Pesaje (stock). Cada sucursal muestra dos columnas: **Ingresos Brutos** y **Cálculo Neto**, con esta estructura:

| Concepto | Bruto | Neto (para el cálculo) |
|---|---|---|
| **Ventas en efectivo** | monto | = monto (retención 0%) |
| **Ventas por transferencia** | monto | = monto × (1 − % retención) |
| **Ventas con crédito** | monto | = monto × (1 − % retención) |
| **Ventas con débito** | monto | = monto × (1 − % retención) |
| **Total ventas** | Σ brutos | Σ netos |
| **Compras Proveedores** | monto (total) | (entra en el CMV) |
| **Stock inicial** | del pesaje de apertura | |
| **Stock final** | del pesaje de cierre | |
| **CMV** | `Stock inicial + Compras − Stock final` | |
| **Gastos** (Rentas, Contador, Varios [sueldos/luz/alquiler], Saldos sueldos) | monto c/u | |
| **Ganancia** | | `Total ventas neto − CMV − Σ Gastos` |
| **Utilidad neta %** | | `Ganancia / Total ventas neto` |

- El **stock** (inicial y final) sale del **Módulo de Pesaje**: el stock final de un período es el stock inicial del siguiente (encadenado). El primer período de una sucursal se carga con un stock inicial manual.
- **Medios de pago:** efectivo, transferencia, crédito y débito, cada uno con su **% de retención** parametrizable (hoy: efectivo 0%, crédito/débito 12%; transferencia a definir).
- **Compras Proveedores** se muestra como **total** (aunque en la carga se discriminen por tipo Carne/Cerdo/Pollo).
- Los **gastos** se muestran discriminados por tipo y se suman.
- Se muestra por cada sucursal y un **consolidado** comparativo de las 4.

> Equivalencia contable: `Ganancia = Ventas netas − CMV − Gastos` ≡ `Ventas netas − Compras − Gastos + (Stock final − Stock inicial)`.

### 4.5 Módulo de Historial de Balance

- Lista de balances de períodos **cerrados**, por sucursal.
- Permite consultar cualquier período histórico (rango, ventas, compras, CMV, gastos, rendimiento).
- Los históricos no se alteran al cambiar precios vigentes (se guarda el snapshot de precios del pesaje).

### 4.6 Módulo de Configuración (solo admin)

- **Roles de usuarios:** crear cajeras, asignarlas a una sucursal, definir admin.
- **Parametrización de ventas:** medios de pago (efectivo, transferencia, crédito, débito) con su **% de descuento/retención** (hoy efectivo 0%, crédito/débito 12%, transferencia a definir).
- **Parametrización de compras a proveedores:** tipos Carne, Cerdo, Pollo.
- **Parametrización de gastos:** tipos (Rentas, Contador, Gastos varios [sueldos, luz, alquiler], Saldos de sueldos, agua, internet, etc.).
- **Parametrización de cortes** por categoría (alta/baja/edición, KGR de rinde, orden).
- **Parametrización de sucursales** (alta/baja/edición).
- **Parametrización del rinde:** pieza base y costo por categoría (kg y $/kg), factor de incremento por categoría.
- **Precio de costo de piezas enteras** (Media Res, Octavo, Costillar, Pierna, Caja de Pollo): **carga manual**, usado para valorizar esas piezas en el pesaje.

---

## 5. Reglas de negocio (fórmulas)

```
Valor de stock (pesaje)   = Σ ( Σ pesos del corte × precio del corte )
Venta neta del medio      = monto bruto × ( 1 − % retención del medio )
Venta neta total          = Σ venta neta de cada medio
CMV                       = Stock inicial + Compras − Stock final
Ganancia sucursal         = Venta neta total − CMV − Σ Gastos
Utilidad neta %           = Ganancia / Venta neta total
Costo de la pieza base    = kg de la pieza × $/kg de compra
Ingreso del despiece      = Σ ( KGR del corte × $ Actual del corte )
Resultado del rinde ($)   = Ingreso del despiece − Costo de la pieza base
% de rinde                = Resultado del rinde / Costo de la pieza base
```

- **Encadenado de stock:** el stock final de un período es el stock inicial del siguiente.
- **Primer período de una sucursal:** el stock inicial se carga manualmente (no hay pesaje anterior).
- Los cálculos se **derivan** de los datos cargados; no se editan a mano.

---

## 6. Modelo de datos conceptual

> Ajustar la DB actual a este modelo (ver §7 discrepancias).

- **profiles** — usuario: nombre, rol (admin | cajera), sucursal asignada (solo cajera).
- **sucursales** — Don Chacho 1..4, orden, activo.
- **categorias** — Carne, Cerdo, Pollo; factor de incremento; datos de pieza base (nombre, kg, $/kg de costo) para el rinde.
- **cortes** — categoría, nombre, KGR de rinde, activo, orden.
- **precios** — corte (único), precio_actual, precio_ultimo, precio_penultimo, actualizado_at.
- **medios_pago** — nombre, % retención. *(config ventas)*
- **tipos_gasto** — nombre. *(config gastos)*
- **periodos / balances** — sucursal, fecha_inicio, fecha_fin, estado (abierto | cerrado).
- **ventas** — período, sucursal, fecha, medio_pago, monto.
- **compras** — período, sucursal, fecha, tipo (Carne|Cerdo|Pollo), monto, proveedor (opcional).
- **gastos** — período, sucursal, fecha, tipo_gasto, monto.
- **pesajes** — sucursal, fecha, corte, precio_snapshot (precio al momento).
- **pesaje_items** — pesaje, kg (varios por corte).

---

## 7. Discrepancias con la base de datos actual (a corregir)

La migración existente (`supabase/migrations/20260527000000_initial_schema.sql`) fue hecha para la Fase 1 y necesita ajustes:

1. **Categorías:** quitar **Pescado**.
2. **Sucursales:** renombrar a **Don Chacho 1, 2, 3, 4** (hoy figuran "Chacho 1/2", "Cabaña del Valle").
3. **Cortes:** reemplazar el seed por la lista real del Excel (Carne, Cerdo, Pollo), que es más amplia y distinta.
4. **Rinde:** agregar a `categorias` la **pieza base** (kg y $/kg de costo). `cortes.kgr_rinde` (único por corte) se mantiene — alcanza con un rinde por categoría.
5. **Incremento:** guardar el **factor por categoría** (ej. 1.05, 1.07).
6. **Nuevas tablas:** `medios_pago`, `tipos_gasto`, `periodos/balances`, `ventas`, `compras`, `gastos`.
7. **Precio de costo vs venta en pesaje:** distinguir cortes valorizados a costo (piezas enteras) de los valorizados a precio de venta.

---

## 8. Preguntas abiertas (pendientes de definir)

**Resueltas** (con el Excel de balance):
- ✅ Fórmula de CMV/ganancia: `Ganancia = Ventas netas − CMV − Gastos`, con `CMV = Stock inicial + Compras − Stock final`. Se agrega **Utilidad neta %** = Ganancia / Ventas netas.
- ✅ Stock inicial: encadenado del período anterior; el primero se carga a mano.
- ✅ Retención vigente: efectivo 0%, crédito/débito 12%. **Todos los medios son parametrizables** en Configuración; transferencia arranca con valor provisorio y se ajusta cuando el admin lo defina.
- ✅ Frecuencia del pesaje: 2 por período (apertura = stock inicial, cierre = stock final = apertura del siguiente).
- ✅ Layout Lista de Precios: dos paneles lado a lado; incremento con botón Calcular + columna editable "Nuevo precio".
- ✅ Precio de costo de piezas enteras en el pesaje: **carga manual** en Configuración.
- ✅ Layout del pesaje: una **pestaña por sucursal**; la cajera puede ver todas.
- ✅ Medios de pago: efectivo, transferencia, crédito, débito (cada uno con su % de retención).
- ✅ Balance: se completa automáticamente desde Carga y Pesaje; Compras se muestra como total.
- ✅ Mermas: no se registran aparte; quedan capturadas en el stock final medido en el pesaje.

**Todavía pendientes:**
- Ninguna. El análisis funcional está **cerrado**. (El % de retención de transferencia se define en Configuración cuando el admin lo tenga; no bloquea el diseño.)

---

## 9. Fuera de alcance (v1)

- Pescado.
- Facturación electrónica / AFIP.
- Sueldos y liquidaciones.
- Integración con balanzas o lectores de tarjeta.
- App móvil nativa (se prioriza web).
