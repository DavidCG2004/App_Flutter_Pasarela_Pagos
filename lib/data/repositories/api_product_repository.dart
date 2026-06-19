import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/product_response.dart';
import '../../domain/repositories/i_product_repository.dart';

class ApiProductRepository implements IProductRepository {
  final String _baseUrl = 'https://dummyjson.com/products';

  @override
  Future<ProductResponse> getProducts({int skip = 0, int limit = 30}) async {
    final response = await http.get(Uri.parse('$_baseUrl?limit=$limit&skip=$skip'));
    return _parseResponse(response);
  }

  @override
  Future<ProductResponse> searchProducts({required String query, int skip = 0, int limit = 30}) async {
    final response = await http.get(Uri.parse('$_baseUrl/search?q=$query&limit=$limit&skip=$skip'));
    return _parseResponse(response);
  }

  static const List<String> _validCategories = [
    'smartphones', 'laptops', 'mobile-accessories', 'beauty', 'fragrances',
    'skin-care', 'furniture', 'home-decoration', 'kitchen-accessories', 'groceries',
    'tops', 'mens-shirts', 'mens-shoes', 'womens-dresses', 'womens-shoes',
    'womens-watches', 'mens-watches', 'womens-bags', 'womens-jewellery', 'sunglasses',
    'automotive', 'motorcycle', 'sports-accessories'
  ];

  @override
  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final fetchedCategories = data.map((e) {
        if (e is String) return e;
        if (e is Map && e.containsKey('slug')) return e['slug'].toString();
        if (e is Map && e.containsKey('name')) return e['name'].toString();
        return e.toString();
      }).toList();
      
      // Filtrar solo las categorías validadas por el usuario
      return fetchedCategories.where((cat) => _validCategories.contains(cat)).toList();
    }
    throw Exception('Error al cargar categorías');
  }

  @override
  Future<ProductResponse> getProductsByCategory({required String category, int skip = 0, int limit = 30}) async {
    final response = await http.get(Uri.parse('$_baseUrl/category/$category?limit=$limit&skip=$skip'));
    return _parseResponse(response);
  }

  ProductResponse _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ProductResponse.fromJson(data);
    }
    throw Exception('Error en red: ${response.statusCode}');
  }
}
