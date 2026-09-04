import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(Product, int) onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 600;

          if (isLargeScreen) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        product.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 32),

                  Expanded(
                    flex: 5,
                    child: _ProductInformation(
                      product: product,
                      quantity: quantity,
                      theme: theme,
                      onDecrease: decreaseQuantity,
                      onIncrease: increaseQuantity,
                      onAddToCart: () {
                        widget.onAddToCart(product, quantity);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} added to cart',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: Image.asset(
                            product.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _ProductInformation(
                        product: product,
                        quantity: quantity,
                        theme: theme,
                        onDecrease: decreaseQuantity,
                        onIncrease: increaseQuantity,
                        onAddToCart: () {
                          widget.onAddToCart(product, quantity);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} added to cart',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  final Product product;
  final int quantity;
  final ThemeData theme;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAddToCart;

  const _ProductInformation({
    required this.product,
    required this.quantity,
    required this.theme,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          product.name,
          style: theme.textTheme.headlineMedium,
        ),

        const SizedBox(height: 8),

        Text(
          '₱${product.price.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Description',
          style: theme.textTheme.titleLarge,
        ),

        const SizedBox(height: 8),

        Text(
          product.description,
          style: theme.textTheme.bodyMedium,
        ),

        const SizedBox(height: 24),

        Text(
          'Quantity',
          style: theme.textTheme.titleLarge,
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            IconButton.outlined(
              onPressed: onDecrease,
              icon: const Icon(Icons.remove),
            ),

            SizedBox(
              width: 50,
              child: Text(
                quantity.toString(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ),

            IconButton.outlined(
              onPressed: onIncrease,
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Add to Cart'),
          ),
        ),
      ],
    );
  }
}