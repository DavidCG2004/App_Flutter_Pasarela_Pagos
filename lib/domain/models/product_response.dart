import 'product_model.dart';

class ProductResponse {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  ProductResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    var list = json['products'] as List? ?? [];
    List<ProductModel> productList = list.map((i) => ProductModel.fromJson(i)).toList();
    
    return ProductResponse(
      products: productList,
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }
}
