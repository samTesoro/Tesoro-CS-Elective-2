import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_view.dart';
import '../widgets/type_badge.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pokemon = context.watch<PokemonProvider>().selectedPokemon;
    final isDark = context.watch<ThemeProvider>().isDark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(
          pokemon?.displayName ?? 'Pokemon',
          style: const TextStyle(fontSize: 28),
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
        child: pokemon == null
            ? const StatusView(
                icon: Icons.catching_pokemon,
                title: 'Pokemon not found',
                message: 'This Pokemon is no longer in the list.',
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      decoration: pixelBox(
                        color: theme.cardTheme.color ?? Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 300,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              border: const Border(
                                bottom: BorderSide(
                                  color: pixelBorderColor,
                                  width: pixelBorderWidth,
                                ),
                              ),
                            ),
                            child: Hero(
                              tag: pokemonHeroTag(pokemon.id),
                              child: Image.network(
                                pokemon.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.catching_pokemon,
                                      size: 120,
                                      color: theme.colorScheme.primary,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  pokemon.displayId,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pokemon.displayName,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineLarge,
                                ),
                                if (pokemon.types.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      for (final type in pokemon.types)
                                        TypeFilterChip(
                                          type: type,
                                          selected: true,
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
