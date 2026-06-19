import 'package:flutter/foundation.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/i_product_repository.dart';

class CatalogProvider extends ChangeNotifier {
  final IProductRepository repository;

  final List<ProductModel> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _currentQuery = '';
  String _currentCategory = '';
  int _skip = 0;
  final int _limit = 20;

  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get currentCategory => _currentCategory;

  CatalogProvider({required this.repository}) {
    _loadCategories();
    loadMore();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await repository.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error categorías: $e');
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = _currentQuery.isNotEmpty
          ? await repository.searchProducts(
              query: _currentQuery,
              skip: _skip,
              limit: _limit,
            )
          : _currentCategory.isNotEmpty
          ? await repository.getProductsByCategory(
              category: _currentCategory,
              skip: _skip,
              limit: _limit,
            )
          : await repository.getProducts(skip: _skip, limit: _limit);

      if (response.products.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(response.products);
        _skip += _limit;
        _hasMore = _skip < response.total;
      }
    } catch (e) {
      debugPrint('Error loadMore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (_currentQuery == query) return;
    _currentQuery = query;
    _currentCategory = '';
    _resetAndFetch();
  }

  void setCategory(String category) {
    if (_currentCategory == category) return;
    _currentCategory = category;
    _currentQuery = '';
    _resetAndFetch();
  }

  void clearFilters() {
    _currentCategory = '';
    _currentQuery = '';
    _resetAndFetch();
  }

  void _resetAndFetch() {
    _skip = 0;
    _products.clear();
    _hasMore = true;
    loadMore();
  }
}
