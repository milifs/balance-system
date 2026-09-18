# Especificación Funcional — Sistema de Balance de Carnicerías

> **Metodología:** Spec Driven Development (SDD). Este documento es la *especificación* (el "qué"). El diseño técnico y el plan de implementación (el "cómo") se desarrollan en documentos posteriores, una vez validado este.
>
> **Estado:** Borrador v0.1 — para revisión
> **Fecha:** 2026-06-26
> **Autor:** Mili (con asistencia de Claude)

---

## 1. Visión general

### 1.1 Problema actual
El negocio (cadena de carnicerías con varias sucursales) lleva hoy el balance en planillas de Excel. Por cada sucursal se realiza un pesaje de todos los cortes de carne, se valoriza por su precio por kilo y, combinado con ventas, gastos y compras, se obtiene el rendimiento de cada sucursal. El proceso manual en Excel es propenso a errores, difícil de consolidar entre sucursales y depende de una sola persona.

### 1.2 Objetivo del sistema
Construir una **aplicación web** que permita:
- Registrar el pesaje de mercadería por sucursal y valorizarlo automáticamente.
- Registrar ventas (por medio de pago), gastos y compras a proveedores por período.
- Calcular automáticamente el **rendimiento de cada sucursal** por período.
- Consolidar y comparar el desempeño entre sucursales.

### 1.3 Alcance de este documento
Análisis funcional completo: actores, datos, reglas de negocio, requerimientos funcionales y no funcionales, flujos y preguntas abiertas. **No** incluye todavía decisiones de tecnología, base de datos ni diseño de pantallas.

---

## 2. Glosario de dominio

| Término | Definición |
|---|---|
| **Sucursal** | Cada local físico de carnicería que se balancea de forma independiente. |
| **Corte** | Tipo de producto cárnico (ej.: asado, vacío, peceto, pollo). Tiene un precio por kilo. |
| **Pesaje** | Acto de pesar el stock de cada corte en una sucursal en una fecha dada. Es lo que abre/cierra un período. |
| **Período** | Lapso de tiempo entre dos pesajes consecutivos de una sucursal. El balance se cierra **el día del pesaje** (fecha variable, aproximadamente mensual). |
| **Valor de mercadería (stock)** | Suma de `kg pesados × $/kg` de todos los cortes de una sucursal en un pesaje. |
| **Variación de stock** | Diferencia entre el valor de mercadería al cierre y al inicio del período. |
| **Medio de pago** | Forma en que ingresa la venta: efectivo, transferencia, tarjeta de crédito, tarjeta de débito. |
| **Retención** | Porcentaje que el medio de pago (o el fisco/procesador) descuenta de la venta bruta. |
| **Venta neta** | Venta bruta menos las retenciones aplicables. |
| **Gastos** | Erogaciones operativas de la sucursal (luz, internet, etc.). |
| **Compras a proveedores** | Mercadería comprada para reponer stock durante el período. |
| **Rendimiento** | Resultado económico de la sucursal en el período. |

---

## 3. Actores y roles

### 3.1 Administrador
- Es el dueño/responsable (tu marido).
- Crea y configura sucursales, cortes y precios por kilo.
- Configura los porcentajes de retención por medio de pago.
- Puede cargar todos los datos de cualquier sucursal.
- Ve el rendimiento de **todas** las sucursales y la comparación consolidada.
- Abre y cierra períodos.

### 3.2 Cajera (una o varias por sucursal)
- Está asignada a **una** sucursal.
- Carga, **para su sucursal y el período en curso**:
  - Monto de mercadería vendida, discriminado por medio de pago.
  - Gastos varios (luz, internet, etc.).
  - Compras a proveedores.
  - Pesajes de los cortes de carne.
- No ve datos ni rendimientos de otras sucursales (a confirmar — ver §9).

> **Regla de acceso:** la cajera solo opera sobre su propia sucursal; el administrador opera sobre todas.

---

## 4. Modelo de datos (entidades)

> Descripción conceptual de la información a guardar. No es un esquema de base de datos todavía.

### 4.1 Sucursal
- Identificador, nombre, dirección (opcional), estado (activa/inactiva).

### 4.2 Usuario
- Identificador, nombre, rol (Administrador | Cajera), sucursal asignada (solo cajeras).

### 4.3 Corte
- Identificador, nombre, **precio por kilo vigente** ($/kg).
- Histórico de precios (para no perder el valor que tenía en pesajes anteriores).

### 4.4 Período
- Sucursal, fecha de inicio (= fecha del pesaje anterior), fecha de cierre (= fecha del pesaje actual), estado (abierto | cerrado).

### 4.5 Pesaje
- Sucursal, fecha, y por cada corte: kilos pesados y el $/kg aplicado en ese momento.
- Valor total del pesaje = Σ (kg × $/kg).

### 4.6 Venta del período
- Sucursal, período, y monto **por medio de pago**: efectivo, transferencia, tarjeta crédito, tarjeta débito.
- (A definir: si se carga un único total por período o desglosado por día — ver §9.)

### 4.7 Gasto
- Sucursal, período, concepto (luz, internet, etc.), monto, fecha.

### 4.8 Compra a proveedor
- Sucursal, período, proveedor (opcional), monto, fecha.

### 4.9 Configuración de retenciones
- Por medio de pago: porcentaje de retención. Editable por el Administrador.
- (Detalle de impuestos/comisiones extra: a definir — ver §9.)

---

## 5. Reglas de negocio

### 5.1 Valorización del stock
Para un pesaje:

```
Valor de mercadería = Σ ( kilos del corte × $/kg del corte )
```

El `$/kg` que se usa es el vigente al momento del pesaje (se guarda histórico para no alterar pesajes pasados al cambiar precios).

### 5.2 Variación de stock del período

```
Variación de stock = Valor de mercadería (pesaje de cierre)
                   − Valor de mercadería (pesaje de inicio)
```

- En el **primer período** de una sucursal no hay pesaje de inicio: el valor inicial se toma como un **stock inicial de apertura** (a cargar manualmente) o como cero. Ver §9.

### 5.3 Venta neta (aplicación de retenciones)
Por cada medio de pago:

```
Venta neta del medio = Monto bruto del medio × ( 1 − % retención del medio )
```

```
Venta neta total = Σ ( Venta neta de cada medio )
```

- El efectivo normalmente tiene retención 0%. Transferencia y tarjetas tienen el porcentaje configurado. **Los porcentajes están a definir** (ver §9).

### 5.4 Rendimiento de la sucursal en el período
**Fórmula principal:**

```
Rendimiento = Venta neta total − Compras a proveedores − Gastos + Variación de stock
```

**Fundamento contable (verificación):** esta fórmula equivale al resultado clásico de comercio:

```
Resultado = Ventas − Costo de Mercadería Vendida (CMV) − Gastos
CMV       = Stock inicial + Compras − Stock final
```

Sustituyendo y reordenando:

```
Resultado = Ventas − (Stock inicial + Compras − Stock final) − Gastos
          = Ventas − Compras − Gastos + (Stock final − Stock inicial)
          = Ventas − Compras − Gastos + Variación de stock   ✓
```

Es decir, la opción elegida ("ventas netas − compras − gastos + variación de stock") es **contablemente consistente** con el costo de la mercadería efectivamente vendida.

### 5.5 Consolidado
El rendimiento total del negocio en un período es la suma de los rendimientos de cada sucursal cuyos períodos cierren en ese rango.

---

## 6. Requerimientos funcionales (RF)

### Gestión y configuración
- **RF-01** El administrador puede crear, editar y desactivar sucursales.
- **RF-02** El administrador puede crear cajeras y asignarlas a una sucursal.
- **RF-03** El administrador puede administrar el catálogo de cortes y su $/kg, conservando histórico de precios.
- **RF-04** El administrador puede configurar el % de retención por medio de pago.

### Carga de datos (cajera y administrador)
- **RF-05** Registrar un pesaje de la sucursal: kilos por corte; el sistema valoriza automáticamente.
- **RF-06** Registrar ventas del período por medio de pago.
- **RF-07** Registrar gastos del período (concepto y monto).
- **RF-08** Registrar compras a proveedores del período.

### Períodos y cálculo
- **RF-09** El sistema determina el período por la fecha del pesaje (cierre del período actual / apertura del siguiente).
- **RF-10** El sistema calcula automáticamente: valor de stock, variación de stock, venta neta y rendimiento.
- **RF-11** El administrador puede cerrar un período; una vez cerrado, queda como registro histórico.

### Visualización
- **RF-12** La cajera ve el estado y rendimiento de su propia sucursal en el período en curso.
- **RF-13** El administrador ve el rendimiento de todas las sucursales y un consolidado comparativo.
- **RF-14** El sistema permite consultar períodos históricos por sucursal.

---

## 7. Flujos principales

### 7.1 Cierre de período (pesaje)
1. Llega el día del pesaje (fecha variable).
2. La cajera (o el administrador) carga los kilos de cada corte → el sistema valoriza el stock de cierre.
3. El sistema toma el stock de inicio (pesaje anterior) y calcula la variación de stock.
4. El sistema toma ventas, gastos y compras cargados en el período.
5. El sistema calcula el rendimiento y muestra el resultado.
6. El administrador revisa y cierra el período. Se abre automáticamente el siguiente.

### 7.2 Carga diaria/periódica (cajera)
1. La cajera ingresa a su sucursal.
2. Registra ventas por medio de pago, gastos y compras a medida que ocurren en el período.
3. Los montos se acumulan en el período abierto.

---

## 8. Requerimientos no funcionales

- **Acceso por roles:** el sistema distingue administrador y cajera, y restringe los datos por sucursal.
- **Usabilidad:** pensado para personas no técnicas (cajeras); carga simple y clara.
- **Web y multiusuario:** accesible desde navegador; varias cajeras pueden cargar en paralelo.
- **Trazabilidad:** se conserva el histórico de pesajes, precios y períodos cerrados sin alterarlos.
- **Integridad:** los cálculos no se editan a mano; se derivan de los datos cargados.

---

## 9. Preguntas abiertas (pendientes de definir)

Estas decisiones afectan el diseño y conviene cerrarlas antes de la fase de implementación:

1. **Porcentajes de retención:** ¿qué valor tiene cada medio (transferencia, crédito, débito)? ¿Hay impuestos o comisiones extra además de la retención del medio de pago?
2. **Granularidad de ventas:** ¿la cajera carga un total por período, o día a día / por turno y el sistema acumula?
3. **Stock inicial de apertura:** ¿cómo se valoriza el primer período de cada sucursal (carga manual del stock inicial, o arranca en cero)?
4. **Visibilidad de la cajera:** ¿la cajera ve el rendimiento final de su sucursal, o solo carga datos y el administrador ve resultados?
5. **Mermas/diferencias:** ¿se contempla pérdida de peso de la carne, mermas o ajustes que expliquen diferencias de stock no vendidas?
6. **Migración:** ¿hay un Excel actual para tomar como base exacta de la fórmula y los cortes? (Recomendado subirlo.)

---

## 10. Fuera de alcance (v1)

- Facturación electrónica / integración con AFIP.
- Gestión de empleados, sueldos o liquidaciones.
- Integración directa con balanzas o lectores de tarjeta.
- App móvil nativa (se prioriza web).

---

## 11. Próximos pasos (SDD)

1. **Validar esta especificación** con tu marido y cerrar las preguntas abiertas de §9.
2. **Documento de diseño técnico:** modelo de datos detallado, tecnología y arquitectura.
3. **Plan de implementación:** tareas, prioridades y entregables.
4. **Construcción iterativa** de la app web.
