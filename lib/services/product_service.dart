import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class ProductService {
  static const String _table = 'products';

  final SupabaseClient _client;

  ProductService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<Product>> fetchProducts({
    String? category,
    String search = '',
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

    final rows = await query.order('id', ascending: true);

    return rows.map(Product.fromMap).toList();
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
