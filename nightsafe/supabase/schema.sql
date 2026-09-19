alter table public.journeys add column if not exists contact_phone text;
alter table public.journeys add column if not exists last_heartbeat_at timestamptz;
alter table public.journeys add column if not exists last_signal_alert_at timestamptz;
create or replace function public.heartbeat(p_owner_token text)
returns boolean language plpgsql security definer set search_path=public as $$begin update journeys set last_heartbeat_at=now() where owner_token=p_owner_token and status='active'; return found;end;$$;
grant execute on function public.heartbeat(text) to anon,authenticated;
create or replace function public.create_journey(p_start text,p_destination text,p_eta timestamptz,p_contact text,p_contact_phone text)
returns table(id uuid,owner_token text,viewer_token text,start text,destination text,eta timestamptz,contact text,contact_phone text)
language sql security definer set search_path=public as $$
insert into journeys(start,destination,eta,contact,contact_phone,last_heartbeat_at) values(left(p_start,120),left(p_destination,120),p_eta,left(p_contact,80),left(p_contact_phone,30),now())
returning journeys.id,journeys.owner_token,journeys.viewer_token,journeys.start,journeys.destination,journeys.eta,journeys.contact,journeys.contact_phone;$$;
grant execute on function public.create_journey(text,text,timestamptz,text,text) to anon,authenticated;