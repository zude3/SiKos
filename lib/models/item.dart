/// Model data kos yang ditampilkan oleh aplikasi SiKos.
class Item {
  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.isMale,
    required this.isPopular,
    this.availability = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final String rating;
  final String imageUrl;
  final bool isMale;
  final bool isPopular;
  final String availability;
}
