class ProductModel {
  final String id;
  final String name; 
  final String description;
  final double price;
  final int stockQuantity; 
  final String categoryName; 
  final String imageUrl; 

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.categoryName,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['title'] ?? 'Sin nombre',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock'] as int? ?? 0,
      categoryName: json['category'] ?? '',
      imageUrl: json['thumbnail'] ?? '',
    );
  }
}
