const model = require('../models/kosModel');

// CONTROLLER Kos: membaca request, memanggil model, memilih kode HTTP dan isi JSON.
// Endpoint publik (tanpa login). Pencarian dan filter lanjutan milik Modul 1.

// GET /kos
async function daftar(req, res) {
  return res.json(await model.daftarAktif());
}

// GET /kos/:id
async function detail(req, res) {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ message: 'ID kos tidak valid' });
  }

  const kos = await model.cariAktifById(id);
  if (!kos) return res.status(404).json({ message: 'Kos tidak ditemukan' });
  return res.json(kos);
}

module.exports = { daftar, detail };
