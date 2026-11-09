class Product {
  final int id;
  final String name;
  final double price;
  final String imagePath;
  final String category;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      imagePath: (map['image_path'] as String?) ?? '',
      category: map['category'] as String,
      description: (map['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'description': description,
    };
  }

  Product copyWith({
    String? name,
    double? price,
    String? category,
    String? description,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      imagePath: imagePath,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}
