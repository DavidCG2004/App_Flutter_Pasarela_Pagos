import '../models/product_response.dart';

abstract class IProductRepository {
  Future<ProductResponse> getProducts({int skip = 0, int limit = 30});
  Future<ProductResponse> searchProducts({required String query, int skip = 0, int limit = 30});
  Future<List<String>> getCategories();
  Future<ProductResponse> getProductsByCategory({required String category, int skip = 0, int limit = 30});
}
