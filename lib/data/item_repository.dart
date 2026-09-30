import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
  static const List<Item> _popular = [
    Item(
      id: '1',
      title: 'Kos Nopal',
      subtitle: 'RB Teknik 02, Bawah Terowongan',
      description:
          'Kos khusus putri dengan suasana tenang dan dekat kampus. Kamar bersih, kamar mandi dalam, dan ada dapur bersama.',
      price: 'Rp 850.000',
      rating: '4.8',
      imageUrl:
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80',
    ),
    Item(
      id: '2',
      title: 'Griya Anggrek Executive',
      subtitle: 'Seturan, Yogyakarta',
      description:
          'Kos eksekutif dengan AC, WiFi kencang, dan parkir luas. Lingkungan aman dengan akses mudah ke pusat kota.',
      price: 'Rp 1.200.000',
      rating: '4.9',
      imageUrl:
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=600&q=80',
    ),
  ];

  static const List<Item> _nearby = [
    Item(
      id: '3',
      title: 'Kontrakan Ghozi',
      subtitle: '300m dari Los Chicken',
      description:
          'Kontrakan luas cocok untuk patungan bersama teman. Dekat tempat makan dan minimarket.',
      price: 'Rp 3.950.000',
      rating: '2.3',
      availability: 'SISA 2 KAMAR',
      imageUrl:
          'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=300&q=80',
    ),
    Item(
      id: '4',
      title: 'Kost Wafa',
      subtitle: 'Belakang BC',
      description:
          'Kos putra nyaman, berjarak jalan kaki dari kampus. Fasilitas lengkap: kasur, lemari, meja belajar, dan WiFi.',
      price: 'Rp 1.500.000',
      rating: '4.6',
      availability: 'SISA 1 KAMAR',
      imageUrl:
          'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=300&q=80',
    ),
  ];

  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<({List<Item> popular, List<Item> nearby})> fetchItems({
    bool simulateError = false,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return (popular: _popular, nearby: _nearby);
  }
}