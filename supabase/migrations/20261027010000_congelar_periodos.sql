-- =============================================================
-- Los períodos cerrados quedan congelados
-- =============================================================
--
-- El balance se armaba con los valores de HOY, no con los del momento:
--
--   * `v_valor_pesaje` valorizaba el stock con `precios.precio_actual`, así
--     que cada vez que se actualizaba la Lista de Precios cambiaba el stock
--     inicial y final de TODOS los períodos, incluidos los ya cerrados.
--   * `fn_balance_periodo` calculaba la venta neta con el
--     `medios_pago.retencion_pct` actual, así que tocar el % de Crédito
--     reescribía las ventas netas de todo el historial.
--
-- Con inflación y precios que se mueven seguido, eso significaba que cerrabas
-- un período con una ganancia y a la semana el Historial te mostraba otra.
--
-- Se congela cada período con el dato del momento:
--
--   * Stock: se usa `pesajes.precio_snapshot`, que ya se venía guardando al
--     crear el pesaje y nadie leía. Si está en null (pesajes viejos o cortes
--     sin precio cargado) se cae al precio de lista, como antes.
--   * Ventas: `ventas.retencion_pct` nuevo, con el % vigente al cargar la
--     venta. Lo completa un trigger, así vale para cualquier insert (app o
--     SQL a mano) y no hay forma de que una venta quede sin su retención.
--
-- OJO con el backfill: las ventas que ya están cargadas se completan con el
-- % que el medio de pago tiene HOY, que es lo único que se puede saber. Si
-- alguna retención cambió desde que se cargaron, esas ventas quedan con el
-- valor de hoy; de acá en adelante cada venta guarda el suyo.
--
-- Idempotente.

-- -------------------------------------------------------------
-- 1. Stock valorizado al precio del momento del pesaje
-- -------------------------------------------------------------
create or replace view v_valor_pesaje as
select
  p.id                                        as pesaje_id,
  p.periodo_id,
  p.sucursal_id,
  p.momento,
  p.fecha,
  co.id                                       as corte_id,
  co.nombre                                   as corte,
  cat.nombre                                  as categoria,
  coalesce(sum(pi.kg), 0)                     as total_kg,
  coalesce(p.precio_snapshot, pr.precio_actual)                as precio,
  coalesce(sum(pi.kg), 0)
    * coalesce(p.precio_snapshot, pr.precio_actual)            as total_valor
from pesajes p
join cortes co            on co.id  = p.corte_id
join categorias cat       on cat.id = co.categoria_id
left join precios pr      on pr.corte_id = co.id
left join pesaje_items pi on pi.pesaje_id = p.id
group by p.id, p.periodo_id, p.sucursal_id, p.momento, p.fecha,
         co.id, co.nombre, cat.nombre, p.precio_snapshot, pr.precio_actual;

-- -------------------------------------------------------------
-- 2. Retención vigente guardada en cada venta
-- -------------------------------------------------------------
alter table ventas
  add column if not exists retencion_pct decimal(5, 2);

-- Ventas ya cargadas: el % que el medio tiene hoy (ver OJO del encabezado).
update ventas v
   set retencion_pct = mp.retencion_pct
  from medios_pago mp
 where mp.id = v.medio_pago_id
   and v.retencion_pct is null;

-- De acá en adelante lo completa el trigger si el insert no lo trae.
create or replace function ventas_retencion_vigente()
returns trigger language plpgsql as $$
begin
  if new.retencion_pct is null then
    select retencion_pct into new.retencion_pct
      from medios_pago where id = new.medio_pago_id;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_ventas_retencion on ventas;
create trigger trg_ventas_retencion
  before insert on ventas
  for each row execute function ventas_retencion_vigente();

-- -------------------------------------------------------------
-- 3. El balance usa la retención de la venta
-- -------------------------------------------------------------
-- Igual que la versión de 20261027000000 (stock inicial encadenado); lo único
-- que cambia es el `coalesce(v.retencion_pct, mp.retencion_pct)` del primer
-- select. El join a medios_pago queda como red de seguridad.
create or replace function fn_balance_periodo(p_periodo uuid)
returns table (
  ventas_bruto       numeric,
  ventas_neto        numeric,
  compras_total      numeric,
  stock_inicial      numeric,
  stock_final        numeric,
  cmv                numeric,
  gastos_total       numeric,
  ganancia           numeric,
  utilidad_neta_pct  numeric
) language plpgsql stable as $$
declare
  v_ventas_bruto numeric := 0;
  v_ventas_neto  numeric := 0;
  v_compras      numeric := 0;
  v_stock_ini    numeric := 0;
  v_stock_fin    numeric := 0;
  v_gastos       numeric := 0;
  v_manual       numeric;
  v_anterior     uuid;
begin
  select coalesce(sum(v.monto), 0),
         coalesce(sum(v.monto *
           (1 - coalesce(v.retencion_pct, mp.retencion_pct) / 100.0)), 0)
    into v_ventas_bruto, v_ventas_neto
  from ventas v
  join medios_pago mp on mp.id = v.medio_pago_id
  where v.periodo_id = p_periodo;

  select coalesce(sum(monto), 0) into v_compras from compras where periodo_id = p_periodo;
  select coalesce(sum(monto), 0) into v_gastos  from gastos  where periodo_id = p_periodo;

  select coalesce(sum(total_valor), 0) into v_stock_ini
    from v_valor_pesaje where periodo_id = p_periodo and momento = 'apertura';
  select coalesce(sum(total_valor), 0) into v_stock_fin
    from v_valor_pesaje where periodo_id = p_periodo and momento = 'cierre';

  -- Sin pesaje de apertura propio: el stock inicial es el cierre del período
  -- anterior de la sucursal.
  if v_stock_ini = 0 then
    select pa.id into v_anterior
      from periodos pa
      join periodos pe on pe.id = p_periodo
     where pa.sucursal_id = pe.sucursal_id
       and pa.id         <> pe.id
       and pa.fecha_fin   < pe.fecha_fin
     order by pa.fecha_fin desc, pa.creado_at desc
     limit 1;

    if v_anterior is not null then
      select coalesce(sum(total_valor), 0) into v_stock_ini
        from v_valor_pesaje where periodo_id = v_anterior and momento = 'cierre';
    end if;
  end if;

  -- Primer período de la sucursal (o cadena cortada): stock inicial manual.
  if v_stock_ini = 0 then
    select stock_inicial_manual into v_manual from periodos where id = p_periodo;
    if v_manual is not null then v_stock_ini := v_manual; end if;
  end if;

  ventas_bruto      := v_ventas_bruto;
  ventas_neto       := v_ventas_neto;
  compras_total     := v_compras;
  stock_inicial     := v_stock_ini;
  stock_final       := v_stock_fin;
  cmv               := v_stock_ini + v_compras - v_stock_fin;
  gastos_total      := v_gastos;
  ganancia          := v_ventas_neto - cmv - v_gastos;
  utilidad_neta_pct := case when v_ventas_neto = 0 then 0
                            else ganancia / v_ventas_neto * 100 end;
  return next;
end;
$$;
