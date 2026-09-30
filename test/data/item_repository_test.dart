import 'package:flutter_test/flutter_test.dart';
import 'package:tes1/data/item_repository.dart';

void main() {
  test('fetchItems returns the SiKos dummy listings', () async {
    final repository = ItemRepository(delay: Duration.zero);

    final items = await repository.fetchItems();

    expect(items, isNotEmpty);
    expect(items.first.id, isNotEmpty);
    expect(items.first.title, isNotEmpty);
    expect(items.any((item) => item.isPopular), isTrue);
  });

  test('fetchItems throws the expected message when error is simulated', () {
    final repository = ItemRepository(delay: Duration.zero);

    expect(
      () => repository.fetchItems(simulateError: true),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          'Exception: Gagal memuat data. Periksa koneksi internet.',
        ),
      ),
    );
  });
}
