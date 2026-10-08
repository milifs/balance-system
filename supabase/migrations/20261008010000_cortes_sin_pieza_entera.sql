-- =============================================================
-- Cortes: se elimina la distinción "pieza entera" / "corte individual"
-- =============================================================
--
-- Decisión funcional: no existe la pieza entera como caso aparte. Todo se
-- carga en kilos en el Pesaje — si entra una media res entera, se cargan sus
-- kilos como cualquier otro corte — y todo se valoriza con el precio vigente
-- en la Lista de Precios.
--
-- Esto deja sin uso `cortes.valoriza_a` y `cortes.costo_manual`, que existían
-- para que las piezas enteras se valorizaran a un costo cargado a mano en vez
-- de al precio de lista.
--
-- OJO antes de correr esto: si algún corte estaba marcado como 'costo', pasa
-- a valorizarse por la Lista de Precios. Si ese corte no tiene precio
-- cargado, su valorización queda en $0 hasta que se le cargue uno.

-- 1. La vista del pesaje valoriza siempre por precio de lista.
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
  pr.precio_actual                            as precio,
  coalesce(sum(pi.kg), 0) * pr.precio_actual  as total_valor
from pesajes p
join cortes co            on co.id  = p.corte_id
join categorias cat       on cat.id = co.categoria_id
left join precios pr      on pr.corte_id = co.id
left join pesaje_items pi on pi.pesaje_id = p.id
group by p.id, p.periodo_id, p.sucursal_id, p.momento, p.fecha,
         co.id, co.nombre, cat.nombre, pr.precio_actual;

-- 2. Fuera las columnas, ya sin lectores (ni la vista ni la app).
alter table cortes
  drop column if exists valoriza_a,
  drop column if exists costo_manual;
