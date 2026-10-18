const model = require('../models/komplainModel');
const rules = require('../services/komplainRules');
const { hapusFileUnggahan, hapusFileTersimpan } = require('../middleware/upload');

// CONTROLLER Komplain: membaca request, memanggil validasi (komplainRules) dan model,
// lalu memilih kode HTTP dan isi JSON balasan. Tidak menulis SQL.
// Handler berupa fungsi async biasa; pembungkus asyncHandler dipasang di routes/komplain.js.
// Kepemilikan selalu dicek dengan user_id dari token (req.user.id), bukan dari body (NFR-04).

// Mengambil komplain milik user yang login. Bila gagal, respons error sudah dikirim dan
// fungsi mengembalikan null (pemanggil cukup berhenti).
async function muatKomplainSaya(req, res) {
  const id = rules.parseId(req.params.id);
  if (!id) {
    res.status(400).json({ message: 'ID komplain tidak valid' });
    return null;
  }
  const komplain = await model.cariMilik(id, req.user.id);
  if (!komplain) {
    res.status(404).json({ message: 'Komplain tidak ditemukan' });
    return null;
  }
  return komplain;
}

// D1. POST /komplain  (multipart: booking_id, kategori, deskripsi, foto[] maks 3)
async function buat(req, res) {
  const files = req.files || [];

  const { error, value } = rules.validasiBuat(req.body);
  if (error) {
    await hapusFileUnggahan(files);
    return res.status(400).json({ message: error });
  }

  // Komplain hanya untuk booking milik sendiri yang sedang aktif.
  if (!(await model.adaBookingAktif(value.booking_id, req.user.id))) {
    await hapusFileUnggahan(files);
    return res.status(404).json({
      message: 'Booking aktif tidak ditemukan. Komplain hanya untuk sewa yang sedang berjalan',
    });
  }

  try {
    const id = await model.buat({
      userId: req.user.id,
      bookingId: value.booking_id,
      kategori: value.kategori,
      deskripsi: value.deskripsi,
      pathFoto: files.map((f) => `komplain/${f.filename}`),
    });
    return res.status(201).json({ id, status: 'diterima', jumlah_foto: files.length });
  } catch (err) {
    await hapusFileUnggahan(files); // transaksi gagal: jangan tinggalkan file yatim
    throw err;
  }
}

// D2. GET /komplain?status=diterima|diproses|selesai
async function daftar(req, res) {
  const { status } = req.query;
  if (status !== undefined && !rules.STATUS.includes(status)) {
    return res
      .status(400)
      .json({ message: `Status harus salah satu dari: ${rules.STATUS.join(', ')}` });
  }

  const rows = await model.daftarMilik(req.user.id, status);
  return res.json(rows.map((r) => ({ ...r, dikonfirmasi: Boolean(r.dikonfirmasi) })));
}

// D3. GET /komplain/:id  -> detail + foto + linimasa
async function detail(req, res) {
  const komplain = await muatKomplainSaya(req, res);
  if (!komplain) return undefined;

  const [foto, linimasa] = await Promise.all([
    model.daftarFoto(komplain.id),
    model.linimasa(komplain.id),
  ]);
  return res.json({
    ...komplain,
    dikonfirmasi: Boolean(komplain.dikonfirmasi),
    foto,
    linimasa,
  });
}

// D4. PUT /komplain/:id  (JSON: kategori dan/atau deskripsi) - hanya saat status "diterima"
async function ubah(req, res) {
  const komplain = await muatKomplainSaya(req, res);
  if (!komplain) return undefined;

  const alasan = rules.alasanTidakBisaUbah(komplain);
  if (alasan) return res.status(409).json({ message: alasan });

  const { error, value } = rules.validasiUbah(req.body);
  if (error) return res.status(400).json({ message: error });

  // Model mengulang syarat status di WHERE: simulasi bisa memajukan status di antara dua query.
  if (!(await model.ubahJikaDiterima(komplain.id, req.user.id, value))) {
    return res.status(409).json({ message: rules.alasanTidakBisaUbah({ status: 'diproses' }) });
  }
  return res.json({ id: komplain.id, ...value });
}

// D4. DELETE /komplain/:id  - hanya saat status "diterima"
async function hapus(req, res) {
  const komplain = await muatKomplainSaya(req, res);
  if (!komplain) return undefined;

  const alasan = rules.alasanTidakBisaUbah(komplain);
  if (alasan) return res.status(409).json({ message: alasan });

  const pathFoto = await model.daftarFoto(komplain.id); // dibaca sebelum baris dihapus
  if (!(await model.hapusJikaDiterima(komplain.id, req.user.id))) {
    return res.status(409).json({ message: rules.alasanTidakBisaUbah({ status: 'diproses' }) });
  }

  // Baris foto dan log ikut terhapus (ON DELETE CASCADE); file di disk dihapus di sini.
  await hapusFileTersimpan(pathFoto);
  return res.json({ message: 'Komplain dihapus' });
}

// D5a. PUT /komplain/:id/konfirmasi
async function konfirmasi(req, res) {
  const komplain = await muatKomplainSaya(req, res);
  if (!komplain) return undefined;

  const alasan = rules.alasanTidakBisaKonfirmasi(komplain);
  if (alasan) return res.status(409).json({ message: alasan });

  if (!(await model.konfirmasiJikaSelesai(komplain.id, req.user.id))) {
    return res.status(409).json({ message: 'Komplain tidak bisa dikonfirmasi saat ini' });
  }
  return res.json({ id: komplain.id, dikonfirmasi: true });
}

// D5b. POST /komplain/:id/penilaian  (JSON: rating 1-5, komentar opsional)
async function beriPenilaian(req, res) {
  const komplain = await muatKomplainSaya(req, res);
  if (!komplain) return undefined;

  const alasan = rules.alasanTidakBisaMenilai(komplain);
  if (alasan) return res.status(409).json({ message: alasan });

  const { error, value } = rules.validasiPenilaian(req.body);
  if (error) return res.status(400).json({ message: error });

  if (!(await model.beriPenilaian(komplain.id, req.user.id, value.rating, value.komentar))) {
    return res.status(409).json({ message: 'Penilaian sudah diberikan' });
  }
  return res.status(201).json({
    id: komplain.id,
    rating_penanganan: value.rating,
    komentar_penanganan: value.komentar,
  });
}

module.exports = { buat, daftar, detail, ubah, hapus, konfirmasi, beriPenilaian };
