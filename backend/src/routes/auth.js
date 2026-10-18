const bcrypt = require('bcryptjs');
const express = require('express');
const jwt = require('jsonwebtoken');

const db = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { getJwtSecret } = require('../middleware/auth');

const router = express.Router();

function issueToken(user) {
  return jwt.sign(
    { role: user.role },
    getJwtSecret(),
    {
      subject: String(user.id),
      expiresIn: '12h',
      issuer: 'sikos-api',
      audience: 'sikos-app',
    }
  );
}

router.post(
  '/register',
  asyncHandler(async (req, res) => {
    const body = req.body || {};
    const nama = typeof body.nama === 'string' ? body.nama.trim() : '';
    const email = typeof body.email === 'string'
      ? body.email.trim().toLowerCase()
      : '';
    if (body.no_hp != null && typeof body.no_hp !== 'string') {
      return res.status(400).json({ message: 'Nomor HP tidak valid' });
    }
    const noHp = typeof body.no_hp === 'string' ? body.no_hp.trim() : null;
    const password = body.password;

    if (!nama || nama.length > 100) {
      return res.status(400).json({ message: 'Nama wajib diisi (maksimal 100 karakter)' });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 150) {
      return res.status(400).json({ message: 'Alamat email tidak valid' });
    }
    if (noHp && noHp.length > 20) {
      return res.status(400).json({ message: 'Nomor HP maksimal 20 karakter' });
    }
    if (typeof password !== 'string' || password.length < 8 || Buffer.byteLength(password) > 72) {
      return res.status(400).json({ message: 'Kata sandi harus 8-72 byte' });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    try {
      const [result] = await db.query(
        'INSERT INTO users (nama, email, no_hp, password_hash) VALUES (?, ?, ?, ?)',
        [nama, email, noHp || null, passwordHash]
      );
      const user = { id: result.insertId, nama, email, role: 'penyewa' };
      res.status(201).json({ user, token: issueToken(user) });
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'Email sudah terdaftar' });
      }
      throw error;
    }
  })
);

router.post(
  '/login',
  asyncHandler(async (req, res) => {
    const body = req.body || {};
    const email = typeof body.email === 'string'
      ? body.email.trim().toLowerCase()
      : '';
    const password = body.password;
    if (!email || typeof password !== 'string') {
      return res.status(400).json({ message: 'Email dan kata sandi wajib diisi' });
    }

    const [users] = await db.query(
      'SELECT id, nama, email, role, password_hash FROM users WHERE email = ?',
      [email]
    );
    const passwordHash = users[0] && users[0].password_hash;
    const isBcryptHash =
      typeof passwordHash === 'string' &&
      /^\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}$/.test(passwordHash);
    if (
      users.length === 0 ||
      !isBcryptHash ||
      !(await bcrypt.compare(password, passwordHash))
    ) {
      return res.status(401).json({ message: 'Email atau kata sandi salah' });
    }

    const { id, nama, role } = users[0];
    res.json({
      user: { id, nama, email: users[0].email, role },
      token: issueToken({ id, role }),
    });
  })
);

module.exports = router;
