-- =============================================================
-- Sistema de Balance — Don Chacho
-- Fix: "Database error creating new user" al dar de alta usuarios en Auth.
--
-- Causa: `handle_new_user` es SECURITY DEFINER sin `search_path` fijado.
-- Cuando el entorno endurece el search_path, las tablas sin calificar por
-- esquema (`profiles`) dejan de resolver y el trigger falla; Supabase Auth
-- aborta la creación del usuario con ese mensaje genérico.
--
-- Fix: recrear la función calificando `public.profiles` y fijando
-- `search_path = public` explícitamente. Idempotente (create or replace).
-- =============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nombre, rol, sucursal_id)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nombre', new.email),
    coalesce(new.raw_user_meta_data->>'rol', 'cajera'),
    (new.raw_user_meta_data->>'sucursal_id')::uuid
  );
  return new;
end;
$$;

-- El trigger on_auth_user_created ya existe y apunta a esta función;
-- create or replace conserva el trigger sin necesidad de recrearlo.
