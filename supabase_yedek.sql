-- PlanZen: otomatik yedek sistemi
-- Supabase panelinde: SQL Editor > New query > bunu yapıştır > Run (birden fazla çalıştırmak güvenlidir)
-- Not: pg_cron eklentisinin açık olması gerekir (Database > Extensions).

create table if not exists public.user_backups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('auto','manual','pre-restore')),
  data jsonb not null check (pg_column_size(data) < 4000000),
  summary jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists user_backups_user_created on public.user_backups (user_id, created_at desc);
alter table public.user_backups enable row level security;

drop policy if exists "backups select own" on public.user_backups;
drop policy if exists "backups insert own" on public.user_backups;
drop policy if exists "backups delete own" on public.user_backups;
create policy "backups select own" on public.user_backups for select to authenticated using (user_id = (select auth.uid()));
create policy "backups insert own" on public.user_backups for insert to authenticated
  with check (user_id = (select auth.uid()) and kind in ('manual','pre-restore'));
create policy "backups delete own" on public.user_backups for delete to authenticated using (user_id = (select auth.uid()));
revoke all on public.user_backups from anon;
revoke update on public.user_backups from authenticated;

create or replace function public.backup_summary(d jsonb)
returns jsonb language plpgsql immutable set search_path = '' as $$
begin
  return jsonb_build_object(
    'min', coalesce((select sum((value)::numeric) from jsonb_each_text(d->'log') where value ~ '^[0-9.]+$'), 0),
    'days', coalesce((select count(*) from jsonb_each_text(d->'log') where value ~ '^[0-9.]+$' and value::numeric > 0), 0),
    'exams', case when jsonb_typeof(d->'exams') = 'array' then jsonb_array_length(d->'exams') else 0 end
  );
exception when others then
  return '{}'::jsonb;
end $$;

-- Her kullanıcı için 14 otomatik, 10 elle, 5 geri-yükleme-öncesi yedek saklanır
create or replace function public.prune_backups()
returns trigger language plpgsql security definer set search_path = '' as $$
declare keep int := case new.kind when 'auto' then 14 when 'manual' then 10 else 5 end;
begin
  delete from public.user_backups b
  where b.user_id = new.user_id and b.kind = new.kind
    and b.id in (
      select id from public.user_backups
      where user_id = new.user_id and kind = new.kind
      order by created_at desc offset keep
    );
  return null;
end $$;
revoke all on function public.prune_backups() from public, anon, authenticated;
drop trigger if exists user_backups_prune on public.user_backups;
create trigger user_backups_prune after insert on public.user_backups
  for each row execute function public.prune_backups();

-- Her gece: veri son yedekten farklıysa yeni otomatik yedek al
create or replace function public.run_daily_backup()
returns int language plpgsql security definer set search_path = '' as $$
declare n int;
begin
  with ins as (
    insert into public.user_backups (user_id, kind, data, summary)
    select ud.user_id, 'auto', ud.data, public.backup_summary(ud.data)
    from public.user_data ud
    where jsonb_typeof(ud.data->'tasks') = 'array'
      and ud.data is distinct from (
        select b.data from public.user_backups b where b.user_id = ud.user_id order by b.created_at desc limit 1
      )
    returning 1
  )
  select count(*) into n from ins;
  return n;
end $$;
revoke all on function public.run_daily_backup() from public, anon, authenticated;
revoke all on function public.backup_summary(jsonb) from public, anon;
grant execute on function public.backup_summary(jsonb) to authenticated;

-- 00:00 UTC = 03:00 Türkiye saati
select cron.unschedule('planzen-daily-backup') where exists (select 1 from cron.job where jobname = 'planzen-daily-backup');
select cron.schedule('planzen-daily-backup', '0 0 * * *', $$select public.run_daily_backup()$$);
