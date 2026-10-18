const path = require('path');
const express = require('express');
const cors = require('cors');

const db = require('./config/db');
const asyncHandler = require('./utils/asyncHandler');
const kosRoutes = require('./routes/kos');
const authRoutes = require('./routes/auth');
const billingRoutes = require('./routes/tagihan');
const { errorHandler } = require('./middleware/errors');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/uploads', express.static(path.resolve(__dirname, '../uploads')));

app.use('/auth', authRoutes);
app.use('/tagihan', billingRoutes);

//cek db aiven
app.get(
  '/health',
  asyncHandler(async (req, res) => {
    await db.query('SELECT 1');
    res.json({ status: 'ok', database: 'terhubung' });
  })
);

app.use('/kos', kosRoutes);

app.use((req, res) => {
  res.status(404).json({ message: 'Endpoint tidak ditemukan' });
});

app.use(errorHandler);

module.exports = app;
