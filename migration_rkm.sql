-- RKM (Rencana Kebutuhan Material) — daftar rencana kebutuhan material tahunan
-- yang diajukan ke SCM, per divisi (Hoist/Static/Rotating). Realisasinya nanti
-- dicatat manual lewat menu DC & Reservasi (Reservasi) yang sudah ada.

create table if not exists public.rkm (
  id text primary key,
  fungsi text not null default 'Hoist' check (fungsi in ('Hoist','Static','Rotating')),
  tahun text not null,
  part_number text,
  nama_part text not null,
  kategori text,
  satuan text,
  qty_rencana numeric(10,2) default 0,
  harga_satuan_estimasi numeric(18,2) default 0,
  total_estimasi numeric(18,2) default 0,
  keterangan text,
  status text not null default 'Draft' check (status in ('Draft','Diajukan','Disetujui','Ditolak')),
  created_at timestamptz default now(),
  created_by text,
  updated_by text
);

create index if not exists idx_rkm_fungsi_tahun on public.rkm (fungsi, tahun);

alter table public.rkm enable row level security;
create policy "auth_only" on public.rkm for all using (auth.role()='authenticated') with check (auth.role()='authenticated');
