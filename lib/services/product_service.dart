import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class ProductService {
  static const String _table = 'products';

  final SupabaseClient _client;

  ProductService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<({List<Product> products, int totalCount})> fetchProducts({
    String? category,
    String search = '',
    double? minPrice,
    double? maxPrice,
    required int page,
    required int pageSize,
  }) async {
    var query = _client.from(_table).select();

    if (category != null) {
      query = query.eq('category', category);
    }

    final cleanSearch = _sanitize(search);
    if (cleanSearch.isNotEmpty) {
      query = query.or(
        'name.ilike.%$cleanSearch%,category.ilike.%$cleanSearch%',
      );
    }

    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }

    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await query
        .order('id', ascending: true)
        .range(from, to)
        .count(CountOption.exact);

    return (
      products: response.data.map(Product.fromMap).toList(),
      totalCount: response.count,
    );
  }

  Future<({double min, double max})> fetchPriceBounds() async {
    final lowest = await _client
        .from(_table)
        .select('price')
        .order('price', ascending: true)
        .limit(1);

    final highest = await _client
        .from(_table)
        .select('price')
        .order('price', ascending: false)
        .limit(1);

    if (lowest.isEmpty || highest.isEmpty) {
      return (min: 0.0, max: 0.0);
    }

    return (
      min: (lowest.first['price'] as num).toDouble(),
      max: (highest.first['price'] as num).toDouble(),
    );
  }

  Future<Product> updateProduct(Product product) async {
    final row = await _client
        .from(_table)
        .update(product.toUpdateMap())
        .eq('id', product.id)
        .select()
        .single();

    return Product.fromMap(row);
  }

  Future<void> deleteProduct(int id) async {
    final deleted =
        await _client.from(_table).delete().eq('id', id).select();

    if (deleted.isEmpty) {
      throw Exception('Product was not deleted (not found or not allowed).');
    }
  }

  String _sanitize(String input) {
    return input.trim().replaceAll(RegExp(r'[,()%*\\]'), ' ').trim();
  }
}
