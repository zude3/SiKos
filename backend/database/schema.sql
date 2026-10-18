-- ============================================================
-- SiKos - Skema database bersama (MySQL 8.0, Aiven)
-- Jalankan di database yang dipilih tim (mis. defaultdb), sekali saja,
-- oleh pemegang paket F1. Urutan tabel mengikuti dependensi foreign key.
-- Semua tabel punya primary key (Aiven biasanya mewajibkannya).
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS ulasan_foto, ulasan, komplain_log, komplain_foto, komplain,
  bukti_pembayaran, tagihan, booking, riwayat_pencarian, favorit,
  kos_fasilitas, kos_foto, kamar, fasilitas, kos, users;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- FONDASI (F1/F2): akun penyewa
-- ------------------------------------------------------------
CREATE TABLE users (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama          VARCHAR(100) NOT NULL,
  email         VARCHAR(150) NOT NULL,
  no_hp         VARCHAR(20)  NULL,
  password_hash VARCHAR(255) NOT NULL,           -- hasil bcrypt, bukan password asli
  foto_profil   VARCHAR(255) NULL,               -- path file di server
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- DATA PEMILIK FIKTIF (F1): kos, kamar, fasilitas
-- Diisi lewat seed.sql, hanya dibaca oleh aplikasi penyewa.
-- Pemilik tidak punya akun: cukup nama_pemilik dan kontak_pemilik.
-- ------------------------------------------------------------
CREATE TABLE kos (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama           VARCHAR(120) NOT NULL,
  alamat         VARCHAR(255) NOT NULL,
  lat            DECIMAL(9,6) NOT NULL,
  lng            DECIMAL(9,6) NOT NULL,
  deskripsi      TEXT NULL,
  nama_pemilik   VARCHAR(100) NOT NULL,
  kontak_pemilik VARCHAR(20)  NOT NULL,
  aktif          TINYINT(1) NOT NULL DEFAULT 1,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_kos_nama (nama),
  KEY idx_kos_lokasi (lat, lng)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE kamar (
  id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kos_id    INT UNSIGNED NOT NULL,
  nomor     VARCHAR(10)  NOT NULL,
  harga     INT UNSIGNED NOT NULL,               -- rupiah per bulan
  tersedia  TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_kamar_nomor (kos_id, nomor),
  KEY idx_kamar_harga (harga),
  CONSTRAINT fk_kamar_kos FOREIGN KEY (kos_id) REFERENCES kos (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE kos_foto (
  id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kos_id  INT UNSIGNED NOT NULL,
  path    VARCHAR(255) NOT NULL,
  urutan  TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  KEY idx_kos_foto_kos (kos_id),
  CONSTRAINT fk_kos_foto_kos FOREIGN KEY (kos_id) REFERENCES kos (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fasilitas (
  id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama  VARCHAR(60) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_fasilitas_nama (nama)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE kos_fasilitas (
  kos_id        INT UNSIGNED NOT NULL,
  fasilitas_id  INT UNSIGNED NOT NULL,
  PRIMARY KEY (kos_id, fasilitas_id),
  CONSTRAINT fk_kf_kos       FOREIGN KEY (kos_id)       REFERENCES kos (id)       ON DELETE CASCADE,
  CONSTRAINT fk_kf_fasilitas FOREIGN KEY (fasilitas_id) REFERENCES fasilitas (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- MODUL 1: Pencarian & Detail Kos (data milik penyewa)
-- ------------------------------------------------------------
CREATE TABLE favorit (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     INT UNSIGNED NOT NULL,
  kos_id      INT UNSIGNED NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_favorit (user_id, kos_id),
  CONSTRAINT fk_favorit_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_favorit_kos  FOREIGN KEY (kos_id)  REFERENCES kos (id)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE riwayat_pencarian (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     INT UNSIGNED NOT NULL,
  kata_kunci  VARCHAR(120) NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_riwayat_user (user_id, created_at),
  CONSTRAINT fk_riwayat_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- MODUL 2: Booking Kamar
-- Status: menunggu -> disetujui / ditolak (simulasi pemilik),
--         dibatalkan (oleh penyewa), selesai (masa sewa berakhir)
-- ------------------------------------------------------------
CREATE TABLE booking (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id           INT UNSIGNED NOT NULL,
  kamar_id          INT UNSIGNED NOT NULL,
  tgl_mulai         DATE NOT NULL,
  durasi_bulan      TINYINT UNSIGNED NOT NULL DEFAULT 1,
  tgl_selesai       DATE NOT NULL,
  status            ENUM('menunggu','disetujui','ditolak','dibatalkan','selesai')
                    NOT NULL DEFAULT 'menunggu',
  alasan_penolakan  VARCHAR(255) NULL,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_booking_user (user_id, status),
  KEY idx_booking_kamar (kamar_id, status),
  CONSTRAINT fk_booking_user  FOREIGN KEY (user_id)  REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_booking_kamar FOREIGN KEY (kamar_id) REFERENCES kamar (id) ON DELETE RESTRICT,
  CONSTRAINT chk_booking_tanggal CHECK (tgl_selesai > tgl_mulai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- MODUL 3: Tagihan & Pembayaran
-- Status: belum_bayar -> menunggu_verifikasi -> lunas / ditolak (simulasi pemilik)
--         terlambat (lewat jatuh tempo)
-- ------------------------------------------------------------
CREATE TABLE tagihan (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  booking_id   INT UNSIGNED NOT NULL,
  periode      DATE NOT NULL,                    -- tanggal 1 bulan yang ditagih
  jumlah       INT UNSIGNED NOT NULL,
  jatuh_tempo  DATE NOT NULL,
  status       ENUM('belum_bayar','menunggu_verifikasi','lunas','ditolak','terlambat')
               NOT NULL DEFAULT 'belum_bayar',
  tgl_lunas    DATE NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_tagihan_periode (booking_id, periode),
  KEY idx_tagihan_status (status, jatuh_tempo),
  CONSTRAINT fk_tagihan_booking FOREIGN KEY (booking_id) REFERENCES booking (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bukti_pembayaran (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tagihan_id         INT UNSIGNED NOT NULL,
  path               VARCHAR(255) NOT NULL,
  catatan_penolakan  VARCHAR(255) NULL,
  created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_bukti_tagihan (tagihan_id),      -- satu bukti aktif per tagihan (ganti = update)
  CONSTRAINT fk_bukti_tagihan FOREIGN KEY (tagihan_id) REFERENCES tagihan (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- MODUL 4: Komplain & Maintenance
-- Status: diterima -> diproses -> selesai (simulasi pemilik)
-- Konfirmasi penyewa disimpan di kolom dikonfirmasi (bukan status baru).
-- Penilaian penanganan hanya boleh setelah dikonfirmasi (dicek di backend).
-- Maksimal 3 foto per komplain (dicek di backend).
-- ------------------------------------------------------------
CREATE TABLE komplain (
  id                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id              INT UNSIGNED NOT NULL,
  booking_id           INT UNSIGNED NOT NULL,
  kategori             ENUM('listrik','air','furnitur','kebersihan','lainnya') NOT NULL,
  deskripsi            TEXT NOT NULL,
  status               ENUM('diterima','diproses','selesai') NOT NULL DEFAULT 'diterima',
  dikonfirmasi         TINYINT(1) NOT NULL DEFAULT 0,
  tgl_konfirmasi       DATETIME NULL,
  rating_penanganan    TINYINT UNSIGNED NULL,
  komentar_penanganan  VARCHAR(500) NULL,
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_komplain_user (user_id, status),
  KEY idx_komplain_booking (booking_id),
  CONSTRAINT fk_komplain_user    FOREIGN KEY (user_id)    REFERENCES users (id)   ON DELETE CASCADE,
  CONSTRAINT fk_komplain_booking FOREIGN KEY (booking_id) REFERENCES booking (id) ON DELETE CASCADE,
  CONSTRAINT chk_komplain_rating CHECK (rating_penanganan IS NULL OR rating_penanganan BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE komplain_foto (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  komplain_id  INT UNSIGNED NOT NULL,
  path         VARCHAR(255) NOT NULL,
  urutan       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  KEY idx_komplain_foto (komplain_id),
  CONSTRAINT fk_komplain_foto FOREIGN KEY (komplain_id) REFERENCES komplain (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE komplain_log (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  komplain_id  INT UNSIGNED NOT NULL,
  status       ENUM('diterima','diproses','selesai','dikonfirmasi') NOT NULL,
  catatan      VARCHAR(255) NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_komplain_log (komplain_id, created_at),
  CONSTRAINT fk_komplain_log FOREIGN KEY (komplain_id) REFERENCES komplain (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- MODUL 5: Ulasan & Rating
-- Satu ulasan per booking. kos_id disimpan agar rata-rata rating per kos
-- mudah dihitung; konsistensinya dengan booking dijaga di backend.
-- ------------------------------------------------------------
CREATE TABLE ulasan (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     INT UNSIGNED NOT NULL,
  booking_id  INT UNSIGNED NOT NULL,
  kos_id      INT UNSIGNED NOT NULL,
  rating      TINYINT UNSIGNED NOT NULL,
  komentar    VARCHAR(1000) NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ulasan_booking (booking_id),
  KEY idx_ulasan_kos (kos_id, rating),
  KEY idx_ulasan_user (user_id),
  CONSTRAINT fk_ulasan_user    FOREIGN KEY (user_id)    REFERENCES users (id)   ON DELETE CASCADE,
  CONSTRAINT fk_ulasan_booking FOREIGN KEY (booking_id) REFERENCES booking (id) ON DELETE CASCADE,
  CONSTRAINT fk_ulasan_kos     FOREIGN KEY (kos_id)     REFERENCES kos (id)     ON DELETE CASCADE,
  CONSTRAINT chk_ulasan_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ulasan_foto (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ulasan_id  INT UNSIGNED NOT NULL,
  path       VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_ulasan_foto (ulasan_id),
  CONSTRAINT fk_ulasan_foto FOREIGN KEY (ulasan_id) REFERENCES ulasan (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
