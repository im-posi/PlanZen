-- PlanZen: kullanıcının kendi hesabını ve tüm verisini silmesi (KVKK)
-- Diğer tablolar auth.users'a ON DELETE CASCADE bağlı olduğundan hepsi birlikte silinir.
create or replace function public.delete_my_account()
returns void language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'oturum yok'; end if;
  delete from public.push_log where user_id = me;
  delete from auth.users where id = me;
end $$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
