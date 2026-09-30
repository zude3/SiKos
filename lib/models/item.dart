class Item {
  final String id;
  final String title; 
  final String subtitle; 
  final String description;
  final String price;
  final String rating;
  final String imageUrl;
  final String availability;

  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.availability = '',
  });
}