-- ============================================================
-- DATA UJI SEMENTARA untuk mengetes Modul Komplain lewat Postman.
-- Menambah 1 penyewa uji dan 1 booking aktif (disetujui) di database BERSAMA.
-- Hapus bila autentikasi (F2) sudah jadi dan semua orang punya akun sungguhan:
--   DELETE FROM users WHERE email = 'uji@sikos.test';   (booking, komplain ikut terhapus)
-- Aman dijalankan berulang kali.
-- ============================================================

INSERT IGNORE INTO users (nama, email, no_hp, password_hash)
VALUES ('Penyewa Uji', 'uji@sikos.test', '081200009999', 'bukan-hash-asli-hanya-untuk-uji');

INSERT INTO booking (user_id, kamar_id, tgl_mulai, durasi_bulan, tgl_selesai, status)
SELECT u.id, 1, CURDATE(), 6, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 'disetujui'
FROM users u
WHERE u.email = 'uji@sikos.test'
  AND NOT EXISTS (
    SELECT 1 FROM booking b
    WHERE b.user_id = u.id AND b.kamar_id = 1 AND b.status = 'disetujui'
  );

-- Pakai nilai ini di Postman: header X-User-Id = user_id, field booking_id = booking_id
SELECT u.id AS user_id, b.id AS booking_id
FROM users u
JOIN booking b ON b.user_id = u.id AND b.kamar_id = 1 AND b.status = 'disetujui'
WHERE u.email = 'uji@sikos.test';
