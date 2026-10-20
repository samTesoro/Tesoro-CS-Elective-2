import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_notifier.dart';
import '../providers/music_notifier.dart';
import '../providers/nickname_notifier.dart';
import '../theme.dart';
import 'pokemon_card.dart' show PokemonImage;

/// Feature 3 — the retractable favorites panel.
///
/// Placed at the top of both the home and the details screen. Whether it is
/// open lives in `favoritesPanelProvider`, so it stays open or closed across
/// screens. Its contents come from `favoritePokemonProvider`, so it updates
/// the moment a heart is tapped anywhere in the app.
class FavoritesPanel extends ConsumerWidget {
  /// Called when a favorite is tapped (opens its details page).
  final ValueChanged<int> onOpen;

  const FavoritesPanel({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOpen = ref.watch(favoritesPanelProvider);
    final favoriteCount = ref.watch(favoritesProvider.select((s) => s.length));
    final favorites = ref.watch(favoritePokemonProvider);

    void toggle() {
      ref.read(musicProvider.notifier).playClick();
      ref.read(favoritesPanelProvider.notifier).toggle();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: pixelBox(color: theme.cardTheme.color ?? Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: always visible, tap to expand / collapse.
          Semantics(
            button: true,
            expanded: isOpen,
            child: InkWell(
              onTap: toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: accentRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Favorites ($favoriteCount)',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Icon(isOpen ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
          ),
          // Body: animates open / closed.
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !isOpen
                ? const SizedBox(width: double.infinity)
                : Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: pixelBorderColor,
                          width: pixelBorderWidth,
                        ),
                      ),
                    ),
                    child: favorites.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              favoriteCount == 0
                                  ? 'No favorites yet. Tap the heart on a '
                                        'Pokemon to add it here.'
                                  : 'Your favorites will show up once the '
                                        'Pokedex finishes loading.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                          )
                        : SizedBox(
                            height: 128,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(10),
                              itemCount: favorites.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) => _FavoriteTile(
                                pokemon: favorites[index],
                                onOpen: onOpen,
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  final Pokemon pokemon;
  final ValueChanged<int> onOpen;

  const _FavoriteTile({required this.pokemon, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final nickname = ref.watch(
      nicknameProvider.select((nicknames) => nicknames[pokemon.id]),
    );

    return SizedBox(
      width: 96,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                ref.read(musicProvider.notifier).playClick();
                onOpen(pokemon.id);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(color: pixelBorderColor, width: 2),
                ),
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    // No Hero here: the grid card already owns the hero tag.
                    Expanded(child: PokemonImage(url: pokemon.imageUrl)),
                    Text(
                      nickname ?? pokemon.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove ${pokemon.displayName} from favorites',
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(musicProvider.notifier).playClick();
                ref.read(favoritesProvider.notifier).remove(pokemon.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}