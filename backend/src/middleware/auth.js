// ============================================================================
// PLACEHOLDER SEMENTARA UNTUK PENGEMBANGAN - BUKAN AUTENTIKASI SUNGGUHAN.
// Paket F2 (autentikasi) akan MENGGANTI isi file ini dengan verifikasi JWT.
// Kontraknya: setelah lolos, middleware mengisi req.user = { id: <id user> }.
// Route modul hanya memakai req.user.id, jadi tidak perlu diubah saat diganti.
//
// Selama masih placeholder: kirim header  X-User-Id: <id user>  (mis. dari Postman).
// Placeholder otomatis menolak semua permintaan bila NODE_ENV=production.
// ============================================================================

module.exports = (req, res, next) => {
  if (process.env.NODE_ENV === 'production') {
    return res.status(500).json({ message: 'Autentikasi belum dipasang (placeholder)' });
  }

  const id = Number(req.header('x-user-id'));
  if (!Number.isInteger(id) || id <= 0) {
    return res
      .status(401)
      .json({ message: 'Belum login (placeholder: kirim header X-User-Id)' });
  }

  req.user = { id };
  return next();
};
