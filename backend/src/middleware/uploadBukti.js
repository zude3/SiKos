const multer = require('multer');

module.exports = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024, files: 1, fields: 4, parts: 5 },
  fileFilter(req, file, callback) {
    if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)) {
      const error = new Error('Bukti harus berupa gambar JPG, PNG, atau WebP');
      error.status = 400;
      return callback(error);
    }
    callback(null, true);
  },
});
