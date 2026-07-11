-- ============================================================
-- Migration: Audit Trail + User Profiles
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- 1. Tabel profil pengguna
create table if not exists public.user_profiles (
  id uuid primary key,
  email text not null unique,
  nama text,
  role text default 'user',
  created_at timestamptz default now()
);

alter table public.user_profiles enable row level security;
create policy "auth_profiles" on public.user_profiles
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- 2. Trigger: otomatis tambah profil saat user baru signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.user_profiles(id, email)
  values (new.id, new.email)
  on conflict (email) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 3. Kolom audit di semua tabel
alter table public.spk            add column if not exists created_by text;
alter table public.spk            add column if not exists updated_by text;

alter table public.direct_charge  add column if not exists created_by text;
alter table public.direct_charge  add column if not exists updated_by text;

alter table public.master_kontrak add column if not exists created_by text;
alter table public.master_kontrak add column if not exists updated_by text;

alter table public.coo_spk        add column if not exists created_by text;
alter table public.coo_spk        add column if not exists updated_by text;

alter table public.purchase_request add column if not exists created_by text;
alter table public.purchase_request add column if not exists updated_by text;

alter table public.penagihan_sa   add column if not exists created_by text;
alter table public.penagihan_sa   add column if not exists updated_by text;

-- 4. Daftarkan user maman0807@gmail.com sebagai admin
-- (jalankan setelah user maman login minimal 1x, atau setelah trigger berjalan)
-- update public.user_profiles set role = 'admin' where email = 'maman0807@gmail.com';
