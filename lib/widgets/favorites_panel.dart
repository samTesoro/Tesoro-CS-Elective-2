import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_notifier.dart';
import '../providers/music_notifier.dart';
import '../providers/nickname_notifier.dart';
import '../theme.dart';
import 'pokemon_card.dart' show PokemonImage;

class FavoritesPanel extends ConsumerWidget {
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

class FavoritesDrawer extends ConsumerWidget {
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

class FavoritesFab extends ConsumerWidget {
  static const _size = 48.0;

  static const _margin = 16.0;

  const FavoritesFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteCount = ref.watch(favoritesProvider.select((s) => s.length));
    final saved = ref.watch(favoritesFabPositionProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxX = constraints.maxWidth - _size - _margin;
        final maxY = constraints.maxHeight - _size - _margin;
        Offset clamp(Offset o) => Offset(
          o.dx.clamp(_margin, maxX < _margin ? _margin : maxX),
          o.dy.clamp(_margin, maxY < _margin ? _margin : maxY),
        );
        final position = clamp(saved ?? Offset(maxX, maxY));

        return Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Semantics(
                button: true,
                label: 'Show favorites',
                child: GestureDetector(
                  onTap: () {
                    ref.read(musicProvider.notifier).playClick();
                    Scaffold.of(context).openEndDrawer();
                  },
                  onPanUpdate: (details) => ref
                      .read(favoritesFabPositionProvider.notifier)
                      .set(clamp(position + details.delta)),
                  child: SizedBox(
                    width: _size,
                    height: _size,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: pixelBox(
                              color: theme.cardTheme.color ?? Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: const PixelHeart(size: 22),
                          ),
                        ),
                        if (favoriteCount > 0)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentRed,
                                border: Border.all(
                                  color: pixelBorderColor,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '$favoriteCount',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'PokemonPixel',
                                  fontSize: 16,
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
              ),
            ),
          ],
        );
      },
    );
  }
}

class PixelHeart extends StatelessWidget {
  final double size;

  const PixelHeart({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _PixelHeartPainter());
}

class _PixelHeartPainter extends CustomPainter {
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
