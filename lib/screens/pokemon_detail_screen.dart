import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_notifier.dart';
import '../providers/music_notifier.dart';
import '../providers/nickname_notifier.dart';
import '../providers/pokemon_list_notifier.dart';
import '../providers/theme_notifier.dart';
import '../theme.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/nickname_dialog.dart';
import '../widgets/pokemon_about.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_view.dart';
import '../widgets/type_badge.dart';

/// Pushes the details page for the Pokemon with [id].
void openPokemonDetails(BuildContext context, int id) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => PokemonDetailScreen(pokemonId: id)),
  );
}

/// Details page. Only the ID travels through the route; the Pokemon, its
/// nickname and its favorite status are all read from Riverpod, so editing
/// the nickname here updates the grid card at the same time.
class PokemonDetailScreen extends ConsumerWidget {
  final int pokemonId;

  const PokemonDetailScreen({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonByIdProvider(pokemonId));
    final nickname = ref.watch(
      nicknameProvider.select((nicknames) => nicknames[pokemonId]),
    );
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isPanelOpen = ref.watch(favoritesPanelProvider);
    final theme = Theme.of(context);
    // Phones use a floating button + drawer instead of the inline panel.
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    // Opening another favorite from here replaces this page.
    void openFavorite(int id) {
      if (id == pokemonId) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PokemonDetailScreen(pokemonId: id),
        ),
      );
    }

    return Scaffold(
      endDrawer: isMobile ? FavoritesDrawer(onOpen: openFavorite) : null,
      floatingActionButton: isMobile ? const FavoritesFab() : null,
      appBar: AppBar(
        toolbarHeight: 72,
        automaticallyImplyActions: false,
        title: Text(
          pokemon?.displayName ?? 'Pokemon',
          style: const TextStyle(fontSize: 28),
        ),
        actions: [
          if (!isMobile)
            IconButton(
              tooltip: isPanelOpen ? 'Hide favorites' : 'Show favorites',
              icon: Icon(isPanelOpen ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                ref.read(musicProvider.notifier).playClick();
                ref.read(favoritesPanelProvider.notifier).toggle();
              },
            ),
        ],
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
        child: Column(
          children: [
            if (!isMobile) FavoritesPanel(onOpen: openFavorite),
            Expanded(
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
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: pixelBorderColor,
                                        width: pixelBorderWidth,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Hero(
                                            tag: pokemonHeroTag(pokemon.id),
                                            child: PokemonImage(
                                              url: pokemon.imageUrl,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: FavoriteHeartButton(
                                          pokemonId: pokemon.id,
                                          size: 34,
                                        ),
                                      ),
                                    ],
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
                                      // Nickname as the headline when set;
                                      // the original name stays visible.
                                      Text(
                                        nickname == null
                                            ? pokemon.displayName
                                            : '"$nickname"',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.headlineLarge,
                                      ),
                                      if (nickname != null)
                                        Text(
                                          'Original name: '
                                          '${pokemon.displayName}',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyLarge,
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
                                      const SizedBox(height: 20),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          ref
                                              .read(musicProvider.notifier)
                                              .playClick();
                                          showNicknameEditor(context, pokemon);
                                        },
                                        icon: const Icon(Icons.edit),
                                        label: Text(
                                          nickname == null
                                              ? 'Add nickname'
                                              : 'Edit nickname',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: pixelBorderColor,
                                        width: pixelBorderWidth,
                                      ),
                                    ),
                                  ),
                                  child: PokemonAbout(pokemonId: pokemon.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
