-- =============================================================
-- Fix: la cajera no podía dar de alta un corte nuevo
-- =============================================================
--
-- Síntoma: al guardar un corte nuevo desde Configuración > Cortes:
--   new row violates row-level security policy for table "precios"
--
-- Causa: al insertar un corte, el trigger `on_corte_created` crea su fila
-- vacía en `precios`. Esa función no era `security definer`, así que el
-- insert corría con los permisos de quien guardó el corte. Desde que la
-- migración de permisos abrió `cortes` a la cajera habilitada, ella pasa la
-- RLS de `cortes` pero choca con la de `precios`, que sigue siendo solo-admin.
--
-- Arreglo: la fila de precio es una consecuencia estructural de crear el
-- corte (un corte sin fila en `precios` rompe las vistas del balance), no una
-- escritura de precios. Se marca la función `security definer` para que corra
-- siempre, sin tocar la RLS de `precios`: editar precios sigue siendo
-- exclusivo del admin.

create or replace function handle_new_corte()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into precios (corte_id) values (new.id);
  return new;
end;
$$;

-- Red de seguridad: cortes creados mientras el trigger fallaba a medias
-- podrían haber quedado sin su fila de precio.
insert into precios (corte_id)
select c.id from cortes c
where not exists (select 1 from precios p where p.corte_id = c.id);
