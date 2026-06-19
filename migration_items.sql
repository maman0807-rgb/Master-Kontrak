-- Tambah kolom items (JSONB array) ke tabel direct_charge
-- Jalankan ini di Supabase SQL Editor
ALTER TABLE direct_charge ADD COLUMN IF NOT EXISTS items JSONB DEFAULT '[]'::jsonb;
