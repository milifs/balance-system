-- =============================================================
-- Sistema de Balance — Don Chacho
-- Migración F0: ajuste del modelo al análisis funcional v1.0
-- (ver DISENO_TECNICO.md §2 y §4)
--
-- Parte del schema inicial ya aplicado (20260527000000) y agrega
-- encima los cambios; NO reescribe la migración anterior.
-- =============================================================

-- =============================================================
-- 1. SUCURSALES — corregir nombres a Don Chacho 1..4
-- =============================================================
update sucursales set nombre = 'Don Chacho 1' where orden = 1;
update sucursales set nombre = 'Don Chacho 2' where orden = 2;
update sucursales set nombre = 'Don Chacho 3' where orden = 3;
update sucursales set nombre = 'Don Chacho 4' where orden = 4;

-- =============================================================
-- 2. CATEGORÍAS — columnas nuevas + reemplazo de la tabla `incrementos`
--    (se hace ANTES de borrar Pescado: incrementos tiene FK a categorias)
-- =============================================================
alter table categorias
  add column if not exists pieza_base_nombre   text,
  add column if not exists pieza_base_kg        decimal(10, 3),
  add column if not exists pieza_base_costo_kg  decimal(12, 2),
  add column if not exists factor_incremento    decimal(6, 4) not null default 1.0;

-- Migrar el % de la tabla incrementos → factor (1 + %/100)
update categorias c
  set factor_incremento = 1 + (i.porcentaje / 100.0)
  from incrementos i
  where i.categoria_id = c.id;

-- Eliminar la tabla incrementos (y su FK a categorias) antes de tocar Pescado
drop table if exists incrementos cascade;

-- =============================================================
-- 3. QUITAR PESCADO (categoría fuera de alcance)
--    Ya sin la FK de incrementos; los cortes de Pescado caen por FK y sus
--    precios por ON DELETE CASCADE en precios.corte_id.
-- =============================================================
delete from cortes
  where categoria_id in (select id from categorias where nombre = 'Pescado');
delete from categorias where nombre = 'Pescado';

-- Nombres de pieza base por categoría (kg/$ se completan en Configuración)
update categorias set pieza_base_nombre = 'Media Res',    pieza_base_kg = 111, pieza_base_costo_kg = 10400
  where nombre = 'Carne';
update categorias set pieza_base_nombre = 'Media Cerdo'   where nombre = 'Cerdo';
update categorias set pieza_base_nombre = 'Caja de Pollo' where nombre = 'Pollo';

-- =============================================================
-- 4. CORTES — valorización (venta | costo) para el pesaje
--    Cortes individuales = precio de venta; piezas enteras = costo manual.
-- =============================================================
alter table cortes
  add column if not exists valoriza_a   text not null default 'venta'
    check (valoriza_a in ('venta', 'costo')),
  add column if not exists costo_manual decimal(12, 2);

-- (Las piezas enteras — Media Res, Octavo, Costillar, Pierna, Caja de Pollo —
--  se dan de alta desde Configuración con valoriza_a='costo' y su costo_manual.)

-- =============================================================
-- 5. PROFILES — sucursal asignada (obligatoria para cajera)
-- =============================================================
alter table profiles
  add column if not exists sucursal_id uuid references sucursales(id);

-- Extender el trigger de alta de usuario para leer sucursal_id del metadata
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, nombre, rol, sucursal_id)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nombre', new.email),
    coalesce(new.raw_user_meta_data->>'rol', 'cajera'),
    (new.raw_user_meta_data->>'sucursal_id')::uuid
  );
  return new;
end;
$$ language plpgsql security definer;

-- =============================================================
-- 6. MEDIOS DE PAGO (parametrización de ventas)
-- =============================================================
create table if not exists medios_pago (
  id             uuid primary key default gen_random_uuid(),
  nombre         text not null unique,
  retencion_pct  decimal(5, 2) not null default 0,
  orden          int  not null default 0,
  activo         boolean not null default true
);

insert into medios_pago (nombre, retencion_pct, orden) values
  ('Efectivo',      0,  1),
  ('Transferencia', 0,  2),   -- provisorio, editable
  ('Crédito',      12,  3),
  ('Débito',       12,  4)
on conflict (nombre) do nothing;

-- =============================================================
-- 7. TIPOS DE GASTO (parametrización de gastos)
-- =============================================================
create table if not exists tipos_gasto (
  id      uuid primary key default gen_random_uuid(),
  nombre  text not null unique,
  orden   int  not null default 0,
  activo  boolean not null default true
);

insert into tipos_gasto (nombre, orden) values
  ('Rentas',         1),
  ('Contador',       2),
  ('Gastos varios',  3),
  ('Saldos sueldos', 4),
  ('Luz',            5),
  ('Agua',           6),
  ('Internet',       7)
on conflict (nombre) do nothing;

-- =============================================================
-- 8. PERÍODOS (rango de fechas del balance por sucursal)
-- =============================================================
create table if not exists periodos (
  id                     uuid primary key default gen_random_uuid(),
  sucursal_id            uuid not null references sucursales(id),
  fecha_inicio           date not null,
  fecha_fin              date not null,
  estado                 text not null default 'abierto'
                           check (estado in ('abierto', 'cerrado')),
  stock_inicial_manual   decimal(14, 2),  -- solo primer período (sin pesaje previo)
  creado_at              timestamptz not null default now(),
  check (fecha_fin >= fecha_inicio)
);

create index if not exists idx_periodos_sucursal on periodos(sucursal_id);
create index if not exists idx_periodos_estado    on periodos(estado);

-- =============================================================
-- 9. VENTAS / COMPRAS / GASTOS (registros individuales del Módulo de Carga)
-- =============================================================
create table if not exists ventas (
  id             uuid primary key default gen_random_uuid(),
  periodo_id     uuid not null references periodos(id) on delete cascade,
  sucursal_id    uuid not null references sucursales(id),
  fecha          date not null default current_date,
  medio_pago_id  uuid not null references medios_pago(id),
  monto          decimal(14, 2) not null check (monto >= 0),
  creado_at      timestamptz not null default now()
);
create index if not exists idx_ventas_periodo  on ventas(periodo_id);
create index if not exists idx_ventas_sucursal on ventas(sucursal_id);

create table if not exists compras (
  id           uuid primary key default gen_random_uuid(),
  periodo_id   uuid not null references periodos(id) on delete cascade,
  sucursal_id  uuid not null references sucursales(id),
  fecha        date not null default current_date,
  tipo_compra  text not null check (tipo_compra in ('Carne', 'Cerdo', 'Pollo')),
  monto        decimal(14, 2) not null check (monto >= 0),
  proveedor    text,
  creado_at    timestamptz not null default now()
);
create index if not exists idx_compras_periodo  on compras(periodo_id);
create index if not exists idx_compras_sucursal on compras(sucursal_id);

create table if not exists gastos (
  id            uuid primary key default gen_random_uuid(),
  periodo_id    uuid not null references periodos(id) on delete cascade,
  sucursal_id   uuid not null references sucursales(id),
  fecha         date not null default current_date,
  tipo_gasto_id uuid not null references tipos_gasto(id),
  monto         decimal(14, 2) not null check (monto >= 0),
  creado_at     timestamptz not null default now()
);
create index if not exists idx_gastos_periodo  on gastos(periodo_id);
create index if not exists idx_gastos_sucursal on gastos(sucursal_id);

-- =============================================================
-- 10. PESAJES — ligar al período y al momento (apertura/cierre)
-- =============================================================
alter table pesajes
  add column if not exists periodo_id uuid references periodos(id),
  add column if not exists momento    text check (momento in ('apertura', 'cierre'));

create index if not exists idx_pesajes_periodo on pesajes(periodo_id);

-- =============================================================
-- 11. VISTAS DE CÁLCULO
-- =============================================================

-- Valor de cada pesaje según su valorización (venta usa precio_actual;
-- costo usa costo_manual de la pieza entera).
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
  coalesce(sum(pi.kg), 0)                      as total_kg,
  case when co.valoriza_a = 'costo'
       then co.costo_manual
       else pr.precio_actual end              as precio,
  coalesce(sum(pi.kg), 0) *
    case when co.valoriza_a = 'costo'
         then co.costo_manual
         else pr.precio_actual end            as total_valor
from pesajes p
join cortes co         on co.id  = p.corte_id
join categorias cat    on cat.id = co.categoria_id
left join precios pr   on pr.corte_id = co.id
left join pesaje_items pi on pi.pesaje_id = p.id
group by p.id, p.periodo_id, p.sucursal_id, p.momento, p.fecha,
         co.id, co.nombre, cat.nombre, co.valoriza_a, co.costo_manual, pr.precio_actual;

-- Rinde por corte (precio actual)  — se mantiene la vista existente,
-- recreada por si cambió la definición.
create or replace view v_rinde_actual as
select
  cat.nombre                       as categoria,
  co.nombre                        as corte,
  co.kgr_rinde,
  pr.precio_actual                 as precio,
  co.kgr_rinde * pr.precio_actual  as total_corte
from cortes co
join categorias cat on cat.id = co.categoria_id
join precios pr     on pr.corte_id = co.id
where co.activo = true
order by cat.orden, co.orden;

-- Resumen del rinde por categoría (los 4 valores del pie del cuadro).
create or replace view v_rinde_resumen as
select
  cat.nombre                                            as categoria,
  sum(co.kgr_rinde)                                     as kg_rinde_total,
  sum(co.kgr_rinde * pr.precio_actual)                  as ingreso_despiece,
  (cat.pieza_base_kg * cat.pieza_base_costo_kg)         as costo_pieza_base,
  sum(co.kgr_rinde * pr.precio_actual)
    - (cat.pieza_base_kg * cat.pieza_base_costo_kg)     as resultado_rinde,
  case when coalesce(cat.pieza_base_kg * cat.pieza_base_costo_kg, 0) = 0 then null
       else (sum(co.kgr_rinde * pr.precio_actual)
             - (cat.pieza_base_kg * cat.pieza_base_costo_kg))
            / (cat.pieza_base_kg * cat.pieza_base_costo_kg) * 100 end as pct_rinde
from cortes co
join categorias cat on cat.id = co.categoria_id
join precios pr     on pr.corte_id = co.id
where co.activo = true
group by cat.nombre, cat.orden, cat.pieza_base_kg, cat.pieza_base_costo_kg
order by cat.orden;

-- =============================================================
-- 12. FUNCIONES DE BALANCE (RPC)
-- =============================================================

-- Balance de un período (una sucursal).
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

  -- Primer período sin pesaje de apertura: usar stock inicial manual.
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

-- Consolidado de las sucursales cuyos períodos CERRADOS caen en el rango.
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
    coalesce(sum(b.ventas_bruto),  0),
    coalesce(sum(b.ventas_neto),   0),
    coalesce(sum(b.compras_total), 0),
    coalesce(sum(b.cmv),           0),
    coalesce(sum(b.gastos_total),  0),
    coalesce(sum(b.ganancia),      0)
  from periodos pe
  cross join lateral fn_balance_periodo(pe.id) b
  where pe.estado = 'cerrado'
    and pe.fecha_fin between p_ini and p_fin;
$$;

-- =============================================================
-- 13. RLS — nuevas tablas y helper de sucursal
-- =============================================================

-- Helper: sucursal asignada al usuario autenticado.
create or replace function mi_sucursal()
returns uuid language sql security definer stable as $$
  select sucursal_id from profiles where id = auth.uid();
$$;

alter table medios_pago enable row level security;
alter table tipos_gasto enable row level security;
alter table periodos    enable row level security;
alter table ventas      enable row level security;
alter table compras     enable row level security;
alter table gastos      enable row level security;

-- Catálogos de config: lectura para todos, escritura solo admin.
create policy "lectura publica medios_pago" on medios_pago for select using (true);
create policy "admin modifica medios_pago"  on medios_pago for all    using (is_admin());
create policy "lectura publica tipos_gasto" on tipos_gasto for select using (true);
create policy "admin modifica tipos_gasto"  on tipos_gasto for all    using (is_admin());

-- Períodos: admin todo; cajera solo su sucursal.
create policy "admin todo periodos"  on periodos for all
  using (is_admin()) with check (is_admin());
create policy "cajera su periodos"   on periodos for all
  using (sucursal_id = mi_sucursal()) with check (sucursal_id = mi_sucursal());

-- Ventas / compras / gastos: admin todo; cajera solo su sucursal.
create policy "admin todo ventas"   on ventas  for all
  using (is_admin()) with check (is_admin());
create policy "cajera su ventas"    on ventas  for all
  using (sucursal_id = mi_sucursal()) with check (sucursal_id = mi_sucursal());

create policy "admin todo compras"  on compras for all
  using (is_admin()) with check (is_admin());
create policy "cajera su compras"   on compras for all
  using (sucursal_id = mi_sucursal()) with check (sucursal_id = mi_sucursal());

create policy "admin todo gastos"   on gastos  for all
  using (is_admin()) with check (is_admin());
create policy "cajera su gastos"    on gastos  for all
  using (sucursal_id = mi_sucursal()) with check (sucursal_id = mi_sucursal());

-- Pesajes: la cajera puede LEER todas las sucursales (requisito del módulo),
-- pero solo ESCRIBIR la suya. (La lectura pública ya existe del schema inicial.)
create policy "cajera escribe su pesaje" on pesajes for all
  using (is_admin() or sucursal_id = mi_sucursal())
  with check (is_admin() or sucursal_id = mi_sucursal());

create policy "cajera escribe su pesaje_items" on pesaje_items for all
  using (exists (select 1 from pesajes p
                 where p.id = pesaje_id
                   and (is_admin() or p.sucursal_id = mi_sucursal())))
  with check (exists (select 1 from pesajes p
                 where p.id = pesaje_id
                   and (is_admin() or p.sucursal_id = mi_sucursal())));

-- Admin: ver todos los perfiles (para gestión de usuarios en Configuración).
create policy "admin ve perfiles" on profiles for select using (is_admin());
