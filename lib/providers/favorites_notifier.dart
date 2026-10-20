import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import 'pokemon_list_notifier.dart';

/// Features 3 & 4 — Favorite Pokémon and the heart indicator.
///
/// State is the set of favorite Pokémon IDs, in the order they were added.
/// IDs (not Pokemon objects) are stored so favorites survive a refresh of
/// the list.
class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const <int>{};

  bool isFavorite(int pokemonId) => state.contains(pokemonId);

  void toggle(int pokemonId) =>
      isFavorite(pokemonId) ? remove(pokemonId) : add(pokemonId);

  void add(int pokemonId) {
    if (isFavorite(pokemonId)) return;
    state = <int>{...state, pokemonId}; // new Set -> listeners are notified
  }

  void remove(int pokemonId) {
    if (!isFavorite(pokemonId)) return;
    state = <int>{...state}..remove(pokemonId);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(
  FavoritesNotifier.new,
);

/// The favorite Pokémon objects for the favorites panel. Recomputes
/// automatically when a favorite is added/removed or the list reloads.
final favoritePokemonProvider = Provider<List<Pokemon>>((ref) {
  final ids = ref.watch(favoritesProvider);
  final byId = {for (final p in ref.watch(loadedPokemonProvider)) p.id: p};
  return [
    for (final id in ids)
      if (byId[id] case final pokemon?) pokemon,
  ];
});

/// Whether the favorites panel is expanded. Kept in app state (not in a
/// widget) so the panel stays open/closed as you move between screens.
class FavoritesPanelNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void open() => state = true;

  void close() => state = false;
}

final favoritesPanelProvider = NotifierProvider<FavoritesPanelNotifier, bool>(
  FavoritesPanelNotifier.new,
);
