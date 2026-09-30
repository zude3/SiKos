import '../models/item.dart';

class ItemRepository {
  ItemRepository({List<Item>? items}) : _items = items ?? _defaultItems;

  final List<Item> _items;

  static const List<Item> _defaultItems = [
    Item(
      id: 'kos-nopal',
      title: 'Kos Nopal',
      subtitle: 'RB Teknik 02, Bawah Terowongan',
      description:
          'Kos putri nyaman dekat area kampus dengan fasilitas lengkap.',
      price: 'Rp 850.000',
      rating: '4.8',
      imageUrl: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80',
      availability: 'SISA 3 KAMAR',
      isMale: false,
      isPopular: true,
    ),
    Item(
      id: 'griya-anggrek',
      title: 'Griya Anggrek Executive',
      subtitle: 'Seturan, Yogyakarta',
      description: 'Hunian eksekutif dengan suasana tenang dan akses mudah.',
      price: 'Rp 1.200.000',
      rating: '4.9',
      imageUrl: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=600&q=80',
      availability: 'SISA 2 KAMAR',
      isMale: false,
      isPopular: true,
    ),
    Item(
      id: 'kontrakan-ghozi',
      title: 'Kontrakan Ghozi',
      subtitle: '300m dari Los Chicken',
      description:
          'Kontrakan luas untuk mahasiswa, dekat tempat makan dan kampus.',
      price: 'Rp 3.950.000',
      rating: '2.3',
      imageUrl: 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=300&q=80',
      availability: 'SISA 2 KAMAR',
      isMale: true,
      isPopular: false,
    ),
    Item(
      id: 'kost-wafa',
      title: 'Kost Wafa',
      subtitle: 'Belakang BC',
      description: 'Kost putra praktis dengan lokasi strategis di belakang BC.',
      price: 'Rp 1.500.000',
      rating: '4.6',
      imageUrl: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=300&q=80',
      availability: 'SISA 1 KAMAR',
      isMale: true,
      isPopular: false,
    ),
  ];

  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
