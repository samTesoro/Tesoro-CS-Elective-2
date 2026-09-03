import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/product.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';

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
        routes: [
          GoRoute(
            path: 'product/:name',
            builder: (context, state) {
              final product = state.extra as Product;

              return ProductDetailScreen(
                product: product,
              );
            },
          ),
        ],
      ),
    ],
  );
}