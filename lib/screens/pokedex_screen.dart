import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon_type.dart';
import '../providers/music_provider.dart';
import '../providers/pokemon_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/pokeball_spinner.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_view.dart';
import '../widgets/type_badge.dart';
import '../widgets/volume_control.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  late final _searchController = TextEditingController(
    text: context.read<PokemonProvider>().query,
  );

  @override
  void initState() {
    super.initState();
    context.read<MusicProvider>().start();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  VoidCallback _withClick(VoidCallback action) => () {
    context.read<MusicProvider>().playClick();
    action();
  };

  void _openDetails(int id) {
    context.read<PokemonProvider>().selectPokemon(id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PokemonDetailScreen()),
    );
  }

  Widget _buildTypeFilter(PokemonType? selectedType) {
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
            selected: selectedType == type,
            onTap: _withClick(
              () => context.read<PokemonProvider>().selectType(type),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(PokemonProvider provider) {
    switch (provider.status) {
      case PokemonStatus.loading:
        return const Center(child: PokeballSpinner(size: 80));

      case PokemonStatus.error:
        return StatusView(
          icon: Icons.wifi_off_rounded,
          title: 'Something went wrong',
          message: provider.errorMessage,
          onRetry: _withClick(provider.fetchPokemon),
        );

      case PokemonStatus.success:
        if (provider.pokemon.isEmpty) {
          return StatusView(
            icon: Icons.catching_pokemon,
            title: 'No Pokemon found',
            message: 'The PokeAPI returned an empty list.',
            onRetry: _withClick(provider.fetchPokemon),
          );
        }

        final results = provider.filteredPokemon;
        if (results.isEmpty) {
          return StatusView(
            icon: Icons.search_off,
            title: 'No match',
            message: provider.noMatchMessage,
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchPokemon,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final pokemon = results[index];
              return PokemonCard(
                pokemon: pokemon,
                onTap: _withClick(() => _openDetails(pokemon.id)),
              );
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final query = context.select((PokemonProvider p) => p.query);
    final selectedType = context.select((PokemonProvider p) => p.selectedType);
    final isLoading = context.select(
      (PokemonProvider p) => p.status == PokemonStatus.loading,
    );

    return Listener(
      onPointerDown: (_) => context.read<MusicProvider>().start(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          centerTitle: true,
          leading: IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: isLoading
                ? null
                : _withClick(context.read<PokemonProvider>().fetchPokemon),
          ),
          title: Image.asset(
            'assets/pokedex_logo.png',
            height: 52,
            semanticLabel: 'Pokedex',
          ),
          actions: [
            const VolumeControl(),
            IconButton(
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: _withClick(context.read<ThemeProvider>().toggleTheme),
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
                    onChanged: context.read<PokemonProvider>().setQuery,
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
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: Icon(
                                Icons.close,
                                color: controlTextColor(context),
                              ),
                              onPressed: _withClick(() {
                                _searchController.clear();
                                context.read<PokemonProvider>().setQuery('');
                              }),
                            ),
                    ),
                  ),
                ),
                _buildTypeFilter(selectedType),
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
          child: Consumer<PokemonProvider>(
            builder: (context, provider, _) => _buildBody(provider),
          ),
        ),
      ),
    );
  }
}
