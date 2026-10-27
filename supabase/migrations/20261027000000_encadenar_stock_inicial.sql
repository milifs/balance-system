-- =============================================================
-- Balance: el stock inicial se encadena con el cierre anterior
-- =============================================================
--
-- El análisis funcional (§ Módulo de Pesaje) dice que el stock final de un
-- período es el stock inicial del siguiente: se pesa UNA vez por período, al
-- cierre, y ese mismo pesaje abre el período que sigue.
--
-- `fn_balance_periodo` no hacía ese encadenado: buscaba un pesaje con
-- momento='apertura' dentro del propio período y, si no lo encontraba, dejaba
-- el stock inicial en $0 (salvo que el período tuviera stock_inicial_manual
-- cargado a mano). Como el Módulo de Pesaje abre por defecto en "Cierre", en
-- la práctica todos los períodos menos el primero arrancaban con stock
-- inicial $0 → el CMV quedaba corto por ese monto y la ganancia salía
-- inflada en la misma cifra.
--
-- Queda así el orden de resolución del stock inicial:
--   1. Pesaje de apertura del propio período, si lo cargaron (sigue
--      funcionando para quien pesa dos veces).
--   2. Pesaje de cierre del período anterior de la misma sucursal.
--   3. `periodos.stock_inicial_manual` (primer período de la sucursal, que no
--      tiene cierre anterior del que colgarse).
--
-- "Período anterior" = el de la misma sucursal que termina más cerca, antes
-- de que termine éste. Así vale tanto para períodos pegados (6-feb→5-mar,
-- 5-mar→5-abr) como para los que quedaron con un hueco o pisados entre sí.
--
-- Lo único que cambia respecto de la versión anterior es el bloque del stock
-- inicial; el resto de la función va igual. Idempotente.

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
         coalesce(sum(v.monto * (1 - mp.retencion_pct / 100.0)), 0)
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
