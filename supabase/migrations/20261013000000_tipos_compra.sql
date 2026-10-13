-- =============================================================
-- Tipos de compra parametrizables
-- =============================================================
--
-- Antes: `compras.tipo_compra` era un text con check in ('Carne','Cerdo',
-- 'Pollo'), hardcodeado también como enum en el cliente. La carnicería
-- también compra carbón, condimentos, bolsas, etc., así que la lista pasa a
-- ser un catálogo que el admin edita en Configuración > Tipos de compra.
--
-- `compras.tipo_compra` queda como TEXT (no se convierte en FK a propósito):
-- es el nombre con el que se cargó la compra en su momento. Así, dar de baja
-- o renombrar un tipo no toca los períodos ya cerrados ni puede fallar por
-- integridad referencial.
--
-- Idempotente.

-- -------------------------------------------------------------
-- 1. Catálogo
-- -------------------------------------------------------------
create table if not exists tipos_compra (
  id      uuid primary key default gen_random_uuid(),
  nombre  text not null unique,
  orden   int  not null default 0,
  activo  boolean not null default true
);

-- Semilla con los tres tipos históricos, para no perder las compras ya
-- cargadas de vista en el cuadro de Carga.
insert into tipos_compra (nombre, orden) values
  ('Carne', 1),
  ('Cerdo', 2),
  ('Pollo', 3)
on conflict (nombre) do nothing;

-- -------------------------------------------------------------
-- 2. Soltar el check viejo de compras
-- -------------------------------------------------------------
-- El constraint se creó inline, así que el nombre lo puso Postgres
-- (`compras_tipo_compra_check`). Se busca por definición para no depender
-- de ese nombre.
do $$
declare c record;
begin
  for c in
    select conname
      from pg_constraint
     where conrelid = 'compras'::regclass
       and contype = 'c'
       and pg_get_constraintdef(oid) ilike '%tipo_compra%'
  loop
    execute format('alter table compras drop constraint %I', c.conname);
  end loop;
end $$;

-- -------------------------------------------------------------
-- 3. Permiso de la cajera sobre la sección nueva
-- -------------------------------------------------------------
insert into permisos_cajera (ruta, habilitado) values
  ('/configuracion/tipos-compra', false)
on conflict (ruta) do nothing;

-- -------------------------------------------------------------
-- 4. RLS
-- -------------------------------------------------------------
-- Mismo esquema que el resto de los catálogos: lectura para cualquiera con
-- sesión (el cuadro de Carga lo necesita), escritura para el admin o para la
-- cajera si el admin le habilitó la sección. `to authenticated` es
-- obligatorio: sin eso, `permiso_cajera(...)` en true dejaría escribir a
-- cualquiera con la anon key, que va compilada en el bundle web.
alter table tipos_compra enable row level security;

drop policy if exists "lectura publica tipos_compra" on tipos_compra;
create policy "lectura publica tipos_compra" on tipos_compra for select using (true);

drop policy if exists "config escribe tipos_compra" on tipos_compra;
create policy "config escribe tipos_compra" on tipos_compra for all
  to authenticated
  using       (is_admin() or permiso_cajera('/configuracion/tipos-compra'))
  with check  (is_admin() or permiso_cajera('/configuracion/tipos-compra'));
