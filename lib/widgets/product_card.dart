import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onSeeMore;

  const ProductCard({
    super.key,
    required this.product,
    required this.onSeeMore,
  });

  IconData _getProductIcon() {
    switch (product.category) {
      case 'Printers':
        return Icons.print_outlined;
      case 'Flyers':
        return Icons.description_outlined;
      case 'Brochures':
        return Icons.menu_book_outlined;
      case 'Tarpaulins':
        return Icons.image_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                _getProductIcon(),
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '₱${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSeeMore,
                      child: const Text('See More'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}