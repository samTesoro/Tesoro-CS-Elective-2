import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

enum ProductStatus { loading, success, error }

class ProductProvider extends ChangeNotifier {
  static const List<String> categories = [
    'Printers',
    'Flyers',
    'Brochures',
    'Tarpaulins',
  ];

  final ProductService _service;

  ProductProvider(this._service);

  ProductStatus _status = ProductStatus.loading;
  List<Product> _products = const [];
  String _errorMessage = '';
  String? _selectedCategory;
  String _search = '';

  Timer? _searchDebounce;
  int _requestId = 0;

  ProductStatus get status => _status;
  List<Product> get products => _products;
  String get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get search => _search;
  bool get hasActiveFilters =>
      _selectedCategory != null || _search.trim().isNotEmpty;

  Future<void> fetchProducts() async {
    final requestId = ++_requestId;
    _status = ProductStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _service.fetchProducts(
        category: _selectedCategory,
        search: _search,
      );
      if (requestId != _requestId) return;
      _products = result;
      _status = ProductStatus.success;
    } catch (e) {
      if (requestId != _requestId) return;
      _errorMessage = '$e';
      _status = ProductStatus.error;
    }
    notifyListeners();
  }

  void setCategory(String? category) {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    fetchProducts();
  }

  void setSearch(String value) {
    _search = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      fetchProducts,
    );
    notifyListeners();
  }

  void clearFilters() {
    _searchDebounce?.cancel();
    _selectedCategory = null;
    _search = '';
    fetchProducts();
  }

  Future<Product> updateProduct(Product product) async {
    final updated = await _service.updateProduct(product);
    await fetchProducts();
    return updated;
  }

  Future<void> deleteProduct(int id) async {
    await _service.deleteProduct(id);
    await fetchProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
