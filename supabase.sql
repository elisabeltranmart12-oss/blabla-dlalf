-- blabla DLALF — base de datos
-- Pegar entero en Supabase > SQL Editor > New query y pulsar RUN.

create table if not exists viajes (
  id      text primary key,
  tipo    text not null check (tipo in ('oferta', 'peticion')),
  fecha   date not null,
  hora    text not null check (char_length(hora) <= 5),
  origen  text not null check (char_length(origen) <= 80),
  destino text not null check (char_length(destino) <= 80),
  autor   text not null check (char_length(autor) <= 60),
  plazas  int check (plazas between 1 and 8),
  lleva   text not null default '' check (char_length(lleva) <= 60),
  nota    text not null default '' check (char_length(nota) <= 300),
  creado  bigint
);

alter table viajes add column if not exists telefono text not null default ''
  check (char_length(telefono) <= 20);

create table if not exists plazas (
  id       text primary key,
  viaje_id text not null references viajes(id) on delete cascade,
  nombre   text not null check (char_length(nombre) <= 60),
  creado   bigint
);

-- Permisos: cualquiera con el enlace puede ver, publicar, editar y borrar viajes.
-- Para apuntarse a una plaza se usa la función apuntar(), que comprueba que quede sitio.
alter table viajes enable row level security;
alter table plazas enable row level security;

drop policy if exists "leer viajes" on viajes;
drop policy if exists "crear viajes" on viajes;
drop policy if exists "editar viajes" on viajes;
drop policy if exists "borrar viajes" on viajes;
drop policy if exists "leer plazas" on plazas;
drop policy if exists "borrar plazas" on plazas;

create policy "leer viajes"   on viajes for select to anon using (true);
create policy "crear viajes"  on viajes for insert to anon with check (true);
create policy "editar viajes" on viajes for update to anon using (true) with check (true);
create policy "borrar viajes" on viajes for delete to anon using (true);
create policy "leer plazas"   on plazas for select to anon using (true);
create policy "borrar plazas" on plazas for delete to anon using (true);

create or replace function apuntar(p_id text, p_viaje text, p_nombre text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  cap int;
  n int;
begin
  select plazas into cap from viajes where id = p_viaje and tipo = 'oferta' for update;
  if cap is null then
    raise exception 'Ese viaje ya no existe';
  end if;
  if exists (select 1 from plazas where id = p_id) then
    return;
  end if;
  select count(*) into n from plazas where viaje_id = p_viaje;
  if n >= cap then
    raise exception 'Ya no quedan plazas en ese coche';
  end if;
  insert into plazas (id, viaje_id, nombre, creado)
  values (p_id, p_viaje, left(p_nombre, 60), (extract(epoch from now()) * 1000)::bigint);
end;
$$;

grant execute on function apuntar(text, text, text) to anon;

-- Avisos en tiempo real: la web se actualiza sola cuando alguien cambia algo.
do $$
begin
  begin alter publication supabase_realtime add table viajes; exception when others then null; end;
  begin alter publication supabase_realtime add table plazas; exception when others then null; end;
end $$;
