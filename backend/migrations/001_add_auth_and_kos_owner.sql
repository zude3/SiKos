ALTER TABLE users
  ADD COLUMN role ENUM('penyewa', 'pemilik') NOT NULL DEFAULT 'penyewa'
  AFTER password_hash;

ALTER TABLE kos
  ADD COLUMN pemilik_user_id INT UNSIGNED NULL
  AFTER kontak_pemilik,
  ADD INDEX idx_kos_pemilik_user (pemilik_user_id),
  ADD CONSTRAINT fk_kos_pemilik_user
    FOREIGN KEY (pemilik_user_id) REFERENCES users (id)
    ON DELETE SET NULL;
