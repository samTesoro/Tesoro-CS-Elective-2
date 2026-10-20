import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_notifier.dart';
import 'screens/pokedex_screen.dart';
import 'theme.dart';

void main() {
  // ProviderScope stores the state of every Riverpod provider in the app.
  // It replaces the MultiProvider we used with the Provider package.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Pokedex',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const PokedexScreen(),
    );
  }
}