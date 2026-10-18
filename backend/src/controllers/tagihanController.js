const fs = require('fs');
const path = require('path');

const tagihanModel = require('../models/tagihanModel');
const asyncHandler = require('../utils/asyncHandler');
const {
  imageExtension,
  removeStoredProof,
  storedProofPath,
} = require('../utils/buktiStorage');
const { isDate, parseId } = require('../utils/validators');

function controllerAction(action) {
  return asyncHandler(async (req, res, next) => {
    try {
      await action(req, res);
    } catch (error) {
      if (error.status && error.status < 500) {
        return res.status(error.status).json({ message: error.message });
      }
      next(error);
    }
  });
}

const list = controllerAction(async (req, res) => {
  const rows = await tagihanModel.list(req.user);
  res.json(rows.map(tagihanModel.formatInvoice));
});

const create = controllerAction(async (req, res) => {
  const body = req.body || {};
  const bookingId = parseId(String(body.booking_id || ''));
  const period = body.periode;
  const dueDate = body.jatuh_tempo;
  if (!bookingId) {
    return res.status(400).json({ message: 'ID booking tidak valid' });
  }
  if (!isDate(period) || !period.endsWith('-01')) {
    return res.status(400).json({ message: 'Periode harus berupa tanggal awal bulan (YYYY-MM-01)' });
  }
  if (!isDate(dueDate) || dueDate < period) {
    return res.status(400).json({ message: 'Tanggal jatuh tempo tidak valid' });
  }

  const id = await tagihanModel.create(bookingId, period, dueDate, req.user.id);
  res.status(201).json({ id, booking_id: bookingId });
});

const getById = controllerAction(async (req, res) => {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ message: 'ID tagihan tidak valid' });

  const row = await tagihanModel.getById(id, req.user);
  if (!row) {
    return res.status(404).json({ message: 'Tagihan tidak ditemukan' });
  }
  res.json(tagihanModel.formatInvoice(row));
});

const uploadBukti = controllerAction(async (req, res) => {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ message: 'ID tagihan tidak valid' });
  if (!req.file) {
    return res.status(400).json({ message: 'Bukti pembayaran wajib diunggah' });
  }

  const extension = imageExtension(req.file.buffer);
  if (!extension) {
    return res.status(400).json({ message: 'Isi file bukan gambar JPG, PNG, atau WebP yang valid' });
  }

  const result = await tagihanModel.saveBukti(
    id,
    req.user.id,
    req.file.buffer,
    extension
  );

  if (
    result.oldRelativePath &&
    result.oldRelativePath !== result.newRelativePath
  ) {
    await removeStoredProof(result.oldRelativePath);
  }
  res.status(201).json({
    tagihan_id: id,
    status: 'menunggu_verifikasi',
    bukti_url: `/tagihan/${id}/bukti`,
  });
});

const deleteBukti = controllerAction(async (req, res) => {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ message: 'ID tagihan tidak valid' });

  const oldRelativePath = await tagihanModel.deleteBukti(id, req.user.id);
  await removeStoredProof(oldRelativePath);
  res.json({ tagihan_id: id, status: 'belum_bayar' });
});

const getBukti = controllerAction(async (req, res) => {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ message: 'ID tagihan tidak valid' });

  const proof = await tagihanModel.getBukti(id, req.user);
  if (!proof) {
    return res.status(404).json({ message: 'Bukti pembayaran tidak ditemukan' });
  }
  const filePath = storedProofPath(proof.path);
  if (!filePath) {
    return res.status(404).json({ message: 'Bukti pembayaran tidak ditemukan' });
  }
  try {
    const image = await fs.promises.readFile(filePath);
    const extension = path.extname(filePath).slice(1);
    const contentType = {
      jpg: 'image/jpeg',
      png: 'image/png',
      webp: 'image/webp',
    }[extension];
    res.set('Cache-Control', 'private, no-store');
    res.type(contentType).send(image);
  } catch (error) {
    if (error.code === 'ENOENT') {
      return res.status(404).json({ message: 'Bukti pembayaran tidak ditemukan' });
    }
    throw error;
  }
});

const verify = controllerAction(async (req, res) => {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ message: 'ID tagihan tidak valid' });

  const body = req.body || {};
  const status = body.status;
  const reason = typeof body.catatan_penolakan === 'string'
    ? body.catatan_penolakan.trim()
    : '';
  if (!['lunas', 'ditolak'].includes(status)) {
    return res.status(400).json({ message: 'Status verifikasi harus lunas atau ditolak' });
  }
  if (status === 'ditolak' && (!reason || reason.length > 255)) {
    return res.status(400).json({ message: 'Alasan penolakan wajib diisi (maksimal 255 karakter)' });
  }

  await tagihanModel.verify(id, req.user.id, status, reason);
  res.json({ id, status, catatan_penolakan: status === 'ditolak' ? reason : null });
});

module.exports = {
  create,
  deleteBukti,
  getBukti,
  getById,
  list,
  uploadBukti,
  verify,
};
