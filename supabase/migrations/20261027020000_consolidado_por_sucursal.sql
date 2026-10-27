-- =============================================================
-- Consolidado: se ve qué sucursal entró y cuál quedó afuera
-- =============================================================
--
-- `fn_consolidado` suma los períodos CERRADOS cuya fecha_fin cae en el rango.
-- La regla está bien, pero era muda: si una sucursal se olvidaba de cerrar el
-- período, o sus fechas no caían en el rango, desaparecía del total sin
-- avisar. La pantalla decía "las 4 sucursales" y podía estar mostrando tres.
--
-- `fn_consolidado_detalle` devuelve una fila por sucursal activa —incluidas
-- las que no aportaron ningún período, con `periodos = 0`— así la pantalla
-- puede mostrar quién entró, con cuántos períodos, y quién no.
--
-- `fn_consolidado` pasa a sumar ese detalle, para que el total y el desglose
-- no puedan contar cosas distintas.
--
-- Idempotente.

create or replace function fn_consolidado_detalle(p_ini date, p_fin date)
returns table (
  sucursal_id    uuid,
  sucursal       text,
  orden          int,
  periodos       int,
  ventas_bruto   numeric,
  ventas_neto    numeric,
  compras_total  numeric,
  cmv            numeric,
  gastos_total   numeric,
  ganancia       numeric
) language sql stable as $$
  select
    s.id,
    s.nombre,
    s.orden,
    count(b.sucursal_id)::int,
    coalesce(sum(b.ventas_bruto),  0),
    coalesce(sum(b.ventas_neto),   0),
    coalesce(sum(b.compras_total), 0),
    coalesce(sum(b.cmv),           0),
    coalesce(sum(b.gastos_total),  0),
    coalesce(sum(b.ganancia),      0)
  from sucursales s
  -- Subconsulta y no un lateral directo sobre el left join: así
  -- fn_balance_periodo corre solo para los períodos que existen, y la
  -- sucursal sin períodos queda con 0 filas en vez de una fila de ceros.
  left join (
    select pe.sucursal_id, bal.*
      from periodos pe
      cross join lateral fn_balance_periodo(pe.id) bal
     where pe.estado = 'cerrado'
       and pe.fecha_fin between p_ini and p_fin
  ) b on b.sucursal_id = s.id
  where s.activo = true
  group by s.id, s.nombre, s.orden
  order by s.orden;
$$;

-- El total sale del mismo detalle que se muestra en pantalla.
create or replace function fn_consolidado(p_ini date, p_fin date)
returns table (
  ventas_bruto   numeric,
  ventas_neto    numeric,
  compras_total  numeric,
  cmv            numeric,
  gastos_total   numeric,
  ganancia       numeric
) language sql stable as $$
  select
    coalesce(sum(d.ventas_bruto),  0),
    coalesce(sum(d.ventas_neto),   0),
    coalesce(sum(d.compras_total), 0),
    coalesce(sum(d.cmv),           0),
    coalesce(sum(d.gastos_total),  0),
    coalesce(sum(d.ganancia),      0)
  from fn_consolidado_detalle(p_ini, p_fin) d;
$$;
