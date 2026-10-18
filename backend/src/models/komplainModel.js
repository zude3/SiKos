const db = require('../config/db');

// MODEL Komplain: satu-satunya lapisan yang menulis SQL untuk tabel komplain,
// komplain_foto, dan komplain_log. Tidak mengenal req/res dan tidak memutuskan kode HTTP.
// Fungsi berakhiran "JikaXxx" memeriksa syarat status di WHERE, sehingga aman terhadap
// perubahan status yang terjadi di antara dua query (mis. oleh simulasi pemilik).

const KOLOM_BOLEH_UBAH = ['kategori', 'deskripsi']; // daftar putih nama kolom untuk UPDATE

// Booking milik user yang disetujui dan masa sewanya belum berakhir ("sewa aktif").
async function adaBookingAktif(bookingId, userId) {
  const [rows] = await db.query(
    `SELECT id FROM booking
     WHERE id = ? AND user_id = ? AND status = 'disetujui' AND tgl_selesai >= CURDATE()`,
    [bookingId, userId]
  );
  return rows.length > 0;
}

// D1: membuat komplain + foto + baris log awal dalam satu transaksi. Mengembalikan id baru.
async function buat({ userId, bookingId, kategori, deskripsi, pathFoto = [] }) {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    const [hasil] = await conn.query(
      'INSERT INTO komplain (user_id, booking_id, kategori, deskripsi) VALUES (?, ?, ?, ?)',
      [userId, bookingId, kategori, deskripsi]
    );
    const id = hasil.insertId;

    if (pathFoto.length > 0) {
      await conn.query('INSERT INTO komplain_foto (komplain_id, path, urutan) VALUES ?', [
        pathFoto.map((p, i) => [id, p, i + 1]),
      ]);
    }
    await conn.query('INSERT INTO komplain_log (komplain_id, status, catatan) VALUES (?, ?, ?)', [
      id,
      'diterima',
      'Komplain diterima',
    ]);

    await conn.commit();
    return id;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

// D2: daftar komplain milik user, opsional difilter status (filter dikerjakan di SQL).
async function daftarMilik(userId, status) {
  const params = [userId];
  let kondisi = 'k.user_id = ?';
  if (status) {
    kondisi += ' AND k.status = ?';
    params.push(status);
  }

  const [rows] = await db.query(
    `SELECT k.id, k.booking_id, k.kategori, k.deskripsi, k.status, k.dikonfirmasi,
            k.rating_penanganan, k.created_at, k.updated_at,
            (SELECT f.path FROM komplain_foto f WHERE f.komplain_id = k.id
             ORDER BY f.urutan LIMIT 1) AS foto_utama,
            (SELECT COUNT(*) FROM komplain_foto f WHERE f.komplain_id = k.id) AS jumlah_foto
     FROM komplain k
     WHERE ${kondisi}
     ORDER BY k.created_at DESC, k.id DESC`,
    params
  );
  return rows;
}

// Satu komplain milik user, atau null bila tidak ada / bukan miliknya.
async function cariMilik(id, userId) {
  const [rows] = await db.query('SELECT * FROM komplain WHERE id = ? AND user_id = ?', [id, userId]);
  return rows[0] || null;
}

// D3: path foto (berurutan) dan linimasa perubahan status.
async function daftarFoto(komplainId) {
  const [rows] = await db.query(
    'SELECT path FROM komplain_foto WHERE komplain_id = ? ORDER BY urutan',
    [komplainId]
  );
  return rows.map((r) => r.path);
}

async function linimasa(komplainId) {
  const [rows] = await db.query(
    `SELECT status, catatan, created_at FROM komplain_log
     WHERE komplain_id = ? ORDER BY created_at, id`,
    [komplainId]
  );
  return rows;
}

// D4: ubah kategori/deskripsi hanya bila status masih "diterima". Mengembalikan true bila terubah.
async function ubahJikaDiterima(id, userId, perubahan) {
  const kolom = Object.keys(perubahan).filter((k) => KOLOM_BOLEH_UBAH.includes(k));
  if (kolom.length === 0) return false;

  const [hasil] = await db.query(
    `UPDATE komplain SET ${kolom.map((k) => `${k} = ?`).join(', ')}
     WHERE id = ? AND user_id = ? AND status = 'diterima'`,
    [...kolom.map((k) => perubahan[k]), id, userId]
  );
  return hasil.affectedRows > 0;
}

// D4: hapus hanya bila status masih "diterima". Baris foto dan log ikut terhapus (CASCADE).
async function hapusJikaDiterima(id, userId) {
  const [hasil] = await db.query(
    `DELETE FROM komplain WHERE id = ? AND user_id = ? AND status = 'diterima'`,
    [id, userId]
  );
  return hasil.affectedRows > 0;
}

// D5: konfirmasi selesai (hanya bila status "selesai" dan belum dikonfirmasi) + catat di linimasa.
async function konfirmasiJikaSelesai(id, userId) {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const [hasil] = await conn.query(
      `UPDATE komplain SET dikonfirmasi = 1, tgl_konfirmasi = NOW()
       WHERE id = ? AND user_id = ? AND status = 'selesai' AND dikonfirmasi = 0`,
      [id, userId]
    );
    if (hasil.affectedRows === 0) {
      await conn.rollback();
      return false;
    }
    await conn.query('INSERT INTO komplain_log (komplain_id, status, catatan) VALUES (?, ?, ?)', [
      id,
      'dikonfirmasi',
      'Penyewa mengonfirmasi komplain selesai',
    ]);
    await conn.commit();
    return true;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

// D5: simpan penilaian hanya bila sudah dikonfirmasi dan belum pernah dinilai.
async function beriPenilaian(id, userId, rating, komentar) {
  const [hasil] = await db.query(
    `UPDATE komplain SET rating_penanganan = ?, komentar_penanganan = ?
     WHERE id = ? AND user_id = ? AND dikonfirmasi = 1 AND rating_penanganan IS NULL`,
    [rating, komentar, id, userId]
  );
  return hasil.affectedRows > 0;
}

// --- Dipakai simulasi pemilik fiktif (jobs/komplainSimulator.js) ---

// Id komplain berstatus tertentu yang perubahan status terakhirnya sudah lebih lama dari jeda.
// Perbandingan waktu dilakukan di MySQL agar zona waktu aplikasi tidak berpengaruh.
async function kandidatMajukan(statusSaatIni, jedaDetik) {
  const [rows] = await db.query(
    `SELECT k.id FROM komplain k
     WHERE k.status = ?
       AND TIMESTAMPDIFF(SECOND,
             (SELECT MAX(l.created_at) FROM komplain_log l WHERE l.komplain_id = k.id),
             NOW()) >= ?`,
    [statusSaatIni, jedaDetik]
  );
  return rows.map((r) => r.id);
}

// Memajukan satu komplain dari status "dari" ke "ke" dan menulis log. Mengembalikan true bila
// benar-benar berubah (false bila sudah diubah/dihapus pihak lain di saat yang sama).
async function majukanStatus(id, dari, ke, catatan) {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const [hasil] = await conn.query('UPDATE komplain SET status = ? WHERE id = ? AND status = ?', [
      ke,
      id,
      dari,
    ]);
    const berubah = hasil.affectedRows === 1;
    if (berubah) {
      await conn.query('INSERT INTO komplain_log (komplain_id, status, catatan) VALUES (?, ?, ?)', [
        id,
        ke,
        catatan,
      ]);
    }
    await conn.commit();
    return berubah;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

module.exports = {
  adaBookingAktif,
  buat,
  daftarMilik,
  cariMilik,
  daftarFoto,
  linimasa,
  ubahJikaDiterima,
  hapusJikaDiterima,
  konfirmasiJikaSelesai,
  beriPenilaian,
  kandidatMajukan,
  majukanStatus,
};
