import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../models/pokemon_type.dart';
import '../services/music_service.dart';
import '../services/pokemon_service.dart';
import '../theme.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_view.dart';
import '../widgets/type_badge.dart';
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
  static const _pokemonLimit = 30;

  late Future<List<Pokemon>> _pokemonFuture;

  final _searchController = TextEditingController();
  String _query = '';

  PokemonType? _selectedType;

  late final AppLifecycleListener _lifecycle;

  @override
  void dispose() {
    _lifecycle.dispose();
    widget.music.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Pokemon> _filter(List<Pokemon> pokemon) {
    final q = _query.trim().toLowerCase().replaceFirst('#', '');
    final number = int.tryParse(q);
    return pokemon
        .where((p) => _selectedType == null || p.types.contains(_selectedType))
        .where(
          (p) =>
              q.isEmpty ||
              p.displayName.toLowerCase().contains(q) ||
              p.name.contains(q) ||
              (number != null && p.id == number),
        )
        .toList();
  }

  String get _noMatchMessage {
    final q = _query.trim();
    final type = _selectedType?.label;
    if (type != null && q.isNotEmpty) {
      return 'No $type-type Pokemon matches "$q".';
    }
    if (type != null) return 'No $type-type Pokemon in this list.';
    return 'No Pokemon matches "$q".';
  }

  Widget _buildTypeFilter() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        itemCount: PokemonType.values.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = index == 0 ? null : PokemonType.values[index - 1];
          return TypeFilterChip(
            type: type,
            selected: _selectedType == type,
            onTap: _withClick(() => setState(() => _selectedType = type)),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pokemonFuture = widget.service.fetchPokemon(limit: _pokemonLimit);

    _lifecycle = AppLifecycleListener(
      onHide: widget.music.pause,
      onShow: widget.music.resume,
    );
    widget.music.start();
  }

  VoidCallback _withClick(VoidCallback action) => () {
    widget.music.playClick();
    action();
  };

  void _retry() {
    setState(() {
      _pokemonFuture = widget.service.fetchPokemon(limit: _pokemonLimit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

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
              onPressed: _withClick(widget.onToggleTheme),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(108),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: 20,
                      color: controlTextColor(context),
                    ),
                    cursorColor: controlTextColor(context),
                    decoration: InputDecoration(
                      hintText: 'Search Pokemon...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: controlTextColor(context),
                      ),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: Icon(
                                Icons.close,
                                color: controlTextColor(context),
                              ),
                              onPressed: _withClick(() {
                                _searchController.clear();
                                setState(() => _query = '');
                              }),
                            ),
                    ),
                  ),
                ),
                _buildTypeFilter(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/pokedex_background.jpg'),
              fit: BoxFit.cover,
              colorFilter: isDark
                  ? ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.6),
                      BlendMode.srcATop,
                    )
                  : null,
            ),
          ),
          child: FutureBuilder<List<Pokemon>>(
            future: _pokemonFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    strokeCap: StrokeCap.square,
                  ),
                );
              }

              if (snapshot.hasError) {
                return StatusView(
                  icon: Icons.wifi_off_rounded,
                  title: 'Something went wrong',
                  message: '${snapshot.error}',
                  onRetry: _withClick(_retry),
                );
              }

              final pokemon = snapshot.data ?? const <Pokemon>[];
              if (pokemon.isEmpty) {
                return StatusView(
                  icon: Icons.catching_pokemon,
                  title: 'No Pokemon found',
                  message: 'The PokeAPI returned an empty list.',
                  onRetry: _withClick(_retry),
                );
              }

              final results = _filter(pokemon);
              if (results.isEmpty) {
                return StatusView(
                  icon: Icons.search_off,
                  title: 'No match',
                  message: _noMatchMessage,
                );
              }

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
