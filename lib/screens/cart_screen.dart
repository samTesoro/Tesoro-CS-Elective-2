import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreen({
    super.key,
    required this.cartItems,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get totalPrice {
    return widget.cartItems.fold(
      0,
      (total, item) => total + (item.product.price * item.quantity),
    );
  }

  void increaseQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void decreaseQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        widget.cartItems.remove(item);
      }
    });
  }

  void removeItem(CartItem item) {
    setState(() {
      widget.cartItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: widget.cartItems.isEmpty
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
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
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
                                              decreaseQuantity(item),
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
                                              increaseQuantity(item),
                                          icon: const Icon(Icons.add),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () => removeItem(item),
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
                              '₱${totalPrice.toStringAsFixed(2)}',
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
                              context.push(
                                '/checkout',
                                extra: widget.cartItems,
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