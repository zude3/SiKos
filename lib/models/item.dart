class Item {
  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.availability,
    required this.isMale,
    required this.isPopular,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final String rating;
  final String imageUrl;
  final String availability;
  final bool isMale;
  final bool isPopular;
}
