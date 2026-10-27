-- =============================================================
-- Los períodos de una sucursal van pegados
-- =============================================================
--
-- Regla: la fecha de inicio de un período es el día posterior al cierre del
-- anterior. Sin solapes y sin huecos.
--
-- Nada lo controlaba: las fechas se eligen a mano en el diálogo de período.
-- Dos períodos pisados dejan sin definir cuál es "el anterior" del que sale
-- el stock inicial, y un hueco entre dos deja días cuyos movimientos no caen
-- en ningún período.
--
-- El trigger valida solo cuando las fechas cambian. A propósito: cerrar o
-- reabrir un período, o cargarle el stock inicial manual, son updates que no
-- tocan las fechas y no tienen por qué fallar si los períodos que ya existen
-- no cumplen la regla. Los que ya están cargados quedan como están; la regla
-- rige para los nuevos y para los que se editen.
--
-- Idempotente.

create or replace function periodos_encadenados()
returns trigger language plpgsql as $$
declare
  v_otro periodos%rowtype;
begin
  -- Update que no toca las fechas (cerrar, reabrir, stock inicial): pasa.
  if tg_op = 'UPDATE'
     and new.fecha_inicio = old.fecha_inicio
     and new.fecha_fin    = old.fecha_fin then
    return new;
  end if;

  if new.fecha_fin < new.fecha_inicio then
    raise exception 'La fecha de cierre no puede ser anterior al inicio.';
  end if;

  select * into v_otro
    from periodos p
   where p.sucursal_id   = new.sucursal_id
     and p.id           <> new.id
     and p.fecha_inicio <= new.fecha_fin
     and p.fecha_fin    >= new.fecha_inicio
   limit 1;
  if found then
    raise exception 'El período se pisa con el de % a %.',
      to_char(v_otro.fecha_inicio, 'DD/MM/YYYY'),
      to_char(v_otro.fecha_fin,    'DD/MM/YYYY');
  end if;

  select * into v_otro
    from periodos p
   where p.sucursal_id = new.sucursal_id
     and p.id         <> new.id
     and p.fecha_fin   < new.fecha_inicio
   order by p.fecha_fin desc
   limit 1;
  if found and new.fecha_inicio <> v_otro.fecha_fin + 1 then
    raise exception 'El período tiene que empezar el %, el día siguiente al cierre del anterior.',
      to_char(v_otro.fecha_fin + 1, 'DD/MM/YYYY');
  end if;

  select * into v_otro
    from periodos p
   where p.sucursal_id   = new.sucursal_id
     and p.id           <> new.id
     and p.fecha_inicio  > new.fecha_fin
   order by p.fecha_inicio asc
   limit 1;
  if found and new.fecha_fin <> v_otro.fecha_inicio - 1 then
    raise exception 'El período tiene que cerrar el %, el día anterior al inicio del que sigue.',
      to_char(v_otro.fecha_inicio - 1, 'DD/MM/YYYY');
  end if;

  return new;
end;
$$;

drop trigger if exists trg_periodos_encadenados on periodos;
create trigger trg_periodos_encadenados
  before insert or update on periodos
  for each row execute function periodos_encadenados();
