const db = require('../config/db');

// MODEL Kos: query data kos fiktif (diisi lewat seed.sql, hanya dibaca).
// Tidak mengenal req/res dan tidak memutuskan kode HTTP.

// Daftar kos aktif beserta ringkasan (harga mulai, kamar tersedia, foto utama, rating)
// dan daftar nama fasilitas.
async function daftarAktif() {
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
  if (kosRows.length === 0) return [];

  const [fasRows] = await db.query(
    `SELECT kf.kos_id, f.nama
     FROM kos_fasilitas kf
     JOIN fasilitas f ON f.id = kf.fasilitas_id
     WHERE kf.kos_id IN (?)
     ORDER BY f.id`,
    [kosRows.map((k) => k.id)]
  );
  const fasilitasPerKos = {};
  for (const row of fasRows) {
    (fasilitasPerKos[row.kos_id] ||= []).push(row.nama);
  }

  return kosRows.map((k) => ({ ...k, fasilitas: fasilitasPerKos[k.id] || [] }));
}

// Detail satu kos aktif (foto, fasilitas, daftar kamar, rating), atau null bila tidak ada.
async function cariAktifById(id) {
  const [kosRows] = await db.query(
    `SELECT k.id, k.nama, k.alamat, k.lat, k.lng, k.deskripsi,
            k.nama_pemilik, k.kontak_pemilik,
            (SELECT ROUND(AVG(u.rating), 1) FROM ulasan u WHERE u.kos_id = k.id) AS rata_rata_rating,
            (SELECT COUNT(*) FROM ulasan u WHERE u.kos_id = k.id) AS jumlah_ulasan
     FROM kos k
     WHERE k.id = ? AND k.aktif = 1`,
    [id]
  );
  if (kosRows.length === 0) return null;

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

  return {
    ...kosRows[0],
    foto: fotoRows.map((f) => f.path),
    fasilitas: fasRows.map((f) => f.nama),
    kamar: kamarRows.map((m) => ({ ...m, tersedia: Boolean(m.tersedia) })),
  };
}

module.exports = { daftarAktif, cariAktifById };
