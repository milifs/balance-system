-- =============================================================
-- Sistema de Balance — Don Chacho
-- Permisos de módulos para la CAJERA, configurables por el admin.
--
-- Antes la visibilidad de los módulos estaba hardcodeada en el cliente
-- (`soloAdmin` en modules.dart). Ahora vive acá y el admin la edita desde
-- Configuración > Permisos de la cajera.
--
-- Alcance: por ROL, no por usuario (hoy una sola persona hace la operativa
-- de las 4 sucursales). Si en el futuro hay una cajera por sucursal, esto
-- se extiende con un `profile_id` nullable.
--
-- `/configuracion` NO se incluye a propósito: es el panel que controla estos
-- mismos permisos, dárselo a la cajera le permitiría auto-habilitarse todo.
--
-- OJO: esto gobierna la NAVEGACIÓN, no el acceso a los datos. Quien protege
-- los datos es RLS. Hoy la cajera puede leer ventas/compras/gastos/pesajes
-- (lo necesita para Carga y Pesaje), así que habilitarle Balance/Historial
-- funciona de verdad; apagárselos la saca del menú y del router, pero no es
-- una barrera criptográfica.
--
-- Idempotente.
-- =============================================================

create table if not exists permisos_cajera (
  ruta        text primary key,
  habilitado  boolean not null default false
);

-- Semilla con el comportamiento histórico: Carga, Lista de Precios y Pesaje
-- habilitados; Balance e Historial no. `do nothing` para no pisar lo que el
-- admin ya haya configurado si la migración se vuelve a correr.
insert into permisos_cajera (ruta, habilitado) values
  ('/carga',          true),
  ('/precios-rinde',  true),
  ('/pesaje',         true),
  ('/balance',        false),
  ('/historial',      false)
on conflict (ruta) do nothing;

alter table permisos_cajera enable row level security;

-- La cajera necesita leer sus propios permisos para armar el menú.
drop policy if exists "lectura publica permisos_cajera" on permisos_cajera;
create policy "lectura publica permisos_cajera"
  on permisos_cajera for select using (true);

drop policy if exists "admin modifica permisos_cajera" on permisos_cajera;
create policy "admin modifica permisos_cajera"
  on permisos_cajera for all using (is_admin()) with check (is_admin());
