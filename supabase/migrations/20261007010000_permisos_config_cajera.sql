-- =============================================================
-- Permisos de la cajera sobre las secciones de Configuración
-- =============================================================
--
-- Antes: Configuración era exclusiva del admin, en bloque.
-- Ahora: el admin puede habilitarle a la cajera secciones sueltas
-- (p. ej. "Tipos de gasto" sí, "Sucursales" no).
--
-- "Permisos de la cajera" NO se puede habilitar: es la sección donde se
-- editan estos mismos permisos, así que dársela le permitiría
-- auto-habilitarse todo lo demás. Por eso no tiene fila en esta tabla.
--
-- DIFERENCIA IMPORTANTE con la migración anterior: aquellos permisos solo
-- gobernaban la NAVEGACIÓN (qué ve en el menú); los datos los seguía
-- protegiendo la RLS. Acá la cajera va a ESCRIBIR en los catálogos, así que
-- la RLS tiene que aflojarse de verdad. Las políticas de abajo leen la misma
-- tabla de permisos, de modo que apagar el switch también le corta el acceso
-- por API, no solo el botón en pantalla.

-- -------------------------------------------------------------
-- 1. Filas nuevas: una por sección configurable.
-- -------------------------------------------------------------
-- Arrancan todas apagadas: habilitar es una decisión explícita del admin.
insert into permisos_cajera (ruta, habilitado) values
  ('/configuracion/sucursales',  false),
  ('/configuracion/categorias',  false),
  ('/configuracion/cortes',      false),
  ('/configuracion/medios-pago', false),
  ('/configuracion/tipos-gasto', false)
on conflict (ruta) do nothing;

-- -------------------------------------------------------------
-- 2. Helper: ¿está habilitada esta sección?
-- -------------------------------------------------------------
-- `security definer` para que la política pueda leer permisos_cajera sin
-- depender de la RLS de esa tabla (hoy la lectura es pública, pero no
-- queremos que la política se rompa si eso cambia).
create or replace function permiso_cajera(p_ruta text)
returns boolean language sql security definer stable as $$
  select coalesce(
    (select habilitado from permisos_cajera where ruta = p_ruta),
    false
  );
$$;

-- -------------------------------------------------------------
-- 3. Políticas de escritura de los catálogos
-- -------------------------------------------------------------
-- `to authenticated` es OBLIGATORIO acá y no es un detalle de estilo.
--
-- Las políticas viejas (`for all using (is_admin())`) se crearon sin cláusula
-- `to`, o sea `to public`, que incluye el rol `anon`. Eran seguras igual
-- porque `is_admin()` da false para un usuario sin sesión. Pero ahora la
-- condición es `is_admin() OR permiso_cajera(...)`, y el segundo término es
-- true para cualquiera apenas el admin prenda el switch: sin `to
-- authenticated`, cualquier persona con la anon key (que es pública, va
-- compilada en el bundle web) podría escribir en los catálogos.
--
-- Se reemplazan las políticas viejas por una sola por tabla. Los nombres
-- cambian a "config escribe X" porque ya no son exclusivas del admin.

-- Sucursales
drop policy if exists "admin modifica sucursales" on sucursales;
drop policy if exists "config escribe sucursales" on sucursales;
create policy "config escribe sucursales" on sucursales for all
  to authenticated
  using       (is_admin() or permiso_cajera('/configuracion/sucursales'))
  with check  (is_admin() or permiso_cajera('/configuracion/sucursales'));

-- Categorías y rinde
drop policy if exists "admin modifica categorias" on categorias;
drop policy if exists "config escribe categorias" on categorias;
create policy "config escribe categorias" on categorias for all
  to authenticated
  using       (is_admin() or permiso_cajera('/configuracion/categorias'))
  with check  (is_admin() or permiso_cajera('/configuracion/categorias'));

-- Cortes
drop policy if exists "admin modifica cortes" on cortes;
drop policy if exists "config escribe cortes" on cortes;
create policy "config escribe cortes" on cortes for all
  to authenticated
  using       (is_admin() or permiso_cajera('/configuracion/cortes'))
  with check  (is_admin() or permiso_cajera('/configuracion/cortes'));

-- Medios de pago
drop policy if exists "admin modifica medios_pago" on medios_pago;
drop policy if exists "config escribe medios_pago" on medios_pago;
create policy "config escribe medios_pago" on medios_pago for all
  to authenticated
  using       (is_admin() or permiso_cajera('/configuracion/medios-pago'))
  with check  (is_admin() or permiso_cajera('/configuracion/medios-pago'));

-- Tipos de gasto
drop policy if exists "admin modifica tipos_gasto" on tipos_gasto;
drop policy if exists "config escribe tipos_gasto" on tipos_gasto;
create policy "config escribe tipos_gasto" on tipos_gasto for all
  to authenticated
  using       (is_admin() or permiso_cajera('/configuracion/tipos-gasto'))
  with check  (is_admin() or permiso_cajera('/configuracion/tipos-gasto'));

-- Nota: las políticas de LECTURA ("lectura publica X") quedan intactas.
-- Nota: permisos_cajera sigue con escritura solo-admin, así que la cajera no
-- puede tocar sus propios permisos ni siquiera llamando a la API directo.
