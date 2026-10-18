-- ============================================================
-- SiKos - Data contoh (pemilik kos fiktif)
-- Semua nama, alamat, koordinat, dan nomor kontak di bawah ini fiktif
-- (koordinat hanya perkiraan area sekitar kampus). Jalankan setelah schema.sql.
-- Path foto relatif terhadap folder uploads/ di backend; letakkan gambar
-- placeholder dengan nama yang sama di folder itu.
-- ============================================================

INSERT INTO fasilitas (id, nama) VALUES
  (1, 'WiFi'),
  (2, 'AC'),
  (3, 'Kamar mandi dalam'),
  (4, 'Kasur'),
  (5, 'Lemari'),
  (6, 'Meja belajar'),
  (7, 'Dapur bersama'),
  (8, 'Parkir motor'),
  (9, 'Laundry'),
  (10, 'Listrik termasuk');

INSERT INTO kos (id, nama, alamat, lat, lng, deskripsi, nama_pemilik, kontak_pemilik) VALUES
  (1, 'Kos Melati',  'Jl. Contoh No. 5, Limau Manis, Padang',  -0.916400, 100.461200,
      'Kos tenang dekat kampus, cocok untuk mahasiswa.',          'Bu Ratna',   '081200000001'),
  (2, 'Kos Anggrek', 'Jl. Contoh No. 12, Limau Manis, Padang', -0.919800, 100.458900,
      'Kamar luas dengan AC dan kamar mandi dalam.',              'Pak Hendra', '081200000002'),
  (3, 'Kos Kenanga', 'Jl. Contoh No. 21, Limau Manis, Padang', -0.912500, 100.465300,
      'Kos sederhana dengan harga terjangkau.',                   'Bu Maya',    '081200000003'),
  (4, 'Kos Dahlia',  'Jl. Contoh No. 8, Limau Manis, Padang',  -0.921300, 100.463800,
      'Kos bersih dengan dapur bersama dan area parkir.',         'Pak Rizal',  '081200000004');

INSERT INTO kos_foto (kos_id, path, urutan) VALUES
  (1, 'kos/kos-melati-1.jpg', 1),
  (1, 'kos/kos-melati-2.jpg', 2),
  (2, 'kos/kos-anggrek-1.jpg', 1),
  (3, 'kos/kos-kenanga-1.jpg', 1),
  (4, 'kos/kos-dahlia-1.jpg', 1);

INSERT INTO kamar (kos_id, nomor, harga, tersedia) VALUES
  (1, 'A1',  850000, 1),
  (1, 'A2',  850000, 0),
  (1, 'A3',  900000, 1),
  (2, '101', 1000000, 1),
  (2, '102', 1000000, 1),
  (2, '103', 1200000, 0),
  (3, 'K1',  650000, 1),
  (3, 'K2',  650000, 1),
  (3, 'K3',  700000, 0),
  (4, 'D1',  750000, 1),
  (4, 'D2',  750000, 1),
  (4, 'D3',  800000, 1),
  (4, 'D4',  800000, 0);

INSERT INTO kos_fasilitas (kos_id, fasilitas_id) VALUES
  (1, 1), (1, 4), (1, 5), (1, 6), (1, 8),
  (2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 10),
  (3, 1), (3, 4), (3, 5), (3, 8),
  (4, 1), (4, 4), (4, 5), (4, 7), (4, 8), (4, 9);
