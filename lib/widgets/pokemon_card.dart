import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_notifier.dart';
import '../providers/music_notifier.dart';
import '../providers/nickname_notifier.dart';
import '../theme.dart';
import 'type_badge.dart';

/// Grid card: image, ID, types, original name, nickname (if any) and a
/// heart for the favorite status.
///
/// It is a ConsumerWidget that `watch`es ONLY its own nickname and favorite
/// flag (via `select`), so editing one Pokémon rebuilds just that card.
class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final nickname = ref.watch(
      nicknameProvider.select((nicknames) => nicknames[pokemon.id]),
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: MouseRegion(
        cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        child: Container(
          decoration: pixelBox(color: theme.cardTheme.color ?? Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          border: const Border(
                            bottom: BorderSide(
                              color: pixelBorderColor,
                              width: pixelBorderWidth,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Hero(
                          tag: pokemonHeroTag(pokemon.id),
                          child: PokemonImage(url: pokemon.imageUrl),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: FavoriteHeartButton(pokemonId: pokemon.id),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pokemon.displayId,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        for (final type in pokemon.types) ...[
                          const SizedBox(width: 4),
                          TypeIcon(type: type),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Nickname (if set) on top; the original name is always
                    // shown.
                    if (nickname != null) ...[
                      Text(
                        '"$nickname"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ] else
                      Text(
                        pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature 4 — the heart. Filled red when the Pokémon is a favorite,
/// outlined when not. Tapping it calls FavoritesNotifier.toggle().
class FavoriteHeartButton extends ConsumerWidget {
  final int pokemonId;
  final double size;

  const FavoriteHeartButton({
    super.key,
    required this.pokemonId,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(pokemonId)),
    );

    return IconButton(
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      iconSize: size,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? accentRed : controlTextColor(context),
      ),
      onPressed: () {
        ref.read(musicProvider.notifier).playClick();
        ref.read(favoritesProvider.notifier).toggle(pokemonId);
      },
    );
  }
}

/// Network image with its own loading and error states.
class PokemonImage extends StatelessWidget {
  final String url;

  const PokemonImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              strokeCap: StrokeCap.square,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.catching_pokemon,
        size: 56,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

String pokemonHeroTag(int id) => 'pokemon-image-$id';