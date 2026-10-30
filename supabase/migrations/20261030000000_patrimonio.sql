-- =============================================================
-- Sistema de Balance — Don Chacho
-- Módulo de PATRIMONIO: la foto de "qué tengo / qué debo" a una fecha.
--
-- Es el cuadro que hoy se lleva en una planilla aparte: dos columnas,
-- HABER (lo que está a favor) y DEBE (las deudas), cada una con conceptos
-- escritos a mano, y abajo el saldo del negocio a esa fecha.
--
-- A propósito NO se ata a nada del resto del sistema: ni sucursal, ni
-- período, ni medios de pago, ni tipos de gasto. Los conceptos son texto
-- libre ("MACETA MEDIAS", "PRESTAMO MACRO PAPA") y no tienen por qué existir
-- como catálogo; atarlos obligaría a dar de alta cada cosa antes de poder
-- escribirla, que es justo lo que hace que la planilla siga viviendo afuera.
-- El único cálculo es la suma de cada lado y la resta entre ambos.
--
-- Una foto por fecha (`fecha` es única): el cuadro es "el balance a la
-- fecha", no un movimiento. Volver a guardar la misma fecha reemplaza la
-- foto en vez de duplicarla.
--
-- Idempotente.
-- =============================================================

-- -------------------------------------------------------------
-- 1. Tablas
-- -------------------------------------------------------------
create table if not exists patrimonios (
  id             uuid primary key default gen_random_uuid(),
  fecha          date not null,
  creado_en      timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

-- Una sola foto por fecha. Va como índice único (y no inline en el create)
-- para que la migración se pueda volver a correr sobre una tabla que ya
-- exista. `guardar_patrimonio` depende de él para su `on conflict`.
create unique index if not exists idx_patrimonios_fecha
  on patrimonios (fecha);

create table if not exists patrimonio_items (
  id            uuid primary key default gen_random_uuid(),
  patrimonio_id uuid not null references patrimonios (id) on delete cascade,
  lado          text not null check (lado in ('haber', 'debe')),
  -- Orden en el que se escribieron las filas. El cuadro se lee comparando
  -- renglón contra renglón, así que el orden es información: se respeta tal
  -- como quedó en pantalla y no se reordena por nombre ni por monto.
  orden         int not null default 0,
  concepto      text not null default '',
  -- Sin `check (monto >= 0)`, al revés que `ventas`/`compras`/`gastos`:
  -- acá un saldo puede ser legítimamente negativo (una cuenta en descubierto
  -- del lado del haber), y el cuadro es una foto, no un movimiento.
  monto         numeric(14, 2) not null default 0
);

create index if not exists idx_patrimonio_items_patrimonio
  on patrimonio_items (patrimonio_id);

-- -------------------------------------------------------------
-- 2. Guardado atómico
-- -------------------------------------------------------------
-- La pantalla guarda el cuadro entero de una: no hay "agregar una fila"
-- contra la base, se edita todo y se aprieta Guardar. Eso es borrar los
-- items de esa fecha e insertar los nuevos, y tiene que pasar junto: si el
-- borrado saliera y el insert fallara (se corta internet en el medio), la
-- foto quedaría vacía y se perdería el cuadro cargado.
--
-- `security invoker` (el default) a propósito: la función no puede servir
-- para saltear la RLS de abajo, las policies se evalúan con el usuario que
-- la llama.
create or replace function guardar_patrimonio(p_fecha date, p_items jsonb)
returns uuid
language plpgsql
as $$
declare
  v_id uuid;
begin
  insert into patrimonios (fecha) values (p_fecha)
  on conflict (fecha) do update set actualizado_en = now()
  returning id into v_id;

  delete from patrimonio_items where patrimonio_id = v_id;

  insert into patrimonio_items (patrimonio_id, lado, orden, concepto, monto)
  select v_id,
         item ->> 'lado',
         coalesce((item ->> 'orden')::int, 0),
         coalesce(item ->> 'concepto', ''),
         coalesce((item ->> 'monto')::numeric, 0)
  from jsonb_array_elements(coalesce(p_items, '[]'::jsonb)) as item;

  return v_id;
end;
$$;

-- -------------------------------------------------------------
-- 3. RLS
-- -------------------------------------------------------------
-- Solo el admin, para leer y para escribir. El cuadro mezcla el negocio con
-- lo personal del dueño (créditos hipotecarios, préstamos a nombre de la
-- familia, tarjetas): no es información de la operativa diaria y la cajera
-- no tiene por qué verla. Por eso el módulo tampoco aparece en los permisos
-- configurables (ver `modules.dart`, `exclusivoAdmin`).
alter table patrimonios enable row level security;
alter table patrimonio_items enable row level security;

drop policy if exists "admin opera patrimonios" on patrimonios;
create policy "admin opera patrimonios" on patrimonios for all
  to authenticated
  using      (is_admin())
  with check (is_admin());

drop policy if exists "admin opera patrimonio_items" on patrimonio_items;
create policy "admin opera patrimonio_items" on patrimonio_items for all
  to authenticated
  using      (is_admin())
  with check (is_admin());
