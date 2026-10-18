const cron = require('node-cron');
const model = require('../models/komplainModel');
const { STATUS_BERIKUTNYA } = require('../services/komplainRules');

// Simulasi pemilik kos fiktif: memajukan status komplain secara bertahap
// diterima -> diproses -> selesai dan menulis linimasa (komplain_log).
// Semua akses database lewat models/komplainModel.js.
//
// Jeda dihitung dari perubahan status terakhir (waktu baris log terbaru), dalam detik.
// Bisa dipendekkan lewat .env saat demo:
//   KOMPLAIN_JEDA_DIPROSES_DETIK  (diterima -> diproses, bawaan 30)
//   KOMPLAIN_JEDA_SELESAI_DETIK   (diproses -> selesai, bawaan 60)
//   KOMPLAIN_SIMULASI=off         (matikan simulasi di laptop yang tidak perlu menjalankannya)
const JEDA_DETIK = {
  diterima: Number(process.env.KOMPLAIN_JEDA_DIPROSES_DETIK) || 30,
  diproses: Number(process.env.KOMPLAIN_JEDA_SELESAI_DETIK) || 60,
};

const CATATAN = {
  diproses: [
    'Teknisi sedang dijadwalkan untuk memeriksa kamar Anda',
    'Pemilik kos menerima laporan dan sedang menanganinya',
    'Petugas perbaikan menuju lokasi',
  ],
  selesai: [
    'Perbaikan telah selesai dilakukan',
    'Masalah sudah ditangani oleh pemilik kos',
    'Pekerjaan selesai, mohon periksa dan konfirmasi',
  ],
};

const pilihAcak = (daftar) => daftar[Math.floor(Math.random() * daftar.length)];

// Memajukan semua komplain berstatus statusSaatIni yang jedanya sudah terlewati.
// Mengembalikan jumlah komplain yang benar-benar dimajukan.
async function majukanStatus(statusSaatIni) {
  const statusBaru = STATUS_BERIKUTNYA[statusSaatIni];
  const kandidat = await model.kandidatMajukan(statusSaatIni, JEDA_DETIK[statusSaatIni]);

  let dimajukan = 0;
  for (const id of kandidat) {
    try {
      // Model memeriksa status di WHERE, sehingga aman bila beberapa laptop tim menjalankan
      // simulasi pada database bersama yang sama, atau bila komplain dihapus di saat yang sama.
      const berubah = await model.majukanStatus(
        id,
        statusSaatIni,
        statusBaru,
        pilihAcak(CATATAN[statusBaru])
      );
      if (berubah) dimajukan += 1;
    } catch (err) {
      console.error(`[simulator komplain] gagal memajukan komplain ${id}:`, err.message);
    }
  }
  return dimajukan;
}

let sedangBerjalan = false;

// Satu putaran simulasi. Dipisahkan dari jadwal agar mudah diuji dan dipanggil manual.
async function jalankanSekali() {
  if (sedangBerjalan) return; // hindari putaran bertumpuk bila database sedang lambat
  sedangBerjalan = true;
  try {
    await majukanStatus('diproses'); // lebih dulu, agar satu komplain tidak melompat dua tahap
    await majukanStatus('diterima');
  } catch (err) {
    console.error('[simulator komplain] error:', err.message);
  } finally {
    sedangBerjalan = false;
  }
}

function start() {
  if (process.env.KOMPLAIN_SIMULASI === 'off') {
    console.log('Simulasi pemilik untuk komplain dimatikan (KOMPLAIN_SIMULASI=off)');
    return null;
  }
  console.log(
    `Simulasi pemilik komplain aktif (diterima->diproses ${JEDA_DETIK.diterima} dtk, ` +
      `diproses->selesai ${JEDA_DETIK.diproses} dtk)`
  );
  return cron.schedule('*/5 * * * * *', jalankanSekali); // dicek tiap 10 detik
}

module.exports = { start, jalankanSekali, majukanStatus };
