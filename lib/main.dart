import 'package:flutter/material.dart';
import 'screens/pokedex_screen.dart';
import 'services/pokemon_service.dart';
import 'theme.dart';

void main() {
  runApp(MyApp(service: PokemonService()));
}

class MyApp extends StatefulWidget {
  final PokemonService service;

  const MyApp({super.key, required this.service});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: PokedexScreen(
        service: widget.service,
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
