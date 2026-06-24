-- Tambah kolom jenis_anggaran ke tabel spk (ABI atau ABO)
ALTER TABLE spk ADD COLUMN IF NOT EXISTS jenis_anggaran text;
