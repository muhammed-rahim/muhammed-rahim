create extension if not exists pgcrypto;
create table if not exists public.journeys(
 id uuid primary key default gen_random_uuid(), owner_token text unique not null default encode(gen_random_bytes(24),'hex'), viewer_token text unique not null default encode(gen_random_bytes(24),'hex'),
 start text not null,destination text not null,eta timestamptz not null,contact text,status text not null default 'active' check(status in ('active','arrived','expired')),
 last_lat double precision,last_lon double precision,last_accuracy double precision,last_location_at timestamptz,last_checkin_at timestamptz,created_at timestamptz not null default now()
);
alter table public.journeys enable row level security;
create or replace function public.create_journey(p_start text,p_destination text,p_eta timestamptz,p_contact text)
returns table(id uuid,owner_token text,viewer_token text,start text,destination text,eta timestamptz,contact text) language sql security definer set search_path=public as $$
insert into journeys(start,destination,eta,contact) values(left(p_start,120),left(p_destination,120),p_eta,left(p_contact,80))
returning journeys.id,journeys.owner_token,journeys.viewer_token,journeys.start,journeys.destination,journeys.eta,journeys.contact;$$;
create or replace function public.update_location(p_owner_token text,p_lat double precision,p_lon double precision,p_accuracy double precision)
returns boolean language plpgsql security definer set search_path=public as $$begin update journeys set last_lat=p_lat,last_lon=p_lon,last_accuracy=p_accuracy,last_location_at=now() where owner_token=p_owner_token and status='active'; return found;end;$$;
create or replace function public.check_in(p_owner_token text) returns boolean language plpgsql security definer set search_path=public as $$begin update journeys set last_checkin_at=now() where owner_token=p_owner_token and status='active'; return found;end;$$;
create or replace function public.complete_journey(p_owner_token text) returns boolean language plpgsql security definer set search_path=public as $$begin update journeys set status='arrived' where owner_token=p_owner_token and status='active'; return found;end;$$;
create or replace function public.get_owner_state(p_owner_token text)
returns table(status text,needs_attention boolean) language sql security definer set search_path=public as $$
select status,(status='active' and now()>eta and coalesce(last_checkin_at,'epoch')<eta) from journeys where owner_token=p_owner_token limit 1;$$;
create or replace function public.get_journey(p_viewer_token text)
returns table(id uuid,start text,destination text,eta timestamptz,contact text,status text,last_lat double precision,last_lon double precision,last_accuracy double precision,last_location_at timestamptz,last_checkin_at timestamptz,needs_attention boolean)
language sql security definer set search_path=public as $$
select id,start,destination,eta,contact,status,last_lat,last_lon,last_accuracy,last_location_at,last_checkin_at,(status='active' and now()>eta and coalesce(last_checkin_at,'epoch')<eta) from journeys where viewer_token=p_viewer_token limit 1;$$;
revoke all on table public.journeys from anon,authenticated;
grant execute on function public.create_journey(text,text,timestamptz,text) to anon,authenticated;
grant execute on function public.update_location(text,double precision,double precision,double precision) to anon,authenticated;
grant execute on function public.check_in(text) to anon,authenticated;
grant execute on function public.complete_journey(text) to anon,authenticated;
grant execute on function public.get_owner_state(text) to anon,authenticated;
grant execute on function public.get_journey(text) to anon,authenticated;