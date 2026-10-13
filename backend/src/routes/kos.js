const express = require('express');
const db = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

const router = express.Router();

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const [kosRows] = await db.query(
      `SELECT k.id, k.nama, k.alamat, k.lat, k.lng, k.deskripsi,
              k.nama_pemilik, k.kontak_pemilik,
              (SELECT MIN(m.harga) FROM kamar m WHERE m.kos_id = k.id) AS harga_mulai,
              (SELECT COUNT(*) FROM kamar m WHERE m.kos_id = k.id AND m.tersedia = 1) AS kamar_tersedia,
              (SELECT f.path FROM kos_foto f WHERE f.kos_id = k.id ORDER BY f.urutan LIMIT 1) AS foto_utama,
              (SELECT ROUND(AVG(u.rating), 1) FROM ulasan u WHERE u.kos_id = k.id) AS rata_rata_rating,
              (SELECT COUNT(*) FROM ulasan u WHERE u.kos_id = k.id) AS jumlah_ulasan
       FROM kos k
       WHERE k.aktif = 1
       ORDER BY k.id`
    );

    const fasilitasPerKos = {};
    if (kosRows.length > 0) {
      const [fasRows] = await db.query(
        `SELECT kf.kos_id, f.nama
         FROM kos_fasilitas kf
         JOIN fasilitas f ON f.id = kf.fasilitas_id
         WHERE kf.kos_id IN (?)
         ORDER BY f.id`,
        [kosRows.map((k) => k.id)]
      );
      for (const row of fasRows) {
        (fasilitasPerKos[row.kos_id] ||= []).push(row.nama);
      }
    }

    res.json(kosRows.map((k) => ({ ...k, fasilitas: fasilitasPerKos[k.id] || [] })));
  })
);

router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ message: 'ID kos tidak valid' });
    }

    const [kosRows] = await db.query(
      `SELECT k.id, k.nama, k.alamat, k.lat, k.lng, k.deskripsi,
              k.nama_pemilik, k.kontak_pemilik,
              (SELECT ROUND(AVG(u.rating), 1) FROM ulasan u WHERE u.kos_id = k.id) AS rata_rata_rating,
              (SELECT COUNT(*) FROM ulasan u WHERE u.kos_id = k.id) AS jumlah_ulasan
       FROM kos k
       WHERE k.id = ? AND k.aktif = 1`,
      [id]
    );
    if (kosRows.length === 0) {
      return res.status(404).json({ message: 'Kos tidak ditemukan' });
    }

    const [fotoRows] = await db.query(
      'SELECT path FROM kos_foto WHERE kos_id = ? ORDER BY urutan',
      [id]
    );
    const [fasRows] = await db.query(
      `SELECT f.nama
       FROM kos_fasilitas kf
       JOIN fasilitas f ON f.id = kf.fasilitas_id
       WHERE kf.kos_id = ?
       ORDER BY f.id`,
      [id]
    );
    const [kamarRows] = await db.query(
      'SELECT id, nomor, harga, tersedia FROM kamar WHERE kos_id = ? ORDER BY nomor',
      [id]
    );

    res.json({
      ...kosRows[0],
      foto: fotoRows.map((f) => f.path),
      fasilitas: fasRows.map((f) => f.nama),
      kamar: kamarRows.map((m) => ({ ...m, tersedia: Boolean(m.tersedia) })),
    });
  })
);

module.exports = router;
