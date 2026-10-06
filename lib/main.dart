import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/music_provider.dart';
import 'providers/pokemon_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/pokedex_screen.dart';
import 'services/music_service.dart';
import 'services/pokemon_service.dart';
import 'theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PokemonProvider(PokemonService())..fetchPokemon(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider(MusicService())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

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
