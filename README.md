# SiKos

Repository ini berisi aplikasi Flutter dan paket backend Node.js.

## Struktur proyek

- `flutter/` — aplikasi Flutter beserta konfigurasi platform dan kode sumbernya.
- `backend/` — REST API Express, konfigurasi MySQL, dan migrasi database.

## Menjalankan aplikasi Flutter

Jalankan perintah berikut dari folder `flutter/`:

```sh
flutter pub get
flutter run
```

## Modul 3: Tagihan & Pembayaran

Buka menu **Tagihan** di navigasi bawah untuk melihat tagihan pribadi, detail,
riwayat, dan pengingat jatuh tempo serta mengirim atau memperbarui bukti
pembayaran. Aplikasi Flutter ini berfokus pada alur penyewa; tidak menyediakan
aksi pengelolaan tagihan atau verifikasi milik pemilik.

Layar Flutter saat ini masih memakai data demo di memori aplikasi dan belum
terhubung ke API. API backend untuk autentikasi dan tagihan tersedia di folder
`backend/`.

Backend menyediakan simulasi verifikasi pemilik yang default-nya mati. Untuk
mengaktifkannya, atur variabel `SIMULASI_AKTIF=true` pada `.env` lokal, isi
`SIMULASI_USER_IDS` dengan ID akun penyewa yang boleh diproses (pisahkan dengan
koma), lalu restart backend. Simulator hanya memproses tagihan akun tersebut
yang menunggu verifikasi setelah masa tunggu berlalu. Tagihan dengan ID
kelipatan `SIMULASI_TOLAK_SETIAP` ditolak dengan alasan simulasi; tagihan lainnya
dilunasi.

Variabel simulasi pada `.env`:

- `SIMULASI_AKTIF=false` — matikan simulasi; ubah menjadi `true` untuk
  mengaktifkan.
- `SIMULASI_USER_IDS=` — daftar ID penyewa yang diizinkan. Jika kosong, tidak
  ada tagihan yang diproses.
- `SIMULASI_INTERVAL_DETIK=10` — jeda pemeriksaan dalam detik.
- `SIMULASI_TUNGGU_DETIK=30` — umur minimum bukti sebelum verifikasi.
- `SIMULASI_TOLAK_SETIAP=3` — setiap tagihan dengan ID kelipatan angka ini
  ditolak; sisanya dilunasi.

## Menjalankan backend

Jalankan dari folder `backend/`:

```sh
npm ci
```

Salin `.env.example` menjadi `.env`, isi konfigurasi MySQL, lalu buat `JWT_SECRET`
acak minimal 32 byte. Migrasikan database satu kali dengan menjalankan
`migrations/001_add_auth_and_kos_owner.sql` pada database yang sama. Migrasi
memberi role `penyewa` pada akun yang sudah ada dan menambah relasi pemilik kos;
hubungkan akun pemilik ke kos secara eksplisit oleh administrator, misalnya:

```sql
UPDATE users SET role = 'pemilik' WHERE email = 'pemilik@example.com';
UPDATE kos
SET pemilik_user_id = (SELECT id FROM users WHERE email = 'pemilik@example.com')
WHERE id = 1;
```

Registrasi API hanya membuat akun penyewa. Jangan membuka pembuatan akun pemilik
publik. Login memverifikasi `password_hash` dengan bcrypt; akun lama yang
memakai algoritma hash lain perlu di-reset atau dimigrasikan sebelum bisa login.
Jalankan backend dengan:

```sh
npm start
```

Endpoint utama:

- `POST /auth/register` menerima `nama`, `email`, `password`, dan opsional
  `no_hp`; registrasi selalu membuat role penyewa.
- `POST /auth/login` menerima `email` dan `password`.
- `GET /tagihan` dan `GET /tagihan/:id`
- `POST /tagihan` menerima `booking_id`, `periode` (tanggal awal bulan), dan
  `jatuh_tempo`; jumlah tagihan diambil dari harga kamar di database. Endpoint
  operasional pemilik ini hanya untuk klien pemilik terpisah, bukan aplikasi
  Flutter penyewa.
- `POST /tagihan/:id/bukti` dengan multipart field `bukti` (JPG, PNG, atau WebP,
  maksimal 5 MB); penyewa dapat mengganti bukti selama tagihan belum lunas.
- `DELETE /tagihan/:id/bukti` menghapus bukti milik penyewa pada status
  `menunggu_verifikasi` atau `ditolak`; status tagihan dikembalikan ke
  `belum_bayar`.
- `GET /tagihan/:id/bukti` (hanya penyewa terkait dan pemilik kos)
- `PATCH /tagihan/:id/verifikasi` dengan `status: "lunas"` atau `"ditolak"`
  (alasan penolakan dikirim sebagai `catatan_penolakan` dan wajib diisi).

Semua endpoint `/tagihan` memerlukan header `Authorization` dengan token Bearer
yang dikembalikan oleh register atau login.

Bukti pembayaran disimpan di `backend/private_uploads/`, di luar direktori
statis publik, dan hanya dapat diambil melalui endpoint terautentikasi.
`JWT_SECRET` harus unik dan dirahasiakan.

Validasi widget:

```sh
cd flutter
flutter test
flutter analyze
```

Untuk panduan Flutter, lihat [dokumentasi resmi](https://docs.flutter.dev/).
