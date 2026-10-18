// Konfigurasi sementara. Setelah fondasi (F1/F2) jadi, nilai ini diganti
// oleh login sungguhan (userId dari JWT) dan booking aktif dari modul booking.
class AppConfig {
  // Emulator Android: http://10.0.2.2:3000
  // HP asli: http://<IP-LAPTOP-DI-WIFI-YANG-SAMA>:3000 (cek dengan ipconfig)
  // static const String baseUrl = 'http://10.0.2.2:3000';
  static const String baseUrl = 'http://localhost:3000';

  // Hasil SELECT di akhir database/dev_fixture_komplain.sql
  static const int userIdSementara = 1;
  static const int bookingIdSementara = 1;

  static String fotoUrl(String pathRelatif) => '$baseUrl/uploads/$pathRelatif';
}
