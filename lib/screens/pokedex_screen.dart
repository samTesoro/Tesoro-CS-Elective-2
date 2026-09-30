import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_view.dart';

class PokedexScreen extends StatefulWidget {
  final PokemonService service;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const PokedexScreen({
    super.key,
    required this.service,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  // Created ONCE in initState, not inside build(), so rebuilds (like the
  // theme toggle) don't fire a new network request each time.
  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = widget.service.fetchPokemon(limit: 30);
  }

  void _retry() {
    setState(() {
      _pokemonFuture = widget.service.fetchPokemon(limit: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return StatusView(
              icon: Icons.wifi_off_rounded,
              title: 'Something went wrong',
              message: '${snapshot.error}',
              onRetry: _retry,
            );
          }

          // Empty state
          final pokemon = snapshot.data ?? const <Pokemon>[];
          if (pokemon.isEmpty) {
            return StatusView(
              icon: Icons.catching_pokemon,
              title: 'No Pokémon found',
              message: 'The PokéAPI returned an empty list.',
              onRetry: _retry,
            );
          }

          // Data state
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: pokemon.length,
            itemBuilder: (context, index) =>
                PokemonCard(pokemon: pokemon[index]),
          );
        },
      ),
    );
  }
}
