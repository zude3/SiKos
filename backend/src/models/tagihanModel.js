const db = require('../config/db');
const { removeStoredProof, saveStoredProof } = require('../utils/buktiStorage');

const invoiceSelect = `
  SELECT t.id, t.booking_id,
         DATE_FORMAT(t.periode, '%Y-%m-%d') AS periode,
         t.jumlah,
         DATE_FORMAT(t.jatuh_tempo, '%Y-%m-%d') AS jatuh_tempo,
         CASE
           WHEN t.status = 'belum_bayar' AND t.jatuh_tempo < CURRENT_DATE()
             THEN 'terlambat'
           ELSE t.status
         END AS status,
         DATE_FORMAT(t.tgl_lunas, '%Y-%m-%d') AS tgl_lunas,
         k.nama AS kos, kamar.nomor AS nomor_kamar,
         bp.id AS bukti_id, bp.catatan_penolakan,
         DATE_FORMAT(bp.updated_at, '%Y-%m-%dT%H:%i:%sZ') AS bukti_dibuat
  FROM tagihan t
  JOIN booking b ON b.id = t.booking_id
  JOIN kamar ON kamar.id = b.kamar_id
  JOIN kos k ON k.id = kamar.kos_id
  LEFT JOIN bukti_pembayaran bp ON bp.tagihan_id = t.id
`;

function createError(message, status) {
  const error = new Error(message);
  error.status = status;
  return error;
}

function formatInvoice(row) {
  return {
    id: row.id,
    booking_id: row.booking_id,
    periode: row.periode,
    jumlah: row.jumlah,
    jatuh_tempo: row.jatuh_tempo,
    status: row.status,
    tgl_lunas: row.tgl_lunas,
    kos: row.kos,
    nomor_kamar: row.nomor_kamar,
    bukti: row.bukti_id
      ? {
          url: `/tagihan/${row.id}/bukti`,
          catatan_penolakan: row.catatan_penolakan,
          dibuat: row.bukti_dibuat,
        }
      : null,
  };
}

async function list(user) {
  const ownerCondition = user.role === 'pemilik'
    ? 'k.pemilik_user_id = ?'
    : 'b.user_id = ?';
  const [rows] = await db.query(
    `${invoiceSelect}
     WHERE ${ownerCondition}
     ORDER BY t.jatuh_tempo DESC, t.id DESC
     LIMIT 100`,
    [user.id]
  );
  return rows;
}

async function getById(id, user) {
  const [rows] = await db.query(
    `${invoiceSelect}
     WHERE t.id = ?
       AND ((? = 'penyewa' AND b.user_id = ?)
         OR (? = 'pemilik' AND k.pemilik_user_id = ?))`,
    [id, user.role, user.id, user.role, user.id]
  );
  return rows[0] || null;
}

async function create(bookingId, period, dueDate, ownerId) {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [bookings] = await connection.query(
      `SELECT b.id, b.status,
              DATE_FORMAT(b.tgl_mulai, '%Y-%m-%d') AS tgl_mulai,
              DATE_FORMAT(b.tgl_selesai, '%Y-%m-%d') AS tgl_selesai,
              kamar.harga
       FROM booking b
       JOIN kamar ON kamar.id = b.kamar_id
       JOIN kos k ON k.id = kamar.kos_id
       WHERE b.id = ? AND k.pemilik_user_id = ?
       FOR UPDATE`,
      [bookingId, ownerId]
    );
    if (bookings.length === 0) {
      throw createError('Booking tidak ditemukan', 404);
    }
    const booking = bookings[0];
    if (
      booking.status !== 'disetujui' ||
      period < String(booking.tgl_mulai).slice(0, 7) + '-01' ||
      period > String(booking.tgl_selesai).slice(0, 10)
    ) {
      throw createError('Booking belum disetujui atau periode di luar masa booking', 409);
    }

    const [result] = await connection.query(
      `INSERT INTO tagihan (booking_id, periode, jumlah, jatuh_tempo)
       VALUES (?, ?, ?, ?)`,
      [bookingId, period, booking.harga, dueDate]
    );
    await connection.commit();
    return result.insertId;
  } catch (error) {
    await connection.rollback();
    if (error.code === 'ER_DUP_ENTRY') {
      throw createError('Tagihan untuk periode ini sudah dibuat', 409);
    }
    throw error;
  } finally {
    connection.release();
  }
}

async function saveBukti(id, userId, buffer, extension) {
  const connection = await db.getConnection();
  let newRelativePath;
  let oldRelativePath;
  try {
    await connection.beginTransaction();
    const [rows] = await connection.query(
      `SELECT t.status, b.user_id, bp.path
       FROM tagihan t
       JOIN booking b ON b.id = t.booking_id
       LEFT JOIN bukti_pembayaran bp ON bp.tagihan_id = t.id
       WHERE t.id = ?
       FOR UPDATE`,
      [id]
    );
    if (rows.length === 0 || rows[0].user_id !== userId) {
      throw createError('Tagihan tidak ditemukan', 404);
    }
    if (rows[0].status === 'lunas') {
      throw createError('Tagihan yang sudah lunas tidak dapat menerima bukti', 409);
    }

    oldRelativePath = rows[0].path;
    newRelativePath = await saveStoredProof(buffer, extension);
    await connection.query(
      `INSERT INTO bukti_pembayaran (tagihan_id, path, catatan_penolakan)
       VALUES (?, ?, NULL)
       ON DUPLICATE KEY UPDATE
         path = VALUES(path), catatan_penolakan = NULL`,
      [id, newRelativePath]
    );
    await connection.query(
      `UPDATE tagihan
       SET status = 'menunggu_verifikasi', tgl_lunas = NULL
       WHERE id = ?`,
      [id]
    );
    await connection.commit();
    return { newRelativePath, oldRelativePath };
  } catch (error) {
    await connection.rollback();
    if (newRelativePath) await removeStoredProof(newRelativePath);
    throw error;
  } finally {
    connection.release();
  }
}

async function deleteBukti(id, userId) {
  const connection = await db.getConnection();
  let oldRelativePath;
  try {
    await connection.beginTransaction();
    const [rows] = await connection.query(
      `SELECT t.status, b.user_id, bp.path
       FROM tagihan t
       JOIN booking b ON b.id = t.booking_id
       LEFT JOIN bukti_pembayaran bp ON bp.tagihan_id = t.id
       WHERE t.id = ?
       FOR UPDATE`,
      [id]
    );
    if (
      rows.length === 0 ||
      rows[0].user_id !== userId ||
      !rows[0].path
    ) {
      throw createError('Bukti pembayaran tidak ditemukan', 404);
    }
    if (!['menunggu_verifikasi', 'ditolak'].includes(rows[0].status)) {
      throw createError('Bukti tidak dapat dihapus pada status tagihan ini', 409);
    }

    oldRelativePath = rows[0].path;
    await connection.query(
      'DELETE FROM bukti_pembayaran WHERE tagihan_id = ?',
      [id]
    );
    await connection.query(
      `UPDATE tagihan
       SET status = 'belum_bayar', tgl_lunas = NULL
       WHERE id = ?`,
      [id]
    );
    await connection.commit();
    return oldRelativePath;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

async function getBukti(id, user) {
  const [rows] = await db.query(
    `SELECT bp.path, b.user_id, k.pemilik_user_id
     FROM bukti_pembayaran bp
     JOIN tagihan t ON t.id = bp.tagihan_id
     JOIN booking b ON b.id = t.booking_id
     JOIN kamar ON kamar.id = b.kamar_id
     JOIN kos k ON k.id = kamar.kos_id
     WHERE t.id = ?`,
    [id]
  );
  if (rows.length === 0) return null;

  const row = rows[0];
  const allowed = user.role === 'penyewa'
    ? row.user_id === user.id
    : user.role === 'pemilik' && row.pemilik_user_id === user.id;
  if (!allowed) {
    throw createError('Tagihan tidak ditemukan', 404);
  }
  return row;
}

async function listSimulationCandidates(userIds, waitSeconds) {
  if (userIds.length === 0) return [];

  const [rows] = await db.query(
    `SELECT t.id,
            DATE_FORMAT(bp.updated_at, '%Y-%m-%d %H:%i:%s.%f') AS bukti_updated_at
     FROM tagihan t
     JOIN booking b ON b.id = t.booking_id
     JOIN bukti_pembayaran bp ON bp.tagihan_id = t.id
     WHERE t.status = 'menunggu_verifikasi'
       AND b.user_id IN (?)
       AND bp.updated_at < NOW() - INTERVAL ? SECOND
     ORDER BY t.id`,
    [userIds, waitSeconds]
  );
  return rows;
}

async function verify(id, ownerId, status, reason, expectedProofUpdatedAt) {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const ownerCondition = ownerId == null ? '' : 'AND k.pemilik_user_id = ?';
    const [rows] = await connection.query(
      `SELECT t.status, bp.id AS bukti_id
       FROM tagihan t
       JOIN booking b ON b.id = t.booking_id
       JOIN kamar ON kamar.id = b.kamar_id
       JOIN kos k ON k.id = kamar.kos_id
       LEFT JOIN bukti_pembayaran bp ON bp.tagihan_id = t.id
       WHERE t.id = ? ${ownerCondition}
       FOR UPDATE`,
      ownerId == null ? [id] : [id, ownerId]
    );
    if (rows.length === 0) {
      if (expectedProofUpdatedAt != null) {
        await connection.rollback();
        return false;
      }
      throw createError('Tagihan tidak ditemukan', 404);
    }
    if (rows[0].status !== 'menunggu_verifikasi' || !rows[0].bukti_id) {
      if (expectedProofUpdatedAt != null) {
        await connection.rollback();
        return false;
      }
      throw createError('Tagihan tidak sedang menunggu verifikasi', 409);
    }

    const proofCondition = expectedProofUpdatedAt == null
      ? ''
      : `AND EXISTS (
           SELECT 1
           FROM bukti_pembayaran bp
           WHERE bp.tagihan_id = ? AND bp.updated_at = ?
         )`;
    const [result] = await connection.query(
      `UPDATE tagihan
       SET status = ?, tgl_lunas = ${status === 'lunas' ? 'CURRENT_DATE()' : 'NULL'}
       WHERE id = ? AND status = 'menunggu_verifikasi'
       ${proofCondition}`,
      expectedProofUpdatedAt == null
        ? [status, id]
        : [status, id, id, expectedProofUpdatedAt]
    );
    if (result.affectedRows === 0) {
      await connection.rollback();
      return false;
    }
    if (status === 'ditolak') {
      await connection.query(
        'UPDATE bukti_pembayaran SET catatan_penolakan = ? WHERE tagihan_id = ?',
        [reason, id]
      );
    } else {
      await connection.query(
        'UPDATE bukti_pembayaran SET catatan_penolakan = NULL WHERE tagihan_id = ?',
        [id]
      );
    }
    await connection.commit();
    return true;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

module.exports = {
  create,
  deleteBukti,
  formatInvoice,
  getById,
  getBukti,
  list,
  listSimulationCandidates,
  saveBukti,
  verify,
};
