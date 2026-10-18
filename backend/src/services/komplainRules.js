// Aturan bisnis Modul 4 (Komplain & Maintenance).
// File ini sengaja murni (tanpa akses database) supaya mudah diuji dan dijelaskan.

const KATEGORI = ['listrik', 'air', 'furnitur', 'kebersihan', 'lainnya'];
const STATUS = ['diterima', 'diproses', 'selesai'];

// Urutan status yang digerakkan simulasi pemilik fiktif.
const STATUS_BERIKUTNYA = { diterima: 'diproses', diproses: 'selesai' };

const DESKRIPSI_MIN = 10;
const DESKRIPSI_MAKS = 1000;
const KOMENTAR_MAKS = 500; // sesuai VARCHAR(500) di tabel komplain

// Mengubah nilai (string/angka) menjadi ID bilangan bulat positif, atau null bila tidak valid.
function parseId(nilai) {
  if (nilai === null || nilai === undefined || nilai === '') return null;
  const n = Number(nilai);
  return Number.isInteger(n) && n > 0 ? n : null;
}

function teks(nilai) {
  return typeof nilai === 'string' ? nilai.trim() : '';
}

function validasiDeskripsi(deskripsi) {
  if (deskripsi.length < DESKRIPSI_MIN) {
    return `Deskripsi minimal ${DESKRIPSI_MIN} karakter`;
  }
  if (deskripsi.length > DESKRIPSI_MAKS) {
    return `Deskripsi maksimal ${DESKRIPSI_MAKS} karakter`;
  }
  return null;
}

// D1: membuat komplain. Mengembalikan { error } atau { value }.
function validasiBuat(body = {}) {
  const bookingId = parseId(body.booking_id);
  if (!bookingId) return { error: 'booking_id wajib diisi dengan angka yang valid' };

  const kategori = teks(body.kategori);
  if (!KATEGORI.includes(kategori)) {
    return { error: `Kategori harus salah satu dari: ${KATEGORI.join(', ')}` };
  }

  const deskripsi = teks(body.deskripsi);
  const errDeskripsi = validasiDeskripsi(deskripsi);
  if (errDeskripsi) return { error: errDeskripsi };

  return { value: { booking_id: bookingId, kategori, deskripsi } };
}

// D4: mengubah komplain. Kategori dan/atau deskripsi, minimal salah satu.
function validasiUbah(body = {}) {
  const value = {};

  if (body.kategori !== undefined) {
    const kategori = teks(body.kategori);
    if (!KATEGORI.includes(kategori)) {
      return { error: `Kategori harus salah satu dari: ${KATEGORI.join(', ')}` };
    }
    value.kategori = kategori;
  }

  if (body.deskripsi !== undefined) {
    const deskripsi = teks(body.deskripsi);
    const errDeskripsi = validasiDeskripsi(deskripsi);
    if (errDeskripsi) return { error: errDeskripsi };
    value.deskripsi = deskripsi;
  }

  if (Object.keys(value).length === 0) {
    return { error: 'Tidak ada data yang diubah (kirim kategori dan/atau deskripsi)' };
  }
  return { value };
}

// D5: penilaian penanganan (bintang 1-5 + komentar opsional).
function validasiPenilaian(body = {}) {
  const rating = Number(body.rating);
  if (body.rating === undefined || body.rating === null || body.rating === '' ||
      !Number.isInteger(rating) || rating < 1 || rating > 5) {
    return { error: 'Rating harus bilangan bulat 1 sampai 5' };
  }

  const komentar = teks(body.komentar);
  if (komentar.length > KOMENTAR_MAKS) {
    return { error: `Komentar maksimal ${KOMENTAR_MAKS} karakter` };
  }
  return { value: { rating, komentar: komentar === '' ? null : komentar } };
}

// Aturan status. Masing-masing mengembalikan pesan alasan bila TIDAK boleh, atau null bila boleh.
function alasanTidakBisaUbah(komplain) {
  return komplain.status === 'diterima'
    ? null
    : 'Komplain sudah diproses, tidak bisa diubah atau dihapus';
}

function alasanTidakBisaKonfirmasi(komplain) {
  if (komplain.dikonfirmasi) return 'Komplain sudah dikonfirmasi';
  if (komplain.status !== 'selesai') return 'Komplain belum selesai, belum bisa dikonfirmasi';
  return null;
}

function alasanTidakBisaMenilai(komplain) {
  if (!komplain.dikonfirmasi) return 'Konfirmasi komplain selesai terlebih dahulu';
  if (komplain.rating_penanganan !== null && komplain.rating_penanganan !== undefined) {
    return 'Penilaian sudah diberikan';
  }
  return null;
}

module.exports = {
  KATEGORI,
  STATUS,
  STATUS_BERIKUTNYA,
  parseId,
  validasiBuat,
  validasiUbah,
  validasiPenilaian,
  alasanTidakBisaUbah,
  alasanTidakBisaKonfirmasi,
  alasanTidakBisaMenilai,
};
