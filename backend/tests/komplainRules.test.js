const test = require('node:test');
const assert = require('node:assert/strict');
const r = require('../src/services/komplainRules');

test('parseId hanya menerima bilangan bulat positif', () => {
  assert.equal(r.parseId('5'), 5);
  assert.equal(r.parseId(7), 7);
  for (const salah of ['abc', '', '0', '-1', '1.5', null, undefined]) {
    assert.equal(r.parseId(salah), null, `harus null untuk ${String(salah)}`);
  }
});

test('validasiBuat: data valid dirapikan', () => {
  const { value, error } = r.validasiBuat({
    booking_id: '3',
    kategori: ' listrik ',
    deskripsi: '  Lampu kamar mati total sejak kemarin  ',
  });
  assert.equal(error, undefined);
  assert.deepEqual(value, {
    booking_id: 3,
    kategori: 'listrik',
    deskripsi: 'Lampu kamar mati total sejak kemarin',
  });
});

test('validasiBuat: menolak data tidak valid', () => {
  const dasar = { booking_id: '3', kategori: 'air', deskripsi: 'Keran bocor di kamar mandi' };
  assert.ok(r.validasiBuat({ ...dasar, booking_id: 'x' }).error);
  assert.ok(r.validasiBuat({ ...dasar, booking_id: undefined }).error);
  assert.ok(r.validasiBuat({ ...dasar, kategori: 'sampah' }).error);
  assert.ok(r.validasiBuat({ ...dasar, deskripsi: 'pendek' }).error);
  assert.ok(r.validasiBuat({ ...dasar, deskripsi: 'a'.repeat(1001) }).error);
  assert.ok(r.validasiBuat().error);
});

test('validasiUbah: minimal satu kolom, dan tiap kolom divalidasi', () => {
  assert.ok(r.validasiUbah({}).error);
  assert.deepEqual(r.validasiUbah({ kategori: 'air' }).value, { kategori: 'air' });
  assert.ok(r.validasiUbah({ kategori: 'salah' }).error);
  assert.ok(r.validasiUbah({ deskripsi: 'pendek' }).error);
  assert.deepEqual(
    r.validasiUbah({ deskripsi: 'Keran bocor semakin parah' }).value,
    { deskripsi: 'Keran bocor semakin parah' }
  );
});

test('validasiPenilaian: rating 1-5 bulat, komentar opsional', () => {
  assert.deepEqual(r.validasiPenilaian({ rating: 5 }).value, { rating: 5, komentar: null });
  assert.deepEqual(r.validasiPenilaian({ rating: '4', komentar: ' cepat ' }).value, {
    rating: 4,
    komentar: 'cepat',
  });
  for (const salah of [0, 6, 2.5, 'abc', '', null, undefined]) {
    assert.ok(r.validasiPenilaian({ rating: salah }).error, `harus ditolak: ${String(salah)}`);
  }
  assert.ok(r.validasiPenilaian({ rating: 3, komentar: 'a'.repeat(501) }).error);
});

test('ubah/hapus hanya saat status diterima', () => {
  assert.equal(r.alasanTidakBisaUbah({ status: 'diterima' }), null);
  assert.ok(r.alasanTidakBisaUbah({ status: 'diproses' }));
  assert.ok(r.alasanTidakBisaUbah({ status: 'selesai' }));
});

test('konfirmasi hanya saat selesai dan belum dikonfirmasi', () => {
  assert.equal(r.alasanTidakBisaKonfirmasi({ status: 'selesai', dikonfirmasi: 0 }), null);
  assert.ok(r.alasanTidakBisaKonfirmasi({ status: 'diproses', dikonfirmasi: 0 }));
  assert.ok(r.alasanTidakBisaKonfirmasi({ status: 'selesai', dikonfirmasi: 1 }));
});

test('penilaian hanya setelah dikonfirmasi dan sekali saja', () => {
  assert.equal(r.alasanTidakBisaMenilai({ dikonfirmasi: 1, rating_penanganan: null }), null);
  assert.ok(r.alasanTidakBisaMenilai({ dikonfirmasi: 0, rating_penanganan: null }));
  assert.ok(r.alasanTidakBisaMenilai({ dikonfirmasi: 1, rating_penanganan: 4 }));
});

test('urutan status simulasi pemilik', () => {
  assert.equal(r.STATUS_BERIKUTNYA.diterima, 'diproses');
  assert.equal(r.STATUS_BERIKUTNYA.diproses, 'selesai');
  assert.equal(r.STATUS_BERIKUTNYA.selesai, undefined);
});
