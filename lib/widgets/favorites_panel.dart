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

/// Mobile variant of the favorites panel: a side drawer with a grid of
/// favorites, opened from a floating button instead of sitting above the grid.
class FavoritesDrawer extends ConsumerWidget {
  /// Called when a favorite is tapped (opens its details page).
  final ValueChanged<int> onOpen;

  const FavoritesDrawer({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteCount = ref.watch(favoritesProvider.select((s) => s.length));
    final favorites = ref.watch(favoritePokemonProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
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
                  IconButton(
                    tooltip: 'Close favorites',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(musicProvider.notifier).playClick();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: pixelBorderWidth,
              thickness: pixelBorderWidth,
              color: pixelBorderColor,
            ),
            Expanded(
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
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 120,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) => _FavoriteTile(
                        pokemon: favorites[index],
                        onOpen: (id) {
                          Navigator.of(context).pop();
                          onOpen(id);
                        },
                      ),
                    ),
            ),
          ],
        ),
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

/// Mobile floating favorites button: a square pixel box with a pixel-art
/// heart and a boxy count badge. Opens the nearest Scaffold's end drawer.
class FavoritesFab extends ConsumerWidget {
  const FavoritesFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteCount = ref.watch(favoritesProvider.select((s) => s.length));

    return Semantics(
      button: true,
      label: 'Show favorites',
      child: GestureDetector(
        onTap: () {
          ref.read(musicProvider.notifier).playClick();
          Scaffold.of(context).openEndDrawer();
        },
        child: SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: pixelBox(
                    color: theme.cardTheme.color ?? Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: const PixelHeart(size: 32),
                ),
              ),
              if (favoriteCount > 0)
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 28),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: accentRed,
                      border: Border.all(
                        color: pixelBorderColor,
                        width: pixelBorderWidth,
                      ),
                    ),
                    child: Text(
                      '$favoriteCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PokemonPixel',
                        fontSize: 22,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A heart drawn as a grid of square pixels.
class PixelHeart extends StatelessWidget {
  final double size;

  const PixelHeart({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _PixelHeartPainter());
}

class _PixelHeartPainter extends CustomPainter {
  // 0 = empty, 1 = outline, 2 = fill, 3 = highlight.
  static const _grid = [
    [0, 1, 1, 0, 0, 0, 1, 1, 0],
    [1, 3, 2, 1, 0, 1, 2, 2, 1],
    [1, 3, 2, 2, 1, 2, 2, 2, 1],
    [1, 2, 2, 2, 2, 2, 2, 2, 1],
    [0, 1, 2, 2, 2, 2, 2, 1, 0],
    [0, 0, 1, 2, 2, 2, 1, 0, 0],
    [0, 0, 0, 1, 2, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0],
  ];
  static const _colors = {1: pixelBorderColor, 2: accentRed, 3: Colors.white};

  @override
  void paint(Canvas canvas, Size size) {
    final cols = _grid.first.length;
    final px = size.width / cols;
    final top = (size.height - px * _grid.length) / 2;
    final paint = Paint()..isAntiAlias = false;
    for (var y = 0; y < _grid.length; y++) {
      for (var x = 0; x < cols; x++) {
        final color = _colors[_grid[y][x]];
        if (color == null) continue;
        paint.color = color;
        canvas.drawRect(Rect.fromLTWH(x * px, top + y * px, px, px), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
