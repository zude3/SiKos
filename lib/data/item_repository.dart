import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
  // Ganti isi data dummy ini sesuai aplikasi kelompok
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Kos Nopal',
      subtitle: 'bisa dijadikan basecamp',
      description: 'Deskripsi lengkap kos nopal.',
    ),
    Item(
      id: '2',
      title: 'Kos Ghozi',
      subtitle: 'kos jelek pinggiran kota',
      description: 'Deskripsi lengkap kos ghozi.',
    ),
    Item(
      id: '3',
      title: 'Kos Wafa',
      subtitle: 'Kos sudah mati listriknya',
      description: 'Deskripsi lengkap kos wafa.',
    ),
  ];

  /// Mengambil daftar item.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
