import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_item.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final VoidCallback onCheckoutComplete;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.onCheckoutComplete,
  });

  double get totalPrice {
    return cartItems.fold(
      0,
      (total, item) => total + (item.product.price * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: theme.colorScheme.primary,
            ),

            const SizedBox(height: 16),

            Text(
              'Order Confirmed!',
              style: theme.textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            const Text(
              'Thank you for your order.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Order Summary',
                style: theme.textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final subtotal =
                      item.product.price * item.quantity;

                  return Card(
                    child: ListTile(
                      leading: Image.asset(
                        item.product.imagePath,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      title: Text(item.product.name),
                      subtitle: Text(
                        '${item.quantity} × ₱${item.product.price.toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        '₱${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    '₱${totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Clear the cart
                  onCheckoutComplete();

                  // Return to home screen
                  context.go('/');
                },
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}