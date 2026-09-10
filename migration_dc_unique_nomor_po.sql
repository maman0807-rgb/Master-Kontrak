-- Cegah 1 No. PO/RO diinput dobel sebagai Direct Charge (jaga-jaga kalau ada 2 user
-- input bersamaan atau lewat Import Excel — app sudah cek ini juga, ini backstop di DB).
-- Reservasi tidak kena aturan ini (field nomor_po memang kosong untuk Reservasi).
--
-- Jalankan ini di Supabase SQL Editor.

create unique index if not exists direct_charge_nomor_po_unique
  on public.direct_charge (lower(trim(nomor_po)))
  where jenis = 'Direct Charge' and nomor_po is not null and trim(nomor_po) <> '';
