-- =============================================================
-- Sistema de Balance — Don Chacho
-- Cambio de alcance: la CAJERA puede cargar TODAS las sucursales.
--
-- Motivo: por ahora una sola persona hace toda la operativa (pesajes y
-- ventas/compras/gastos) de las 4 sucursales. Se sueltan los filtros por
-- `sucursal_id = mi_sucursal()` en las tablas operativas; la cajera sigue
-- SIN acceso a balance, historial y configuración (eso no cambia).
--
-- `profiles.sucursal_id` se conserva (sirve como sucursal por defecto en la
-- UI), pero deja de usarse para restringir el acceso.
--
-- Idempotente: cada policy se recrea con drop-if-exists previo.
-- =============================================================

-- ---------- VENTAS ----------
drop policy if exists "cajera su ventas" on ventas;
drop policy if exists "cajera todas ventas" on ventas;
create policy "cajera todas ventas" on ventas for all
  to authenticated using (true) with check (true);

-- ---------- COMPRAS ----------
drop policy if exists "cajera su compras" on compras;
drop policy if exists "cajera todas compras" on compras;
create policy "cajera todas compras" on compras for all
  to authenticated using (true) with check (true);

-- ---------- GASTOS ----------
drop policy if exists "cajera su gastos" on gastos;
drop policy if exists "cajera todas gastos" on gastos;
create policy "cajera todas gastos" on gastos for all
  to authenticated using (true) with check (true);

-- ---------- PERÍODOS ----------
drop policy if exists "cajera su periodos" on periodos;
drop policy if exists "cajera todas periodos" on periodos;
create policy "cajera todas periodos" on periodos for all
  to authenticated using (true) with check (true);

-- ---------- PESAJES ----------
-- Antes: la cajera leía todas pero escribía solo su sucursal.
-- Ahora: escribe/lee todas las sucursales.
drop policy if exists "cajera escribe su pesaje" on pesajes;
drop policy if exists "cajera todo pesaje" on pesajes;
create policy "cajera todo pesaje" on pesajes for all
  to authenticated using (true) with check (true);

-- ---------- PESAJE_ITEMS ----------
drop policy if exists "cajera escribe su pesaje_items" on pesaje_items;
drop policy if exists "cajera todo pesaje_items" on pesaje_items;
create policy "cajera todo pesaje_items" on pesaje_items for all
  to authenticated using (true) with check (true);

-- Nota: las policies "admin todo X" se conservan; son redundantes con estas
-- (que ya cubren a cualquier usuario autenticado) pero no molestan y dejan
-- explícito el permiso del admin.
