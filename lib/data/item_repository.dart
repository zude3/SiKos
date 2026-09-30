import '../models/item.dart';

/// Sumber data sementara untuk daftar kos.
class ItemRepository {
  ItemRepository({this.delay = const Duration(seconds: 2), List<Item>? items})
    : _items = items ?? _defaultItems;

  final Duration delay;
  final List<Item> _items;

  static const List<Item> _defaultItems = [
    Item(
      id: 'kos-nopal',
      title: 'Kos Nopal',
      subtitle: 'RB Teknik 02, Bawah Terowongan',
      description:
          'Kos putri yang nyaman dan dekat dengan area kampus, cocok untuk '
          'mahasiswi yang mengutamakan akses mudah ke fasilitas harian.',
      price: 'Rp 850.000',
      rating: '4.8',
      imageUrl: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80',
      isMale: false,
      isPopular: true,
    ),
    Item(
      id: 'griya-anggrek',
      title: 'Griya Anggrek Executive',
      subtitle: 'Seturan, Yogyakarta',
      description:
          'Hunian putri dengan kamar bergaya modern, lingkungan tenang, dan '
          'fasilitas yang mendukung kegiatan belajar.',
      price: 'Rp 1.200.000',
      rating: '4.9',
      imageUrl: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=600&q=80',
      isMale: false,
      isPopular: true,
    ),
    Item(
      id: 'kontrakan-ghozi',
      title: 'Kontrakan Ghozi',
      subtitle: '300m dari Los Chicken',
      description:
          'Kontrakan putra dengan ruang yang lega dan lokasi yang mudah '
          'dijangkau dari pusat kuliner sekitar kampus.',
      price: 'Rp 3.950.000',
      rating: '2.3',
      imageUrl: 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=300&q=80',
      isMale: true,
      isPopular: false,
      availability: 'SISA 2 KAMAR',
    ),
    Item(
      id: 'kost-wafa',
      title: 'Kost Wafa',
      subtitle: 'Belakang BC',
      description:
          'Kost putra dekat kampus dengan suasana sederhana dan akses cepat '
          'ke kebutuhan sehari-hari.',
      price: 'Rp 1.500.000',
      rating: '4.6',
      imageUrl: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=300&q=80',
      isMale: true,
      isPopular: false,
      availability: 'SISA 1 KAMAR',
    ),
  ];

  /// Mengambil daftar kos.
  ///
  /// Gunakan [simulateError] untuk menguji tampilan gagal memuat data.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future<void>.delayed(delay);
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return List<Item>.unmodifiable(_items);
  }
}
