// Serverless function: ekstrak data PO/RO material (PDF) jadi JSON terstruktur via Claude API.
// Butuh env var ANTHROPIC_API_KEY di Vercel project settings.
module.exports = async (req, res) => {
  if (req.method !== 'POST') { res.status(405).json({ error: 'Method not allowed' }); return; }

  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) { res.status(500).json({ error: 'ANTHROPIC_API_KEY belum diset di Vercel' }); return; }

  const { pdfBase64 } = req.body || {};
  if (!pdfBase64) { res.status(400).json({ error: 'pdfBase64 wajib diisi' }); return; }

  const tool = {
    name: 'extract_po',
    description: 'Ekstrak data Purchase Order / Release Order Material dari dokumen PDF Pertamina EP',
    input_schema: {
      type: 'object',
      properties: {
        nomorPO: { type: 'string', description: 'Nomor RO/PO, contoh: 4300054720' },
        vendor: { type: 'string' },
        tanggal: { type: 'string', description: 'Tanggal PO/RO format YYYY-MM-DD, kosongkan jika tidak jelas' },
        items: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              namaPart: { type: 'string', description: 'Deskripsi/nama material, ringkas satu baris' },
              partNumber: { type: 'string', description: 'Material No / P/N / MPN dari vendor, jika ada' },
              jumlah: { type: 'number' },
              satuan: { type: 'string', description: 'Contoh: PCS, SET, UNIT' },
              hargaSatuan: { type: 'number', description: 'Harga per unit dalam Rupiah, angka polos tanpa titik/koma pemisah ribuan' }
            },
            required: ['namaPart', 'jumlah', 'satuan', 'hargaSatuan']
          }
        }
      },
      required: ['items']
    }
  };

  try {
    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-sonnet-5',
        max_tokens: 4096,
        tools: [tool],
        tool_choice: { type: 'tool', name: 'extract_po' },
        messages: [{
          role: 'user',
          content: [
            { type: 'document', source: { type: 'base64', media_type: 'application/pdf', data: pdfBase64 } },
            {
              type: 'text',
              text: 'Ini dokumen Purchase Order / Release Order Material dari Pertamina EP (bisa multi-halaman, deskripsi item kadang terpotong ke baris berikutnya). Ekstrak nomor PO/RO, vendor, tanggal terbit, dan SEMUA baris item material (gabungkan deskripsi multi-baris jadi satu namaPart yang ringkas per item, ambil part number/PN/MPN vendor kalau ada, qty, satuan, dan harga satuan dalam Rupiah). Panggil tool extract_po dengan hasilnya.'
            }
          ]
        }]
      })
    });

    const data = await r.json();
    if (!r.ok) { res.status(r.status).json({ error: data?.error?.message || 'Anthropic API error' }); return; }

    const toolUse = Array.isArray(data.content) ? data.content.find(c => c.type === 'tool_use') : null;
    if (!toolUse) { res.status(502).json({ error: 'Model tidak mengembalikan data terstruktur' }); return; }

    res.status(200).json(toolUse.input);
  } catch (err) {
    res.status(500).json({ error: err.message || 'Gagal memproses PDF' });
  }
};
