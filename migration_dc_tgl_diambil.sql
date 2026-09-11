-- Tambah kolom tanggal pengambilan part untuk Reservasi (DC & Reservasi > Reservasi)
alter table public.direct_charge add column if not exists tgl_diambil date;
