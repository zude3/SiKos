import 'package:dio/dio.dart';
import 'config.dart';

// Satu instance Dio untuk seluruh aplikasi. Header X-User-Id hanya placeholder
// auth backend; nanti diganti header Authorization: Bearer <JWT>.
Dio buatApiClient() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'X-User-Id': AppConfig.userIdSementara.toString()},
  ));
  return dio;
}

final Dio apiClient = buatApiClient();

// Mengubah DioException menjadi pesan yang layak ditampilkan ke pengguna.
String pesanError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Tidak bisa terhubung ke server. Periksa koneksi dan alamat server.';
    }
    return 'Terjadi kesalahan (${e.response?.statusCode ?? 'tanpa respons'})';
  }
  return 'Terjadi kesalahan: $e';
}
