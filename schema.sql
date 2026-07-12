-- ============================================================
-- Rekap SPK & Kontrak COO — Prabumulih Field
-- Jalankan di Supabase SQL Editor (sekali)
-- ============================================================

-- 1. SPK Standalone
create table if not exists public.spk (
  id text primary key,
  no_spk text,
  tanggal date,
  vendor text,
  uraian text,
  nilai_kontrak numeric(18,2) default 0,
  realisasi numeric(18,2) default 0,
  progress integer default 0,
  status text default 'Open',
  keterangan text,
  created_at timestamptz default now()
);

-- 2. Direct Charge (Permintaan Part)
create table if not exists public.direct_charge (
  id text primary key,
  no_perm text,
  tanggal date,
  nama_part text,
  jumlah numeric(10,2) default 0,
  satuan text,
  harga_satuan numeric(18,2) default 0,
  total numeric(18,2) default 0,
  kimap text,
  nomor_pr text,
  nomor_po text,
  nomor_memo text,
  nomor_reservasi text,
  status text default 'Pending',
  keterangan text,
  created_at timestamptz default now()
);

-- Migrasi: jalankan ini jika tabel direct_charge sudah ada sebelumnya
-- alter table public.direct_charge add column if not exists kimap text;
-- alter table public.direct_charge add column if not exists nomor_pr text;
-- alter table public.direct_charge add column if not exists nomor_po text;
-- alter table public.direct_charge add column if not exists nomor_memo text;
-- alter table public.direct_charge add column if not exists nomor_reservasi text;

-- 3. Master Kontrak COO
create table if not exists public.master_kontrak (
  id text primary key,
  custom_id text,
  nomor_spb text,
  vendor text,
  judul_kontrak text,
  nilai_kontrak numeric(18,2) default 0,
  tgl_mulai date,
  tgl_berakhir date,
  pic text,
  status text default 'Aktif',
  created_at timestamptz default now()
);

-- 4. CoO SPK (work orders di bawah master kontrak)
create table if not exists public.coo_spk (
  id text primary key,
  id_kontrak text references public.master_kontrak(id) on delete cascade,
  custom_id text,
  nomor_spk text,
  deskripsi text,
  nilai_spk numeric(18,2) default 0,
  tgl_terbit date,
  tgl_mulai date,
  tgl_selesai date,
  status text default 'Open',
  catatan text,
  created_at timestamptz default now()
);

-- 5. Purchase Request (linked ke CoO SPK)
create table if not exists public.purchase_request (
  id text primary key,
  id_coo text references public.coo_spk(id) on delete cascade,
  custom_id text,
  nomor_pr text,
  tgl_pr date,
  deskripsi text,
  estimasi_nilai numeric(18,2) default 0,
  catatan text,
  created_at timestamptz default now()
);

-- 6. Penagihan SA / Realisasi (linked ke CoO SPK)
create table if not exists public.penagihan_sa (
  id text primary key,
  id_coo text references public.coo_spk(id) on delete cascade,
  custom_id text,
  nomor_sa text,
  tgl_sa date,
  deskripsi text,
  nilai_sa numeric(18,2) default 0,
  nomor_invoice text,
  catatan text,
  created_at timestamptz default now()
);

-- ============================================================
-- RLS — HANYA user yang sudah login (authenticated) yang boleh akses
-- (diperketat setelah schema awal; policy aktif di DB bernama "auth_only",
--  bukan "allow_all" seperti draft awal file ini — lihat verifikasi 2026-07-12)
-- ============================================================
alter table public.spk enable row level security;
alter table public.direct_charge enable row level security;
alter table public.master_kontrak enable row level security;
alter table public.coo_spk enable row level security;
alter table public.purchase_request enable row level security;
alter table public.penagihan_sa enable row level security;

create policy "auth_only" on public.spk for all using (auth.role()='authenticated') with check (auth.role()='authenticated');
create policy "auth_only" on public.direct_charge for all using (auth.role()='authenticated') with check (auth.role()='authenticated');
create policy "auth_only" on public.master_kontrak for all using (auth.role()='authenticated') with check (auth.role()='authenticated');
create policy "auth_only" on public.coo_spk for all using (auth.role()='authenticated') with check (auth.role()='authenticated');
create policy "auth_only" on public.purchase_request for all using (auth.role()='authenticated') with check (auth.role()='authenticated');
create policy "auth_only" on public.penagihan_sa for all using (auth.role()='authenticated') with check (auth.role()='authenticated');
