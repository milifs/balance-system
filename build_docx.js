const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType,
  Table, TableRow, TableCell, WidthType, BorderStyle, ShadingType,
  TableOfContents, PageBreak, LevelFormat, Footer, PageNumber,
} = require("docx");

// ---------- Paleta ----------
const RED = "8B1E1E";       // rojo carnicería (títulos)
const DARK = "1A1A1A";
const GREY = "555555";
const LIGHT = "F3ECEC";     // fondo de encabezados de tabla
const ZEBRA = "FAF6F6";     // filas alternas
const ACCENT = "B23A3A";

// ---------- Helpers ----------
const H1 = (text) => new Paragraph({
  heading: HeadingLevel.HEADING_1,
  spacing: { before: 320, after: 140 },
  children: [new TextRun({ text, bold: true, color: RED, size: 30 })],
});
const H2 = (text) => new Paragraph({
  heading: HeadingLevel.HEADING_2,
  spacing: { before: 240, after: 100 },
  children: [new TextRun({ text, bold: true, color: ACCENT, size: 24 })],
});
const P = (runs, opts = {}) => new Paragraph({
  spacing: { after: 100, line: 276 },
  children: Array.isArray(runs) ? runs : [new TextRun({ text: runs, size: 21, color: DARK })],
  ...opts,
});
const T = (text, o = {}) => new TextRun({ text, size: 21, color: DARK, ...o });

function bullet(runs) {
  return new Paragraph({
    numbering: { reference: "vinetas", level: 0 },
    spacing: { after: 60, line: 268 },
    children: Array.isArray(runs) ? runs : [new TextRun({ text: runs, size: 21, color: DARK })],
  });
}

function callout(text) {
  return new Paragraph({
    spacing: { before: 100, after: 140, line: 276 },
    shading: { type: ShadingType.CLEAR, color: "auto", fill: LIGHT },
    border: {
      left: { style: BorderStyle.SINGLE, size: 18, color: RED, space: 8 },
      top: { style: BorderStyle.SINGLE, size: 2, color: LIGHT, space: 6 },
      bottom: { style: BorderStyle.SINGLE, size: 2, color: LIGHT, space: 6 },
      right: { style: BorderStyle.SINGLE, size: 2, color: LIGHT, space: 6 },
    },
    children: Array.isArray(text) ? text : [new TextRun({ text, italics: true, size: 21, color: GREY })],
  });
}

// Tabla genérica: headers = [str], rows = [[cell,...]], widths en DXA
function makeTable(headers, rows, widths) {
  const total = widths.reduce((a, b) => a + b, 0);
  const headerRow = new TableRow({
    tableHeader: true,
    children: headers.map((h, i) => new TableCell({
      width: { size: widths[i], type: WidthType.DXA },
      shading: { type: ShadingType.CLEAR, color: "auto", fill: RED },
      margins: { top: 60, bottom: 60, left: 90, right: 90 },
      children: [new Paragraph({ children: [new TextRun({ text: h, bold: true, color: "FFFFFF", size: 20 })] })],
    })),
  });
  const bodyRows = rows.map((cells, r) => new TableRow({
    children: cells.map((c, i) => new TableCell({
      width: { size: widths[i], type: WidthType.DXA },
      shading: { type: ShadingType.CLEAR, color: "auto", fill: r % 2 ? ZEBRA : "FFFFFF" },
      margins: { top: 50, bottom: 50, left: 90, right: 90 },
      children: (Array.isArray(c) ? c : [c]).map((line, idx) =>
        new Paragraph({
          children: [new TextRun({
            text: typeof line === "string" ? line : line.text,
            bold: typeof line === "object" && line.bold,
            size: 19,
            color: DARK,
          })],
          spacing: { after: idx === (Array.isArray(c) ? c.length - 1 : 0) ? 0 : 40 },
        })
      ),
    })),
  }));
  return new Table({
    columnWidths: widths,
    width: { size: total, type: WidthType.DXA },
    rows: [headerRow, ...bodyRows],
    borders: {
      top: { style: BorderStyle.SINGLE, size: 2, color: "D9C9C9" },
      bottom: { style: BorderStyle.SINGLE, size: 2, color: "D9C9C9" },
      left: { style: BorderStyle.SINGLE, size: 2, color: "D9C9C9" },
      right: { style: BorderStyle.SINGLE, size: 2, color: "D9C9C9" },
      insideHorizontal: { style: BorderStyle.SINGLE, size: 2, color: "E6DADA" },
      insideVertical: { style: BorderStyle.SINGLE, size: 2, color: "E6DADA" },
    },
  });
}

// Bloque de fórmula (monospace, fondo suave)
function formula(lines) {
  return lines.map((ln, i) => new Paragraph({
    spacing: { after: i === lines.length - 1 ? 120 : 0, before: i === 0 ? 60 : 0 },
    shading: { type: ShadingType.CLEAR, color: "auto", fill: "F5F2EE" },
    children: [new TextRun({ text: ln, font: "Consolas", size: 19, color: "3A2A2A" })],
  }));
}

const spacer = () => new Paragraph({ spacing: { after: 60 }, children: [] });

// ================= PORTADA =================
const cover = [
  new Paragraph({ spacing: { before: 1400 }, children: [] }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 60 },
    children: [new TextRun({ text: "CARNICERÍAS DON CHACHO", bold: true, color: ACCENT, size: 28, allCaps: true })],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: RED, space: 10 } },
    spacing: { after: 260 },
    children: [new TextRun({ text: "", size: 2 })],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 120 },
    children: [new TextRun({ text: "Sistema de Balance", bold: true, color: RED, size: 60 })],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 400 },
    children: [new TextRun({ text: "Análisis Funcional Completo", color: DARK, size: 32 })],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 60 },
    children: [new TextRun({ text: "Documento para revisión y validación", italics: true, color: GREY, size: 22 })],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 900, after: 40 },
    children: [new TextRun({ text: "Versión 1.0  ·  Septiembre 2026", color: DARK, size: 20 })],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "4 sucursales  ·  Categorías: Carne, Cerdo, Pollo", color: GREY, size: 18 })],
  }),
  new Paragraph({ children: [new PageBreak()] }),
];

// ================= ÍNDICE =================
const toc = [
  new Paragraph({ spacing: { after: 160 }, children: [new TextRun({ text: "Contenido", bold: true, color: RED, size: 30 })] }),
  new TableOfContents("Contenido", { hyperlink: true, headingStyleRange: "1-2" }),
  new Paragraph({ children: [new PageBreak()] }),
];

// ================= CUERPO =================
const body = [];

// Nota introductoria
body.push(callout([
  new TextRun({ text: "Para qué sirve este documento. ", bold: true, size: 21, color: RED }),
  new TextRun({ text: "Describe, en lenguaje de negocio, todo lo que hará el sistema de balance que reemplazará las planillas de Excel. El objetivo es revisarlo juntos y confirmar que cubre todas las necesidades antes de empezar a construir la aplicación.", italics: true, size: 21, color: GREY }),
]));

// 1. Visión general
body.push(H1("1. Visión general"));
body.push(P("Cadena de carnicerías Don Chacho con 4 sucursales. Hoy el balance se lleva en Excel: por cada sucursal se pesan todos los cortes, se valorizan por su precio por kilo y, combinado con ventas, compras y gastos, se obtiene el rendimiento de cada sucursal. El objetivo es reemplazar ese Excel por una aplicación web que:"));
body.push(bullet("Mantenga la lista de precios con histórico y cálculo de incremento."));
body.push(bullet("Calcule el rinde (rentabilidad estimada del despiece de cada animal)."));
body.push(bullet("Registre pesajes de stock por sucursal y los valorice automáticamente."));
body.push(bullet("Registre ventas, compras y gastos por sucursal y período."));
body.push(bullet("Calcule el balance/rendimiento por sucursal y guarde su historial."));
body.push(callout([
  new TextRun({ text: "Ventaja clave: ", bold: true, size: 21, color: RED }),
  new TextRun({ text: "todo se calcula automáticamente a partir de lo que se carga; no hay que rehacer fórmulas ni copiar entre planillas, y las 4 sucursales se consolidan solas.", italics: true, size: 21, color: GREY }),
]));

// 2. Roles
body.push(H1("2. Roles y accesos"));
body.push(P("El sistema distingue dos tipos de usuario, cada uno con acceso a distintos módulos:"));
body.push(makeTable(
  ["Rol", "Qué puede hacer"],
  [
    ["Administrador", "Accede a todos los módulos: Carga, Lista de Precios + Rinde, Pesaje, Balance, Historial de Balance y Configuración. Ve las 4 sucursales y el consolidado."],
    ["Cajera", "Accede solo a 3 módulos: Carga, Lista de Precios + Rinde y Pesaje. No ve Balance, Historial ni Configuración. Opera sobre su sucursal (en Pesaje puede ver todas)."],
  ],
  [2200, 6800]
));

// 3. Sucursales y categorías
body.push(H1("3. Sucursales y categorías"));
body.push(bullet([T("Sucursales: ", { bold: true }), T("Don Chacho 1, Don Chacho 2, Don Chacho 3, Don Chacho 4.")]));
body.push(bullet([T("Categorías de producto: ", { bold: true }), T("Carne, Cerdo y Pollo. (Pescado queda fuera de alcance por ahora.)")]));
body.push(P("Cada categoría es independiente en precios, incremento y rinde."));

// 4. Módulos
body.push(H1("4. Módulos del sistema"));
body.push(P("El sistema se organiza en 6 módulos:"));

// 4.1 Carga
body.push(H2("4.1  Módulo de Carga"));
body.push(P("Permite cargar los datos económicos de un período por sucursal. Todos los montos se ingresan como registros individuales (cada uno con su fecha y monto); el sistema los suma dentro del rango elegido."));
body.push(bullet([T("Rango de fechas: ", { bold: true }), T("el período de balance se define manualmente (fecha de inicio y de fin). Ventas, compras, gastos y pesajes se asocian a ese rango.")]));
body.push(bullet([T("Ventas ($): ", { bold: true }), T("cada venta se carga por medio de pago (efectivo, crédito, débito, transferencia) con su monto y fecha.")]));
body.push(bullet([T("Compras ($): ", { bold: true }), T("cada compra a proveedor se carga por tipo (Carne, Cerdo, Pollo) con monto y fecha.")]));
body.push(bullet([T("Gastos ($): ", { bold: true }), T("cada gasto se carga por tipo (luz, agua, internet, etc.) con monto y fecha.")]));
body.push(callout("La cajera carga los datos de su sucursal. El administrador puede cargar los de cualquiera."));

// 4.2 Lista de precios + rinde
body.push(H2("4.2  Módulo de Lista de Precios + Rinde"));
body.push(P("Pantalla de dos paneles lado a lado (igual que el Excel): Lista de Precios a la izquierda y Rinde a la derecha, visibles al mismo tiempo. Con pestañas por categoría (Carne | Cerdo | Pollo)."));
body.push(P([T("Panel izquierdo — Lista de Precios. ", { bold: true, color: ACCENT }), T("Por cada corte:")]));
body.push(makeTable(
  ["Columna", "Editable", "Descripción"],
  [
    ["Corte", "No", "Nombre del corte"],
    ["$ Penúltimo", "No", "Precio de 2 períodos atrás"],
    ["$ Último", "No", "Precio del período anterior"],
    ["$ Actual", "No", "Precio vigente (base del cálculo; alimenta el pesaje)"],
    ["Calc. con incremento", "No", "$ Actual × (1 + incremento%); se llena al presionar Calcular"],
    ["Nuevo precio", "Sí", "Pre-cargado con el valor calculado; el admin lo ajusta (sube/baja/redondea). Al guardar pasa a ser el nuevo $ Actual."],
  ],
  [2200, 1200, 5600]
));
body.push(P([T("Flujo de incremento:", { bold: true })]));
body.push(bullet("Arriba de la tabla: campo Incremento [%] + botón Calcular (aplica a toda la categoría)."));
body.push(bullet("Al presionar Calcular se llena la columna Calc. con incremento = $ Actual × (1 + %)."));
body.push(bullet("La columna Nuevo precio se pre-carga con esos valores y queda editable: el admin sube, baja o redondea cada precio según su criterio."));
body.push(bullet("La columna Nuevo precio alimenta el Rinde en tiempo real (permite simular la rentabilidad antes de confirmar)."));
body.push(bullet("Al Guardar precios: Nuevo precio → $ Actual, $ Actual → $ Último, $ Último → $ Penúltimo. Siempre se conservan los últimos 3 precios."));
body.push(P([T("Panel derecho — Rinde. ", { bold: true, color: ACCENT }), T("Un rinde por categoría, que simula la rentabilidad del despiece del animal:")]));
body.push(bullet([T("Cada categoría define una pieza base con su costo: ", {}), T("kg de la pieza × $/kg de compra (ej. Media Res 111 kg × $10.400).", { bold: true })]));
body.push(bullet("Carne → Media Res; Cerdo → Media Cerdo; Pollo → Caja de Pollo."));
body.push(bullet("Cada corte tiene un KGR (kg que rinde del animal) y un Precio tomado en vivo del $ Actual de la lista. Total del corte = KGR × Precio."));
body.push(P([T("Al pie del cuadro se muestran 4 valores (con el ejemplo de Media Res):", { bold: true })]));
body.push(makeTable(
  ["Valor", "Cómo se calcula", "Ejemplo"],
  [
    ["Kg Rinde total", "Σ de los KGR de todos los cortes", "108,795 kg"],
    ["Ingreso del despiece", "Σ (KGR × Precio)", "$1.382.260,65"],
    ["Resultado del rinde ($)", "Ingreso del despiece − Costo de la pieza", "$227.860,65"],
    ["% de rinde", "Resultado del rinde / Costo de la pieza", "19,74 %"],
  ],
  [2400, 4200, 2400]
));
body.push(callout("Tiempo real: al editar $ Actual en la lista, el rinde se recalcula al instante. Sirve para simular la rentabilidad antes de confirmar los precios nuevos."));

// 4.3 Pesaje
body.push(H2("4.3  Módulo de Pesaje"));
body.push(P("Registra el stock físico de cada sucursal y lo valoriza. Se hace dentro de un período (rango de fechas):"));
body.push(bullet([T("Al inicio del período (ej. 10 de septiembre), los carniceros de cada sucursal pesan cada corte → ", {}), T("stock inicial", { bold: true }), T(".")]));
body.push(bullet([T("Al cierre (ej. 8 de octubre) se vuelve a pesar → ", {}), T("stock final", { bold: true }), T(", que es a su vez el stock inicial del período siguiente (encadenado).")]));
body.push(bullet("Es decir, hay 2 pesajes por período (apertura y cierre); el de cierre sirve de apertura del próximo."));
body.push(P([T("Contenido de la pantalla:", { bold: true })]));
body.push(bullet([T("Layout: ", { bold: true }), T("una pestaña por sucursal (Don Chacho 1..4); dentro, tabs por categoría. La cajera puede ver todas las sucursales.")]));
body.push(bullet("Cada corte × sucursal admite varios campos de peso (ej. cámara de frío + batea); botón para agregar peso. Total kg del corte = Σ pesos."));
body.push(bullet([T("Precio: ", { bold: true }), T("se toma automáticamente de la lista ($ Actual), no se edita acá.")]));
body.push(bullet("Los cortes individuales se valorizan a precio de venta. Las piezas enteras (Media Res, Octavo, Costillar, Caja de Pollo, Pierna) se valorizan a precio de costo, cargado manualmente en Configuración."));
body.push(bullet("Total por corte = Total kg × Precio. Se totaliza por categoría, por sucursal (valor de stock de la sucursal) y total general."));
body.push(callout("El valor de stock de un pesaje es el insumo para el CMV del balance (stock inicial y stock final del período)."));

// 4.4 Balance
body.push(H2("4.4  Módulo de Balance"));
body.push(P("Calcula el resultado de cada sucursal en el período. Todos los campos se completan automáticamente con lo registrado en Carga (ventas, compras, gastos) y en Pesaje (stock). Cada sucursal muestra dos columnas: Ingresos Brutos y Cálculo Neto."));
body.push(makeTable(
  ["Concepto", "Bruto", "Neto (para el cálculo)"],
  [
    ["Ventas en efectivo", "monto", "= monto (retención 0%)"],
    ["Ventas por transferencia", "monto", "= monto × (1 − % retención)"],
    ["Ventas con crédito", "monto", "= monto × (1 − % retención)"],
    ["Ventas con débito", "monto", "= monto × (1 − % retención)"],
    [[{ text: "Total ventas", bold: true }], "Σ brutos", "Σ netos"],
    ["Compras Proveedores", "monto (total)", "(entra en el CMV)"],
    ["Stock inicial", "del pesaje de apertura", ""],
    ["Stock final", "del pesaje de cierre", ""],
    [[{ text: "CMV", bold: true }], "Stock inicial + Compras − Stock final", ""],
    ["Gastos (Rentas, Contador, Varios, Saldos sueldos)", "monto c/u", ""],
    [[{ text: "Ganancia", bold: true }], "", "Total ventas neto − CMV − Σ Gastos"],
    [[{ text: "Utilidad neta %", bold: true }], "", "Ganancia / Total ventas neto"],
  ],
  [3400, 2900, 2700]
));
body.push(bullet("El stock (inicial y final) sale del Módulo de Pesaje; el stock final de un período es el stock inicial del siguiente. El primer período se carga con un stock inicial manual."));
body.push(bullet("Medios de pago: efectivo, transferencia, crédito y débito, cada uno con su % de retención parametrizable (hoy: efectivo 0%, crédito/débito 12%; transferencia a definir)."));
body.push(bullet("Compras Proveedores se muestra como total (aunque en la carga se discriminen por tipo)."));
body.push(bullet("Los gastos se muestran discriminados por tipo y se suman. Se muestra cada sucursal y un consolidado comparativo de las 4."));

// 4.5 Historial
body.push(H2("4.5  Módulo de Historial de Balance"));
body.push(bullet("Lista de balances de períodos cerrados, por sucursal."));
body.push(bullet("Permite consultar cualquier período histórico (rango, ventas, compras, CMV, gastos, rendimiento)."));
body.push(bullet("Los históricos no se alteran al cambiar precios vigentes (se guarda el snapshot de precios del pesaje)."));

// 4.6 Configuración
body.push(H2("4.6  Módulo de Configuración (solo admin)"));
body.push(bullet([T("Roles de usuarios: ", { bold: true }), T("crear cajeras, asignarlas a una sucursal, definir admin.")]));
body.push(bullet([T("Parametrización de ventas: ", { bold: true }), T("medios de pago con su % de descuento/retención (hoy efectivo 0%, crédito/débito 12%, transferencia a definir).")]));
body.push(bullet([T("Parametrización de compras: ", { bold: true }), T("tipos Carne, Cerdo, Pollo.")]));
body.push(bullet([T("Parametrización de gastos: ", { bold: true }), T("tipos (Rentas, Contador, Gastos varios, Saldos de sueldos, luz, agua, internet, etc.).")]));
body.push(bullet([T("Parametrización de cortes ", { bold: true }), T("por categoría (alta/baja/edición, KGR de rinde, orden).")]));
body.push(bullet([T("Parametrización de sucursales ", { bold: true }), T("(alta/baja/edición).")]));
body.push(bullet([T("Parametrización del rinde: ", { bold: true }), T("pieza base y costo por categoría (kg y $/kg), factor de incremento por categoría.")]));
body.push(bullet([T("Precio de costo de piezas enteras ", { bold: true }), T("(Media Res, Octavo, Costillar, Pierna, Caja de Pollo): carga manual, usado para valorizarlas en el pesaje.")]));

// 5. Reglas de negocio
body.push(H1("5. Reglas de negocio (fórmulas)"));
body.push(P("Estas son las fórmulas que el sistema aplica automáticamente:"));
body.push(...formula([
  "Valor de stock (pesaje)  = Σ ( Σ pesos del corte × precio del corte )",
  "Venta neta del medio     = monto bruto × ( 1 − % retención del medio )",
  "Venta neta total         = Σ venta neta de cada medio",
  "CMV                      = Stock inicial + Compras − Stock final",
  "Ganancia sucursal        = Venta neta total − CMV − Σ Gastos",
  "Utilidad neta %          = Ganancia / Venta neta total",
  "Costo de la pieza base   = kg de la pieza × $/kg de compra",
  "Ingreso del despiece     = Σ ( KGR del corte × $ Actual del corte )",
  "Resultado del rinde ($)  = Ingreso del despiece − Costo de la pieza base",
  "% de rinde               = Resultado del rinde / Costo de la pieza base",
]));
body.push(bullet("Encadenado de stock: el stock final de un período es el stock inicial del siguiente."));
body.push(bullet("Primer período de una sucursal: el stock inicial se carga manualmente (no hay pesaje anterior)."));
body.push(bullet("Los cálculos se derivan de los datos cargados; no se editan a mano."));

// 6. Fuera de alcance
body.push(H1("6. Fuera de alcance (primera versión)"));
body.push(P("Para acotar el alcance de la primera versión, quedan afuera:"));
body.push(bullet("Pescado."));
body.push(bullet("Facturación electrónica / AFIP."));
body.push(bullet("Sueldos y liquidaciones."));
body.push(bullet("Integración con balanzas o lectores de tarjeta."));
body.push(bullet("App móvil nativa (se prioriza la web)."));

// 7. Cierre / validación
body.push(H1("7. Validación con el dueño"));
body.push(P("Este análisis funcional está consolidado y prácticamente cerrado. Antes de empezar a construir la aplicación, pedimos revisar y confirmar los siguientes puntos:"));
body.push(bullet("¿Los 6 módulos cubren todo lo que hoy se hace en el Excel?"));
body.push(bullet("¿Las fórmulas de balance y rinde coinciden con las que usan actualmente?"));
body.push(bullet("¿Falta algún tipo de gasto, medio de pago o corte importante?"));
body.push(bullet("Único dato pendiente: el % de retención de las ventas por transferencia (se puede definir después; queda configurable)."));
body.push(callout([
  new TextRun({ text: "Próximo paso una vez validado: ", bold: true, size: 21, color: RED }),
  new TextRun({ text: "ajustar la base de datos al modelo definido y comenzar a construir la aplicación web, módulo por módulo.", italics: true, size: 21, color: GREY }),
]));

// ================= DOCUMENTO =================
const doc = new Document({
  creator: "Mili — Balance System",
  title: "Análisis Funcional — Sistema de Balance Don Chacho",
  description: "Análisis funcional para validación con el dueño",
  numbering: {
    config: [{
      reference: "vinetas",
      levels: [{
        level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
        style: { run: { color: RED }, paragraph: { indent: { left: 420, hanging: 220 } } },
      }],
    }],
  },
  styles: {
    default: { document: { run: { font: "Calibri", size: 21, color: DARK } } },
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 }, // US Letter
        margin: { top: 1200, bottom: 1200, left: 1200, right: 1200 },
      },
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          alignment: AlignmentType.CENTER,
          border: { top: { style: BorderStyle.SINGLE, size: 4, color: "D9C9C9", space: 6 } },
          children: [
            new TextRun({ text: "Sistema de Balance — Don Chacho   ·   ", size: 16, color: GREY }),
            new TextRun({ children: ["Página ", PageNumber.CURRENT], size: 16, color: GREY }),
          ],
        })],
      }),
    },
    children: [...cover, ...toc, ...body],
  }],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync("Analisis_Funcional_Don_Chacho.docx", buf);
  console.log("OK -> Analisis_Funcional_Don_Chacho.docx");
});
