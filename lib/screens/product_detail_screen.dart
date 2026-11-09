import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  late Product _product = widget.product;
  bool _isBusy = false;

  Future<void> _editProduct() async {
    final edited = await ProductFormDialog.show(context, _product);
    if (edited == null || !mounted) return;

    setState(() => _isBusy = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final saved = await context.read<ProductProvider>().updateProduct(edited);
      if (!mounted) return;
      context.read<CartProvider>().syncProduct(saved);
      setState(() => _product = saved);
      messenger.showSnackBar(
        SnackBar(content: Text('${saved.name} updated')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          '"${_product.name}" will be permanently removed from the shop.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await context.read<ProductProvider>().deleteProduct(_product.id);
      if (!mounted) return;
      context.read<CartProvider>().removeProduct(_product.id);
      messenger.showSnackBar(
        SnackBar(content: Text('${_product.name} deleted')),
      );
      context.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _addToCart() {
    final router = GoRouter.of(context);
    context.read<CartProvider>().add(_product, quantity);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$quantity × ${_product.name} added to cart'),
          action: SnackBarAction(
            label: 'View cart',
            onPressed: () => router.push('/cart'),
          ),
        ),
      );
    context.pop();
  }

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
    final product = _product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            tooltip: 'Edit product',
            onPressed: _isBusy ? null : _editProduct,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete product',
            onPressed: _isBusy ? null : _deleteProduct,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 8),
        ],
        bottom: _isBusy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),

      body: SafeArea(
        child: LayoutBuilder(
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
                      onAddToCart: _addToCart,
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
                        onAddToCart: _addToCart,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
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
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
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