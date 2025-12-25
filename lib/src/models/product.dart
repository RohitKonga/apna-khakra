class Product {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double actualPrice;
  final double marginPrice;
  final int stockQuantity;
  final List<String> images;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.actualPrice = 0,
    this.marginPrice = 0,
    this.stockQuantity = 0,
    required this.images,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      actualPrice: (json['actualPrice'] ?? 0).toDouble(),
      marginPrice: (json['marginPrice'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'actualPrice': actualPrice,
      'marginPrice': marginPrice,
      'stockQuantity': stockQuantity,
      'images': images,
    };
  }
}

