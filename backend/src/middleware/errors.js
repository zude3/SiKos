const multer = require('multer');

function errorHandler(error, req, res, next) {
  if (res.headersSent) {
    return next(error);
  }

  if (error instanceof multer.MulterError) {
    const status = error.code === 'LIMIT_FILE_SIZE' ? 413 : 400;
    return res.status(status).json({
      message:
        status === 413
          ? 'Ukuran bukti pembayaran maksimal 5 MB'
          : 'Unggahan bukti pembayaran tidak valid',
    });
  }

  if (error.status && error.status < 500) {
    return res.status(error.status).json({ message: error.message });
  }

  console.error(error);
  return res.status(500).json({ message: 'Terjadi kesalahan pada server' });
}

module.exports = { errorHandler };
