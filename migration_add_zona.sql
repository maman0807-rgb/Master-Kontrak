-- Tambah kolom zona di master_kontrak
-- Jalankan di Supabase SQL Editor

ALTER TABLE master_kontrak
  ADD COLUMN IF NOT EXISTS zona TEXT DEFAULT 'Prabumulih Field';

-- Set nilai default untuk semua data existing
UPDATE master_kontrak SET zona = 'Prabumulih Field' WHERE zona IS NULL;
