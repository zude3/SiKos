const jwt = require('jsonwebtoken');
const db = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

function getJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret || Buffer.byteLength(secret) < 32) {
    throw new Error('JWT_SECRET wajib diisi dengan minimal 32 byte.');
  }
  return secret;
}

const authenticate = asyncHandler(async (req, res, next) => {
  const authorization = req.get('authorization');
  const match = authorization && authorization.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    return res.status(401).json({ message: 'Token autentikasi diperlukan' });
  }

  let payload;
  try {
    payload = jwt.verify(match[1], getJwtSecret(), {
      algorithms: ['HS256'],
      issuer: 'sikos-api',
      audience: 'sikos-app',
    });
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError || error instanceof jwt.TokenExpiredError) {
      return res.status(401).json({ message: 'Token tidak valid atau kedaluwarsa' });
    }
    throw error;
  }

  const userId = Number(payload.sub);
  if (!Number.isInteger(userId) || userId <= 0) {
    return res.status(401).json({ message: 'Token tidak valid atau kedaluwarsa' });
  }

  const [users] = await db.query(
    'SELECT id, role FROM users WHERE id = ?',
    [userId]
  );
  if (users.length === 0) {
    return res.status(401).json({ message: 'Akun tidak ditemukan' });
  }

  req.user = { id: users[0].id, role: users[0].role };
  next();
});

function allowRoles(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Anda tidak memiliki akses' });
    }
    next();
  };
}

module.exports = { authenticate, allowRoles, getJwtSecret };
