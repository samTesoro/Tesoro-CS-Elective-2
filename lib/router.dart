import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/product.dart';
import 'models/cart_item.dart';

import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';

GoRouter createRouter(
  ThemeMode themeMode,
  VoidCallback onToggleTheme,
) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return HomeScreen(
            themeMode: themeMode,
            onToggleTheme: onToggleTheme,
          );
        },
      ),

      GoRoute(
        path: '/product/:name',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final product = extra['product'] as Product;
          final onAddToCart =
              extra['onAddToCart'] as Function(Product, int);

          return ProductDetailScreen(
            product: product,
            onAddToCart: onAddToCart,
          );
        },
      ),

      GoRoute(
        path: '/cart',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return CartScreen(
            cartItems: extra['cartItems'] as List<CartItem>,
            onClearCart: extra['onClearCart'] as VoidCallback,
          );
        },
      ),

      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return CheckoutScreen(
            cartItems: extra['cartItems'] as List<CartItem>,
            onCheckoutComplete:
                extra['onCheckoutComplete'] as VoidCallback,
          );
        },
      ),
    ],
  );
}