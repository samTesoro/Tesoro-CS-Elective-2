import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
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
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              color: theme.colorScheme.surfaceContainerHighest,
              child: product.imagePath.isNotEmpty
                  ? Image.asset(
                      product.imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        _getProductIcon(),
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),

                  const SizedBox(height: 4),

                  Text(
                    '₱${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}