import 'dart:ui' show Offset;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import 'pokemon_list_notifier.dart';

class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const <int>{};

  bool isFavorite(int pokemonId) => state.contains(pokemonId);

  void toggle(int pokemonId) =>
      isFavorite(pokemonId) ? remove(pokemonId) : add(pokemonId);

  void add(int pokemonId) {
    if (isFavorite(pokemonId)) return;
    state = <int>{...state, pokemonId};
  }

  void remove(int pokemonId) {
    if (!isFavorite(pokemonId)) return;
    state = <int>{...state}..remove(pokemonId);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(
  FavoritesNotifier.new,
);

final favoritePokemonProvider = Provider<List<Pokemon>>((ref) {
  final ids = ref.watch(favoritesProvider);
  final byId = {for (final p in ref.watch(loadedPokemonProvider)) p.id: p};
  return [
    for (final id in ids)
      if (byId[id] case final pokemon?) pokemon,
  ];
});

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

class FavoritesFabPositionNotifier extends Notifier<Offset?> {
  @override
  Offset? build() => null;

  void set(Offset position) => state = position;
}

final favoritesFabPositionProvider =
    NotifierProvider<FavoritesFabPositionNotifier, Offset?>(
      FavoritesFabPositionNotifier.new,
    );
