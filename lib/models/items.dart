class Items {
  final String name;
  final int price;
  final String image;
  final String description;
  final String authorEmail;

  Items({
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.authorEmail,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      name: json['name'],
      price: json['price'],
      image: json['image'],
      description: json['description'],
      authorEmail: json['authorEmail'],
    );
  }

  factory Items.fromMap(Map<String, dynamic> map) {
    return Items(
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      authorEmail: map['authorEmail'] ?? '',
    );
  }
}