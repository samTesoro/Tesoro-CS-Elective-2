import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/music_service.dart';
import '../services/pokemon_service.dart';
import '../theme.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_view.dart';
import '../widgets/volume_control.dart';

class PokedexScreen extends StatefulWidget {
  final PokemonService service;
  final MusicService music;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const PokedexScreen({
    super.key,
    required this.service,
    required this.music,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  // Kanto regional Pokedex: #001 Bulbasaur through #151 Mew.
  static const _kantoDexSize = 151;

  // Created ONCE in initState, not inside build(), so rebuilds (like the
  // theme toggle) don't fire a new network request each time.
  late Future<List<Pokemon>> _pokemonFuture;

  final _searchController = TextEditingController();
  String _query = '';

  // Pauses the music when the app is minimized and resumes it on return.
  late final AppLifecycleListener _lifecycle;

  @override
  void dispose() {
    _lifecycle.dispose();
    widget.music.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Matches on name ("pika") or Pokedex number ("25" / "#025").
  List<Pokemon> _filter(List<Pokemon> pokemon) {
    final q = _query.trim().toLowerCase().replaceFirst('#', '');
    if (q.isEmpty) return pokemon;
    final number = int.tryParse(q);
    return pokemon
        .where(
          (p) =>
              p.displayName.toLowerCase().contains(q) ||
              p.name.contains(q) ||
              (number != null && p.id == number),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _pokemonFuture = widget.service.fetchPokemon(limit: _kantoDexSize);

    _lifecycle = AppLifecycleListener(
      onHide: widget.music.pause,
      onShow: widget.music.resume,
    );
    widget.music.start();
  }

  void _retry() {
    setState(() {
      _pokemonFuture = widget.service.fetchPokemon(limit: _kantoDexSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    // start() is a no-op once playing; this retries after the first tap for
    // browsers that block audio until the user interacts with the page.
    return Listener(
      onPointerDown: (_) => widget.music.start(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: Image.asset(
            'assets/pokedex_logo.png',
            height: 52,
            semanticLabel: 'Pokedex',
          ),
          actions: [
            VolumeControl(music: widget.music),
            IconButton(
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: widget.onToggleTheme,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 20, color: pixelBorderColor),
                decoration: InputDecoration(
                  hintText: 'Search Pokemon...',
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: pixelBorderColor),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(
                            Icons.close,
                            color: pixelBorderColor,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/pokedex_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: FutureBuilder<List<Pokemon>>(
            future: _pokemonFuture,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    strokeCap: StrokeCap.square,
                  ),
                );
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
                  title: 'No Pokemon found',
                  message: 'The PokeAPI returned an empty list.',
                  onRetry: _retry,
                );
              }

              final results = _filter(pokemon);
              if (results.isEmpty) {
                return StatusView(
                  icon: Icons.search_off,
                  title: 'No match',
                  message: 'No Pokemon matches "${_query.trim()}".',
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
                itemCount: results.length,
                itemBuilder: (context, index) =>
                    PokemonCard(pokemon: results[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
