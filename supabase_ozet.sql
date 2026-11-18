-- PlanZen: otomatik özetler (günlük / haftalık / aylık)
-- Bu dosya zaten kurulu olan yapıyı belgeler. Yeni bir projeye kurarken çalıştır.
-- Özetleri üreten ve push gönderen kod: Edge Function "summary-cron" (Supabase panelinden dağıtılır).

create table if not exists public.user_summaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('day','week','month')),
  period_start date not null,
  period_end date not null,
  payload jsonb not null,
  created_at timestamptz not null default now(),
  read_at timestamptz,
  push_sent_at timestamptz,
  unique (user_id, kind, period_start)
);
create index if not exists user_summaries_user_created on public.user_summaries (user_id, created_at desc);

alter table public.user_summaries enable row level security;
create policy summaries_select_own on public.user_summaries
  for select using (user_id = (select auth.uid()));
-- Yazma yalnızca sunucu tarafından (service role) yapılır; kullanıcı sadece okuyabilir.

create or replace function public.mark_summaries_read(p_ids uuid[])
returns void language sql security definer set search_path = '' as $$
  update public.user_summaries
     set read_at = now()
   where user_id = (select auth.uid()) and id = any(p_ids) and read_at is null;
$$;

-- Her gece 00:00 (Türkiye) özetleri üret, sabah 08:00'de bildirim gönder.
select cron.schedule('planzen-summary-generate','0 21 * * *', $$
  select net.http_post(url := 'https://PROJE_ID.supabase.co/functions/v1/summary-cron?mode=generate',
    headers := jsonb_build_object('Content-Type','application/json','x-cron-secret',(select cron_secret from public.push_config where id = 1)),
    body := '{}'::jsonb, timeout_milliseconds := 55000) $$);
select cron.schedule('planzen-summary-push','0 5 * * *', $$
  select net.http_post(url := 'https://PROJE_ID.supabase.co/functions/v1/summary-cron?mode=push',
    headers := jsonb_build_object('Content-Type','application/json','x-cron-secret',(select cron_secret from public.push_config where id = 1)),
    body := '{}'::jsonb, timeout_milliseconds := 55000) $$);
