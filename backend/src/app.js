const path = require('path');
const express = require('express');
const cors = require('cors');

const db = require('./config/db');
const asyncHandler = require('./utils/asyncHandler');
const kosRoutes = require('./routes/kos');

const app = express();

app.use(cors());
app.use(express.json());

// File yang diunggah (foto kos, bukti bayar, foto komplain) dilayani dari folder uploads/.
// Contoh: kolom path 'kos/kos-melati-1.jpg' diakses di http://HOST:PORT/uploads/kos/kos-melati-1.jpg
app.use('/uploads', express.static(path.resolve(__dirname, '../uploads')));

// Cek cepat bahwa server hidup dan database Aiven terhubung.
app.get(
  '/health',
  asyncHandler(async (req, res) => {
    await db.query('SELECT 1');
    res.json({ status: 'ok', database: 'terhubung' });
  })
);

// Setiap modul menambahkan route-nya di sini (satu file per modul di src/routes/).
app.use('/kos', kosRoutes);
// app.use('/auth', require('./routes/auth'));         // fondasi F2
// app.use('/booking', require('./routes/booking'));   // Modul 2
// app.use('/tagihan', require('./routes/tagihan'));   // Modul 3
app.use('/komplain', require('./routes/komplain')); // Modul 4
// app.use('/ulasan', require('./routes/ulasan'));     // Modul 5

app.use((req, res) => {
  res.status(404).json({ message: 'Endpoint tidak ditemukan' });
});

// Penangan error terpusat. Detail error hanya dicatat di server, tidak dikirim ke klien.
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: 'Terjadi kesalahan pada server' });
});

module.exports = app;
