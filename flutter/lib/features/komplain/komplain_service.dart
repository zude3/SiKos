import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'komplain_model.dart';

// Semua panggilan HTTP modul komplain. Flutter tidak pernah menyentuh MySQL langsung.
class KomplainService {
  final Dio _dio;
  KomplainService([Dio? dio]) : _dio = dio ?? apiClient;

  // D1: multipart, field file bernama "foto" (maks 3)
  Future<int> buat({
    required int bookingId,
    required String kategori,
    required String deskripsi,
    required List<String> pathFoto,
  }) async {
    final form = FormData();
    form.fields
      ..add(MapEntry('booking_id', bookingId.toString()))
      ..add(MapEntry('kategori', kategori))
      ..add(MapEntry('deskripsi', deskripsi));
    for (final p in pathFoto) {
      // Tanpa contentType: backend menentukan JPG/PNG dari ekstensi nama file.
      form.files.add(MapEntry('foto', await MultipartFile.fromFile(p, filename: p.split(RegExp(r'[\\/]')).last)));
    }
    final res = await _dio.post('/komplain', data: form);
    return res.data['id'] as int;
  }

  // D2
  Future<List<Komplain>> daftar({String? status}) async {
    final res = await _dio.get('/komplain',
        queryParameters: status == null ? null : {'status': status});
    return (res.data as List)
        .map((e) => Komplain.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // D3
  Future<Komplain> detail(int id) async {
    final res = await _dio.get('/komplain/$id');
    return Komplain.fromJson(res.data as Map<String, dynamic>);
  }

  // D4
  Future<void> ubah(int id, {required String kategori, required String deskripsi}) =>
      _dio.put('/komplain/$id', data: {'kategori': kategori, 'deskripsi': deskripsi});

  Future<void> hapus(int id) => _dio.delete('/komplain/$id');

  // D5
  Future<void> konfirmasi(int id) => _dio.put('/komplain/$id/konfirmasi');

  Future<void> beriPenilaian(int id, {required int rating, String? komentar}) =>
      _dio.post('/komplain/$id/penilaian', data: {
        'rating': rating,
        if (komentar != null && komentar.trim().isNotEmpty) 'komentar': komentar.trim(),
      });
}
