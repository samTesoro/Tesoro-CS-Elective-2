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
        path: '/product/:id',
        builder: (context, state) {
          final product = state.extra as Product;

          return ProductDetailScreen(product: product);
        },
      ),

      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),

      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final order = state.extra as List<CartItem>? ?? const <CartItem>[];

          return CheckoutScreen(cartItems: order);
        },
      ),
    ],
  );
}