-- ============================================================
-- Migration: TVM Trakindo (Total Vendor Maintenance)
-- Jalankan di Supabase SQL Editor
-- ============================================================

create table if not exists public.tvm_coo (
  id text primary key,
  nomor_coo text,
  tanggal date,
  fungsi text default 'Hoist & Heavy Equipment',
  deskripsi text,
  nilai numeric(18,2) default 0,
  tgl_mulai date,
  tgl_selesai date,
  status text default 'Open',
  catatan text,
  created_by text,
  updated_by text,
  created_at timestamptz default now()
);

alter table public.tvm_coo enable row level security;
drop policy if exists "auth_tvm" on public.tvm_coo;
create policy "auth_tvm" on public.tvm_coo
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
