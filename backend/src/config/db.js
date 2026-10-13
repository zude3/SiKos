const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

// Seluruh akses ke MySQL melalui pool ini. Flutter tidak pernah terhubung langsung ke database.
const required = ['DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];
const missing = required.filter((k) => !process.env[k]);
if (missing.length > 0) {
  throw new Error(
    `Variabel .env belum diisi: ${missing.join(', ')}. Salin .env.example menjadi .env lalu isi nilainya.`
  );
}

// Aiven mewajibkan SSL. Jika DB_CA_PATH kosong, koneksi tanpa SSL (hanya untuk MySQL lokal).
let ssl;
if (process.env.DB_CA_PATH) {
  const caPath = path.resolve(__dirname, '../..', process.env.DB_CA_PATH);
  if (!fs.existsSync(caPath)) {
    throw new Error(`File sertifikat tidak ditemukan: ${caPath}. Taruh ca.pem di folder certs/.`);
  }
  ssl = { ca: fs.readFileSync(caPath) };
}

const db = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl,
  waitForConnections: true,
  connectionLimit: 5, // kecil, karena paket gratis dibagikan ke seluruh tim
  charset: 'utf8mb4',
  decimalNumbers: true, // lat/lng DECIMAL dikembalikan sebagai angka, bukan string
});

module.exports = db;
