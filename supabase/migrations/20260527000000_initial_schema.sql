-- =============================================================
-- Sistema de Rinde y Balance — Don Chacho
-- Schema Supabase / PostgreSQL
-- =============================================================

-- uuid-ossp no es necesario en PG15+; usamos gen_random_uuid() nativo

-- =============================================================
-- PERFILES DE USUARIO (vinculado a Supabase Auth)
-- =============================================================
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  nombre      text not null,
  rol         text not null check (rol in ('admin', 'cajera')) default 'cajera',
  creado_at   timestamptz not null default now()
);

-- Trigger: crea perfil automáticamente al registrar usuario en Auth
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, nombre, rol)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nombre', new.email),
    coalesce(new.raw_user_meta_data->>'rol', 'cajera')
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- =============================================================
-- CATEGORÍAS
-- =============================================================
create table categorias (
  id        uuid primary key default gen_random_uuid(),
  nombre    text not null unique,
  orden     int  not null default 0
);

insert into categorias (nombre, orden) values
  ('Carne',   1),
  ('Cerdo',   2),
  ('Pollo',   3),
  ('Pescado', 4);

-- =============================================================
-- CORTES
-- =============================================================
create table cortes (
  id           uuid primary key default gen_random_uuid(),
  categoria_id uuid not null references categorias(id),
  nombre       text not null,
  kgr_rinde    decimal(10, 3) not null default 0,  -- kg que rinde del animal
  activo       boolean not null default true,
  orden        int not null default 0,
  creado_at    timestamptz not null default now()
);

create index idx_cortes_categoria on cortes(categoria_id);

-- Datos iniciales — Carne (extraídos del Excel DON CHACHO)
insert into cortes (categoria_id, nombre, kgr_rinde, orden)
select c.id, v.nombre, v.kgr, v.orden
from categorias c,
(values
  ('VACIO',             3.335,  1),
  ('QUEPERI',           2.580,  2),
  ('MATAMBRE',          1.395,  3),
  ('VUELITO',           0.480,  4),
  ('COSTILLA ESPECIAL', 8.850,  5),
  ('TAPA DE NALGA',     1.310,  6),
  ('TAPA DE ASADO',     2.095,  7),
  ('ASADO OFERTA',     11.610,  8),
  ('FILET',             1.855,  9),
  ('LOMO',              5.895, 10),
  ('PULPA',             4.220, 11),
  ('PICANA',            4.700, 12),
  ('PECETO',            1.640, 13),
  ('BOLA DE LOMO',      4.150, 14),
  ('CUADRADA',          3.315, 15),
  ('PALETA',            3.135, 16),
  ('SOBACO',            3.770, 17),
  ('TORTUGA',           1.480, 18),
  ('OSOBUCO',           3.545, 19),
  ('PUCHERO COMUN',    12.440, 20),
  ('PARA CHORIZO',      5.730, 21),
  ('GRASA PARQUE',      9.395, 22),
  ('HUESOS',           11.870, 23)
) as v(nombre, kgr, orden)
where c.nombre = 'Carne';

-- Datos iniciales — Cerdo
insert into cortes (categoria_id, nombre, kgr_rinde, orden)
select c.id, v.nombre, v.kgr, v.orden
from categorias c,
(values
  ('COSTILLA',              6.490, 1),
  ('MATAMBRE DE CERDO',     1.000, 2),
  ('BONDIOLA',              1.830, 3),
  ('COSTELETA DE CERDO',    4.790, 4),
  ('PERNIL',               11.340, 5),
  ('PALETA DE CERDO',       5.340, 6),
  ('PARA CHORIZO',          1.460, 7),
  ('CUERO Y CABEZA',        5.060, 8),
  ('GRASA',                 3.800, 9),
  ('PATITAS Y DESPERDICIOS',1.700,10)
) as v(nombre, kgr, orden)
where c.nombre = 'Cerdo';

-- Datos iniciales — Pollo
insert into cortes (categoria_id, nombre, kgr_rinde, orden)
select c.id, v.nombre, v.kgr, v.orden
from categorias c,
(values
  ('PECHUGAS',    4.890, 1),
  ('PATA MUSLO',  7.380, 2),
  ('ALITAS',      2.240, 3),
  ('MENUDO',      1.370, 4),
  ('PUCHERO',     3.390, 5)
) as v(nombre, kgr, orden)
where c.nombre = 'Pollo';

-- Pescado: sin cortes iniciales (se cargarán desde la app)

-- =============================================================
-- PRECIOS (un registro por corte)
-- =============================================================
create table precios (
  id               uuid primary key default gen_random_uuid(),
  corte_id         uuid not null unique references cortes(id) on delete cascade,
  precio_actual    decimal(12, 2),
  precio_ultimo    decimal(12, 2),
  precio_penultimo decimal(12, 2),
  actualizado_at   timestamptz not null default now()
);

create index idx_precios_corte on precios(corte_id);

-- Crear registro de precio vacío para cada corte existente
insert into precios (corte_id)
select id from cortes;

-- Trigger: al insertar un corte nuevo, crear su registro de precio
create or replace function handle_new_corte()
returns trigger as $$
begin
  insert into precios (corte_id) values (new.id);
  return new;
end;
$$ language plpgsql;

create trigger on_corte_created
  after insert on cortes
  for each row execute function handle_new_corte();

-- =============================================================
-- INCREMENTOS (uno por categoría)
-- =============================================================
create table incrementos (
  id           uuid primary key default gen_random_uuid(),
  categoria_id uuid not null unique references categorias(id),
  porcentaje   decimal(5, 2) not null default 0,
  calculado_at timestamptz not null default now()
);

insert into incrementos (categoria_id, porcentaje)
select id, 0 from categorias;

-- =============================================================
-- SUCURSALES
-- =============================================================
create table sucursales (
  id        uuid primary key default gen_random_uuid(),
  nombre    text not null unique,
  orden     int  not null default 0,
  activo    boolean not null default true
);

insert into sucursales (nombre, orden) values
  ('Chacho 1',        1),
  ('Chacho 2',        2),
  ('Don Chacho 3',    3),
  ('Cabaña del Valle',4);

-- =============================================================
-- PESAJES (sesión de pesaje: corte + sucursal + fecha)
-- =============================================================
create table pesajes (
  id               uuid primary key default gen_random_uuid(),
  corte_id         uuid not null references cortes(id),
  sucursal_id      uuid not null references sucursales(id),
  fecha            date not null default current_date,
  precio_snapshot  decimal(12, 2),  -- precio vigente al momento del pesaje
  creado_at        timestamptz not null default now(),
  unique (corte_id, sucursal_id, fecha)  -- un pesaje por corte/sucursal/día
);

create index idx_pesajes_fecha       on pesajes(fecha);
create index idx_pesajes_sucursal    on pesajes(sucursal_id);
create index idx_pesajes_corte       on pesajes(corte_id);

-- =============================================================
-- PESAJE ITEMS (pesos individuales por origen)
-- =============================================================
create table pesaje_items (
  id         uuid primary key default gen_random_uuid(),
  pesaje_id  uuid not null references pesajes(id) on delete cascade,
  kg         decimal(10, 3) not null check (kg >= 0),
  origen     text,  -- opcional: "cámara de frío", "batea", etc.
  creado_at  timestamptz not null default now()
);

create index idx_pesaje_items_pesaje on pesaje_items(pesaje_id);

-- =============================================================
-- VISTA: BALANCE DEL DÍA
-- Totaliza kg y valor por corte, sucursal y fecha
-- =============================================================
create or replace view v_balance_dia as
select
  p.fecha,
  s.nombre                              as sucursal,
  cat.nombre                            as categoria,
  co.nombre                             as corte,
  sum(pi.kg)                            as total_kg,
  p.precio_snapshot                     as precio,
  sum(pi.kg) * p.precio_snapshot        as total_valor
from pesajes p
join pesaje_items pi  on pi.pesaje_id  = p.id
join sucursales s     on s.id          = p.sucursal_id
join cortes co        on co.id         = p.corte_id
join categorias cat   on cat.id        = co.categoria_id
group by p.fecha, s.nombre, cat.nombre, co.nombre, p.precio_snapshot;

-- =============================================================
-- VISTA: RINDE CON PRECIO ACTUAL
-- Calcula el total esperado del rinde según precio actual
-- =============================================================
create or replace view v_rinde_actual as
select
  cat.nombre                            as categoria,
  co.nombre                             as corte,
  co.kgr_rinde,
  pr.precio_actual                      as precio,
  co.kgr_rinde * pr.precio_actual       as total_corte
from cortes co
join categorias cat on cat.id = co.categoria_id
join precios pr     on pr.corte_id = co.id
where co.activo = true
order by cat.orden, co.orden;

-- =============================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================
alter table profiles      enable row level security;
alter table categorias    enable row level security;
alter table cortes        enable row level security;
alter table precios       enable row level security;
alter table incrementos   enable row level security;
alter table sucursales    enable row level security;
alter table pesajes       enable row level security;
alter table pesaje_items  enable row level security;

-- Profiles: cada usuario ve solo su perfil
create policy "usuario ve su perfil"
  on profiles for select
  using (auth.uid() = id);

create policy "usuario actualiza su perfil"
  on profiles for update
  using (auth.uid() = id);

-- Helper: verifica si el usuario autenticado es admin
create or replace function is_admin()
returns boolean as $$
  select exists (
    select 1 from profiles
    where id = auth.uid() and rol = 'admin'
  );
$$ language sql security definer;

-- Catálogo (categorías, cortes, sucursales): lectura para todos, escritura solo admin
create policy "lectura publica categorias"
  on categorias for select using (true);

create policy "admin modifica categorias"
  on categorias for all using (is_admin());

create policy "lectura publica cortes"
  on cortes for select using (true);

create policy "admin modifica cortes"
  on cortes for all using (is_admin());

create policy "lectura publica sucursales"
  on sucursales for select using (true);

create policy "admin modifica sucursales"
  on sucursales for all using (is_admin());

-- Precios: lectura para todos, escritura solo admin
create policy "lectura publica precios"
  on precios for select using (true);

create policy "admin modifica precios"
  on precios for all using (is_admin());

-- Incrementos: lectura para todos, escritura solo admin
create policy "lectura publica incrementos"
  on incrementos for select using (true);

create policy "admin modifica incrementos"
  on incrementos for all using (is_admin());

-- Pesajes: lectura para todos los autenticados, escritura solo admin
create policy "autenticado lee pesajes"
  on pesajes for select using (auth.role() = 'authenticated');

create policy "admin modifica pesajes"
  on pesajes for all using (is_admin());

create policy "autenticado lee pesaje_items"
  on pesaje_items for select using (auth.role() = 'authenticated');

create policy "admin modifica pesaje_items"
  on pesaje_items for all using (is_admin());
