require('dotenv').config();

const app = require('./app');

const port = Number(process.env.PORT) || 3000;

// 0.0.0.0 agar server bisa diakses dari HP/emulator di jaringan yang sama, bukan hanya localhost.
app.listen(port, '0.0.0.0', () => {
  console.log(`SiKos backend berjalan di port ${port}`);
});
