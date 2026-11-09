import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final subtotal =
                          item.product.price * item.quantity;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.asset(
                                  item.product.imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style:
                                          theme.textTheme.titleMedium,
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      '₱${item.product.price.toStringAsFixed(2)} each',
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      'Subtotal: ₱${subtotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        IconButton.outlined(
                                          onPressed: () =>
                                              cart.decreaseQuantity(item),
                                          style: IconButton.styleFrom(
                                            minimumSize: const Size(
                                              48,
                                              48,
                                            ),
                                          ),
                                          icon:
                                              const Icon(Icons.remove),
                                        ),

                                        SizedBox(
                                          width: 35,
                                          child: Text(
                                            item.quantity.toString(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        IconButton.outlined(
                                          onPressed: () =>
                                              cart.increaseQuantity(item),
                                          style: IconButton.styleFrom(
                                            minimumSize: const Size(
                                              48,
                                              48,
                                            ),
                                          ),
                                          icon: const Icon(Icons.add),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () => cart.removeItem(item),
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              '₱${cart.totalPrice.toStringAsFixed(2)}',
                              style:
                                  theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final order = cart.checkout();
                              context.pushReplacement(
                                '/checkout',
                                extra: order,
                              );
                            },
                            child: const Text('Proceed to Checkout'),
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