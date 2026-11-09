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

  static const double priceStep = 100;

  ProductProvider(this._service);

  ProductStatus _status = ProductStatus.loading;
  List<Product> _products = const [];
  String _errorMessage = '';
  String? _selectedCategory;
  String _search = '';

  bool _boundsLoaded = false;
  double _minPriceBound = 0;
  double _maxPriceBound = 0;
  double _minPrice = 0;
  double _maxPrice = 0;

  Timer? _searchDebounce;
  int _requestId = 0;

  ProductStatus get status => _status;
  List<Product> get products => _products;
  String get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get search => _search;
  double get minPriceBound => _minPriceBound;
  double get maxPriceBound => _maxPriceBound;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get hasPriceBounds => _boundsLoaded && _maxPriceBound > _minPriceBound;
  bool get isPriceFiltered =>
      _boundsLoaded &&
      (_minPrice > _minPriceBound || _maxPrice < _maxPriceBound);
  bool get hasActiveFilters =>
      _selectedCategory != null ||
      _search.trim().isNotEmpty ||
      isPriceFiltered;

  Future<void> fetchProducts() async {
    final requestId = ++_requestId;
    _status = ProductStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      if (!_boundsLoaded) await _loadPriceBounds();
      if (requestId != _requestId) return;

      final result = await _service.fetchProducts(
        category: _selectedCategory,
        search: _search,
        minPrice: isPriceFiltered ? _minPrice : null,
        maxPrice: isPriceFiltered ? _maxPrice : null,
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

  Future<void> _loadPriceBounds() async {
    final keepRange = isPriceFiltered;
    final bounds = await _service.fetchPriceBounds();

    _minPriceBound = (bounds.min / priceStep).floorToDouble() * priceStep;
    _maxPriceBound = (bounds.max / priceStep).ceilToDouble() * priceStep;
    if (_maxPriceBound <= _minPriceBound) {
      _maxPriceBound = _minPriceBound + priceStep;
    }

    if (keepRange) {
      _minPrice = _minPrice.clamp(_minPriceBound, _maxPriceBound);
      _maxPrice = _maxPrice.clamp(_minPrice, _maxPriceBound);
    } else {
      _minPrice = _minPriceBound;
      _maxPrice = _maxPriceBound;
    }

    _boundsLoaded = true;
  }

  void previewPriceRange(double start, double end) {
    _minPrice = start;
    _maxPrice = end;
    notifyListeners();
  }

  void applyPriceRange(double start, double end) {
    _minPrice = start;
    _maxPrice = end;
    fetchProducts();
  }

  void resetPriceRange() {
    _minPrice = _minPriceBound;
    _maxPrice = _maxPriceBound;
    fetchProducts();
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
    _minPrice = _minPriceBound;
    _maxPrice = _maxPriceBound;
    fetchProducts();
  }

  Future<Product> updateProduct(Product product) async {
    final updated = await _service.updateProduct(product);
    _boundsLoaded = false;
    await fetchProducts();
    return updated;
  }

  Future<void> deleteProduct(int id) async {
    await _service.deleteProduct(id);
    _boundsLoaded = false;
    await fetchProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
