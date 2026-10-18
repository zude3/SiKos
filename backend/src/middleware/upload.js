const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const multer = require('multer');

// Helper unggah foto (kamera/galeri dari Flutter). Aslinya bagian paket F5 (layanan bersama);
// bila F5 sudah membuat versi sendiri, cukup sesuaikan import di route modul.
const UPLOAD_ROOT = path.resolve(__dirname, '../../uploads');
const EKSTENSI = { 'image/jpeg': '.jpg', 'image/png': '.png' };
const MAKS_BYTE = 5 * 1024 * 1024; // 5 MB per foto (NFR-07)

class UploadError extends Error {}

// Membuat middleware multer untuk field "foto" (maksimal maksFile foto) di uploads/<subfolder>/.
function buatUploadFoto(subfolder, maksFile) {
  const folder = path.join(UPLOAD_ROOT, subfolder);
  fs.mkdirSync(folder, { recursive: true });

  const upload = multer({
    storage: multer.diskStorage({
      destination: (req, file, cb) => cb(null, folder),
      filename: (req, file, cb) => {
        const acak = crypto.randomBytes(6).toString('hex');
        cb(null, `${Date.now()}-${acak}${EKSTENSI[file.mimetype]}`);
      },
    }),
    limits: { fileSize: MAKS_BYTE, files: maksFile },
    fileFilter: (req, file, cb) => {
      // Sebagian klien (mis. dio di Flutter) mengirim application/octet-stream;
      // dalam kasus itu tipe diambil dari ekstensi nama file.
      if (file.mimetype === 'application/octet-stream') {
        const ext = path.extname(file.originalname || '').toLowerCase();
        if (ext === '.jpg' || ext === '.jpeg') file.mimetype = 'image/jpeg';
        else if (ext === '.png') file.mimetype = 'image/png';
      }
      if (EKSTENSI[file.mimetype]) return cb(null, true);
      return cb(new UploadError('Format foto harus JPG atau PNG'));
    },
  });

  return upload.array('foto', maksFile);
}

// Membungkus middleware multer agar kesalahan unggah menjadi respons 400 yang jelas.
function tanganiUpload(middleware, maksFile) {
  return (req, res, next) => {
    middleware(req, res, (err) => {
      if (!err) return next();
      if (err instanceof UploadError) return res.status(400).json({ message: err.message });
      if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({ message: 'Ukuran foto maksimal 5 MB' });
        }
        if (err.code === 'LIMIT_UNEXPECTED_FILE' || err.code === 'LIMIT_FILE_COUNT') {
          return res
            .status(400)
            .json({ message: `Maksimal ${maksFile} foto, dengan nama field "foto"` });
        }
        return res.status(400).json({ message: 'Unggahan tidak valid' });
      }
      return next(err);
    });
  };
}

// Menghapus file yang baru saja diunggah (objek file dari multer), mis. saat validasi gagal.
function hapusFileUnggahan(files = []) {
  return Promise.all(files.map((f) => fs.promises.unlink(f.path).catch(() => {})));
}

// Menghapus file berdasarkan path relatif di database (mis. 'komplain/123-abc.jpg').
function hapusFileTersimpan(pathRelatif = []) {
  return Promise.all(
    pathRelatif.map((p) => {
      const mutlak = path.resolve(UPLOAD_ROOT, p);
      // Pengaman: hanya boleh menghapus di dalam folder uploads/.
      if (!mutlak.startsWith(UPLOAD_ROOT + path.sep)) return null;
      return fs.promises.unlink(mutlak).catch(() => {});
    })
  );
}

module.exports = { buatUploadFoto, tanganiUpload, hapusFileUnggahan, hapusFileTersimpan };
